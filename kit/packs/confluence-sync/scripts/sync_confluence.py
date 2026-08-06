"""
docs/ 하위 마크다운 문서를 Confluence 페이지로 동기화합니다 (로컬 수동 실행).

Atlassian Cloud(`*.atlassian.net`)와 Confluence Data Center / Server를 모두
지원하며, BASE_URL을 보고 자동으로 모드를 선택합니다.

문서 상단 YAML frontmatter에서 `confluence.page_id`를 읽어 해당 페이지를
갱신합니다. 본문의 ```mermaid 코드 블록은 mermaid-cli(mmdc)로 PNG 렌더링한
뒤 `docs/screens/` 등 로컬 이미지 참조와 함께 페이지 첨부파일로 업로드하고
본문은 <ac:image> 매크로로 치환합니다.

Frontmatter 예시:
    ---
    confluence:
      page_id: "1234567890"
      title: "PRD — 프로젝트명"   # 생략 시 Confluence 페이지 현재 title 유지
    ---

필요한 환경 변수 (둘 다 .env.confluence.local에서 source):
    CONFLUENCE_BASE_URL    Cloud: https://xxx.atlassian.net  / DC: https://wiki.your-corp.com
    CONFLUENCE_USER_EMAIL  Cloud 모드에서만 필요 (Basic Auth용 계정 이메일)
    CONFLUENCE_API_TOKEN   Cloud: id.atlassian.com API token / DC: Personal Access Token

실행:
    scripts/sync.sh                       # docs/ 전체
    scripts/sync.sh docs/PRD.md           # 특정 파일
    scripts/sync.sh --dry-run docs/PRD.md # 변환만, API 호출 없음
"""
from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

import frontmatter
import markdown
import requests


MERMAID_BLOCK = re.compile(r"```mermaid\s*\n(.*?)```", re.DOTALL)
MD_IMAGE = re.compile(r"!\[([^\]]*)\]\(([^)\s]+)(?:\s+\"([^\"]*)\")?\)")
PLACEHOLDER = re.compile(r"\{\{ATTACHMENT:([^}]+)\}\}")


def short_hash(text: str, n: int = 10) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:n]


# ----- Confluence client -----------------------------------------------------

SYNC_MSG = "Synced from docs/"


class ConfluenceClient:
    """Cloud / Data Center 공통 인터페이스."""

    def get_page(self, page_id: str) -> dict:  # pragma: no cover
        raise NotImplementedError

    def update_page(
        self, page_id: str, title: str, body_storage: str, current_version: int
    ) -> None:  # pragma: no cover
        raise NotImplementedError

    def upload_attachment(
        self,
        page_id: str,
        file_path: Path,
        attachment_name: str,
        comment: str = "docs sync",
    ) -> None:  # pragma: no cover
        raise NotImplementedError


@dataclass
class ConfluenceCloudClient(ConfluenceClient):
    """Atlassian Cloud: Basic Auth(email:token) + /wiki/api/v2 + /wiki/rest/api 첨부."""
    base_url: str
    email: str
    api_token: str

    @property
    def _auth(self) -> tuple[str, str]:
        return (self.email, self.api_token)

    def get_page(self, page_id: str) -> dict:
        r = requests.get(
            f"{self.base_url}/wiki/api/v2/pages/{page_id}",
            params={"body-format": "storage"},
            auth=self._auth,
            timeout=30,
        )
        r.raise_for_status()
        return r.json()

    def update_page(self, page_id, title, body_storage, current_version):
        r = requests.put(
            f"{self.base_url}/wiki/api/v2/pages/{page_id}",
            json={
                "id": page_id,
                "status": "current",
                "title": title,
                "body": {"representation": "storage", "value": body_storage},
                "version": {"number": current_version + 1, "message": SYNC_MSG},
            },
            auth=self._auth,
            timeout=60,
        )
        if r.status_code >= 400:
            raise RuntimeError(f"update_page failed [{r.status_code}]: {r.text}")

    def upload_attachment(self, page_id, file_path, attachment_name, comment="docs sync"):
        with open(file_path, "rb") as f:
            r = requests.post(
                f"{self.base_url}/wiki/rest/api/content/{page_id}/child/attachment",
                files={"file": (attachment_name, f, "application/octet-stream")},
                data={"comment": comment, "minorEdit": "true"},
                headers={"X-Atlassian-Token": "nocheck"},
                auth=self._auth,
                timeout=120,
            )
        if r.status_code >= 400:
            raise RuntimeError(
                f"upload_attachment {attachment_name} failed [{r.status_code}]: {r.text}"
            )


@dataclass
class ConfluenceDCClient(ConfluenceClient):
    """Confluence Data Center / Server: Bearer PAT + /rest/api/content."""
    base_url: str
    api_token: str

    @property
    def _headers(self) -> dict[str, str]:
        return {"Authorization": f"Bearer {self.api_token}"}

    def get_page(self, page_id: str) -> dict:
        r = requests.get(
            f"{self.base_url}/rest/api/content/{page_id}",
            params={"expand": "version,space"},
            headers={**self._headers, "Accept": "application/json"},
            timeout=30,
        )
        r.raise_for_status()
        return r.json()

    def update_page(self, page_id, title, body_storage, current_version):
        r = requests.put(
            f"{self.base_url}/rest/api/content/{page_id}",
            json={
                "type": "page",
                "title": title,
                "body": {
                    "storage": {"value": body_storage, "representation": "storage"}
                },
                "version": {"number": current_version + 1, "message": SYNC_MSG},
            },
            headers={**self._headers, "Content-Type": "application/json"},
            timeout=60,
        )
        if r.status_code >= 400:
            raise RuntimeError(f"update_page failed [{r.status_code}]: {r.text}")

    def upload_attachment(self, page_id, file_path, attachment_name, comment="docs sync"):
        with open(file_path, "rb") as f:
            r = requests.post(
                f"{self.base_url}/rest/api/content/{page_id}/child/attachment",
                files={"file": (attachment_name, f, "application/octet-stream")},
                data={"comment": comment, "minorEdit": "true"},
                headers={**self._headers, "X-Atlassian-Token": "nocheck"},
                timeout=120,
            )
        if r.status_code >= 400:
            raise RuntimeError(
                f"upload_attachment {attachment_name} failed [{r.status_code}]: {r.text}"
            )


def make_client(base_url: str, email: str, api_token: str) -> ConfluenceClient:
    """URL로 Cloud / DC를 자동 판별."""
    base_url = base_url.rstrip("/")
    if ".atlassian.net" in base_url:
        if not email:
            raise RuntimeError("Cloud 모드에는 CONFLUENCE_USER_EMAIL 이 필요합니다")
        return ConfluenceCloudClient(base_url, email, api_token)
    return ConfluenceDCClient(base_url, api_token)


# ----- mermaid rendering -----------------------------------------------------

def render_mermaid_to_png(diagram: str, out_path: Path) -> None:
    """mermaid 코드 → PNG 파일 (mermaid-cli 필요)."""
    if shutil.which("mmdc") is None:
        # 로컬 dry-run 환경 등에서 mmdc가 없을 때는 placeholder 파일로 대체
        out_path.write_bytes(b"")
        print(
            f"    (mmdc 없음 → 빈 placeholder 생성: {out_path.name})",
            file=sys.stderr,
        )
        return

    with tempfile.NamedTemporaryFile(
        "w", suffix=".mmd", delete=False, encoding="utf-8"
    ) as f:
        f.write(diagram)
        in_path = Path(f.name)

    cmd = [
        "mmdc",
        "-i", str(in_path),
        "-o", str(out_path),
        "-b", "white",
        "-s", "2",  # 2배 스케일 = 고해상도
    ]
    puppeteer_cfg = os.environ.get("PUPPETEER_CONFIG_FILE")
    if puppeteer_cfg:
        cmd.extend(["-p", puppeteer_cfg])

    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"mermaid 렌더링 실패: {e.stderr or e.stdout}"
        ) from e
    finally:
        in_path.unlink(missing_ok=True)


# ----- markdown preprocessing ------------------------------------------------

def extract_attachments(
    md_path: Path,
    body: str,
    work_dir: Path,
) -> tuple[str, dict[str, Path]]:
    """
    본문에서 mermaid 블록과 로컬 이미지 링크를 찾아
    - mermaid: PNG로 렌더링하고 placeholder로 치환
    - 로컬 이미지: 파일을 그대로 placeholder로 치환
    원격(http/https/data) 이미지는 그대로 둡니다.

    Returns:
        (rewritten_body, {attachment_name: local_file_path})
    """
    attachments: dict[str, Path] = {}
    doc_dir = md_path.parent

    def repl_mermaid(m: re.Match) -> str:
        diagram = m.group(1).strip()
        name = f"mermaid-{md_path.stem}-{short_hash(diagram)}.png"
        out = work_dir / name
        render_mermaid_to_png(diagram, out)
        attachments[name] = out
        # 앞뒤 개행으로 블록 레벨 요소가 되도록 강제
        return f"\n\n{{{{ATTACHMENT:{name}}}}}\n\n"

    body = MERMAID_BLOCK.sub(repl_mermaid, body)

    def repl_image(m: re.Match) -> str:
        src = m.group(2)
        if src.startswith(("http://", "https://", "data:")):
            return m.group(0)
        local = (doc_dir / src).resolve()
        if not local.exists():
            print(
                f"  ! 로컬 이미지를 찾지 못해 링크를 유지합니다: {src}",
                file=sys.stderr,
            )
            return m.group(0)
        # 결정적인 첨부 파일명: 경로 해시 + 원본명
        name = f"{short_hash(str(local))}-{local.name}"
        attachments[name] = local
        return f"{{{{ATTACHMENT:{name}}}}}"

    body = MD_IMAGE.sub(repl_image, body)
    return body, attachments


# ----- markdown → Confluence Storage Format ----------------------------------

def md_to_storage(md_text: str) -> str:
    """Markdown → Confluence Storage Format (XHTML-ish).

    python-markdown이 생성하는 HTML은 대부분 Storage Format과 호환됩니다.
    코드 블록만 Confluence `code` 매크로로 래핑해 가독성을 높입니다.
    """
    html = markdown.markdown(
        md_text,
        extensions=["fenced_code", "tables", "sane_lists", "toc", "attr_list"],
        output_format="xhtml",
    )

    def code_macro(m: re.Match) -> str:
        lang = (m.group(1) or "").strip()
        body = m.group(2)
        lang_param = (
            f'<ac:parameter ac:name="language">{lang}</ac:parameter>' if lang else ""
        )
        return (
            '<ac:structured-macro ac:name="code" ac:schema-version="1">'
            f"{lang_param}"
            f"<ac:plain-text-body><![CDATA[{body}]]></ac:plain-text-body>"
            "</ac:structured-macro>"
        )

    html = re.sub(
        r'<pre><code(?: class="language-([^"]+)")?>(.*?)</code></pre>',
        code_macro,
        html,
        flags=re.DOTALL,
    )

    # Confluence Storage Format은 strict XHTML이라 void 태그를 self-close해야 함.
    # 마크다운 본문에 직접 쓰인 <br>, <hr>를 정규화.
    html = re.sub(r"<br\s*/?>", "<br/>", html, flags=re.IGNORECASE)
    html = re.sub(r"<hr\s*/?>", "<hr/>", html, flags=re.IGNORECASE)
    return html


def replace_attachment_placeholders(storage_html: str) -> str:
    """{{ATTACHMENT:name}} → <ac:image>...</ac:image>."""
    def repl(m: re.Match) -> str:
        name = m.group(1)
        return (
            '<ac:image ac:align="center" ac:layout="center">'
            f'<ri:attachment ri:filename="{name}" />'
            "</ac:image>"
        )
    return PLACEHOLDER.sub(repl, storage_html)


# ----- per-file orchestration ------------------------------------------------

def sync_file(
    path: Path,
    client: Optional[ConfluenceClient],
    dry_run_dir: Optional[Path] = None,
) -> Optional[str]:
    print(f"::group::sync {path}")
    try:
        post = frontmatter.load(path)
        conf = post.metadata.get("confluence") or {}
        page_id = conf.get("page_id")
        if not page_id:
            print("  - confluence.page_id 없음 → 건너뜀")
            return None
        page_id = str(page_id)

        with tempfile.TemporaryDirectory(prefix="confluence-sync-") as tmp:
            work_dir = Path(tmp)

            # 1) mermaid 렌더 + 로컬 이미지 수집
            body, attachments = extract_attachments(path, post.content, work_dir)

            # 2) 첨부 업로드 (dry-run에서는 로컬 디렉터리로 복사)
            for name, file_path in attachments.items():
                if dry_run_dir is not None:
                    target = dry_run_dir / page_id / "attachments" / name
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(file_path, target)
                    print(f"  + [dry-run] attach: {target.relative_to(dry_run_dir)}")
                else:
                    assert client is not None
                    print(f"  + attach: {name}")
                    client.upload_attachment(page_id, file_path, attachment_name=name)

            # 3) 본문 변환 + placeholder 치환
            storage = md_to_storage(body)
            storage = replace_attachment_placeholders(storage)

            # 4) dry-run이면 파일로 저장, 아니면 PUT
            if dry_run_dir is not None:
                title = conf.get("title") or f"(현재 페이지 title 유지) — {path.stem}"
                out = dry_run_dir / page_id / "body.storage.xml"
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_text(storage, encoding="utf-8")
                meta = dry_run_dir / page_id / "meta.txt"
                meta.write_text(
                    f"source: {path}\npage_id: {page_id}\ntitle: {title}\n"
                    f"attachments: {len(attachments)}\nbody_bytes: {len(storage)}\n",
                    encoding="utf-8",
                )
                print(f"  ✓ [dry-run] {out.relative_to(dry_run_dir)} "
                      f"({len(storage):,} bytes, attachments={len(attachments)})")
            else:
                assert client is not None
                current = client.get_page(page_id)
                title = conf.get("title") or current["title"]
                version = int(current["version"]["number"])
                client.update_page(
                    page_id,
                    title=title,
                    body_storage=storage,
                    current_version=version,
                )
                print(f"  ✓ page {page_id}: v{version} → v{version + 1}")
            return None
    except Exception as e:  # noqa: BLE001
        print(f"::error file={path}::동기화 실패: {e}")
        return str(e)
    finally:
        print("::endgroup::")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+", help="동기화할 마크다운 파일들")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Confluence API를 호출하지 않고 변환 결과를 --out 디렉터리에 저장",
    )
    parser.add_argument(
        "--out",
        default="_dryrun_confluence",
        help="dry-run 결과물 출력 디렉터리 (기본: _dryrun_confluence)",
    )
    args = parser.parse_args()

    files = [Path(p) for p in args.files if p.endswith(".md")]
    if not files:
        print("동기화할 마크다운 파일이 없습니다.")
        return 0

    if args.dry_run:
        client = None
        dry_run_dir = Path(args.out).resolve()
        if dry_run_dir.exists():
            shutil.rmtree(dry_run_dir)
        dry_run_dir.mkdir(parents=True)
        print(f"[dry-run] 결과 디렉터리: {dry_run_dir}")
    else:
        client = make_client(
            base_url=os.environ["CONFLUENCE_BASE_URL"],
            email=os.environ.get("CONFLUENCE_USER_EMAIL", ""),
            api_token=os.environ["CONFLUENCE_API_TOKEN"],
        )
        dry_run_dir = None
        print(f"[client] {type(client).__name__}")

    failures: list[Path] = []
    for f in files:
        if not f.exists():
            print(f"  - 삭제된 파일, 건너뜀: {f}")
            continue
        if sync_file(f, client, dry_run_dir=dry_run_dir) is not None:
            failures.append(f)

    if failures:
        print(f"\n실패 {len(failures)}건: {', '.join(str(p) for p in failures)}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
