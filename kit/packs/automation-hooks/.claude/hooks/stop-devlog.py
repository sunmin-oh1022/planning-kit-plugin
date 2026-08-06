#!/usr/bin/env python3
"""Stop — 문서 작업으로 끝났는데 DEVLOG 오늘 항목이 없으면 Claude 에게 작성을 유도.

이번 세션에서 docs/**.md 또는 prototype/**.designspec.html 을 실제로 편집했고
DEVLOG.md 에 오늘 날짜(## YYYY-MM-DD) 헤딩이 없을 때만 한 번 막는다(exit 2).
stop_hook_active 가드로 무한 루프를 방지한다.
"""
import sys, json, os, datetime


def session_edited_docs(tpath):
    """트랜스크립트(JSONL)에서 docs/designspec 을 대상으로 한 Edit/Write 가 있었나."""
    if not tpath or not os.path.exists(tpath):
        return False
    try:
        with open(tpath, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                msg = obj.get("message") if isinstance(obj, dict) else None
                content = msg.get("content") if isinstance(msg, dict) else None
                if not isinstance(content, list):
                    continue
                for item in content:
                    if not isinstance(item, dict) or item.get("type") != "tool_use":
                        continue
                    if item.get("name") not in ("Edit", "Write", "MultiEdit"):
                        continue
                    fp = ((item.get("input") or {}).get("file_path") or "").replace("\\", "/")
                    if "/docs/" in fp and fp.endswith(".md"):
                        return True
                    if (fp.endswith(".designspec.html") and "/prototype/" in fp
                            and "/.baseline/" not in fp
                            and not fp.endswith("_template.designspec.html")):
                        return True
    except Exception:
        return False
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    if data.get("stop_hook_active"):
        sys.exit(0)  # 이미 stop hook 으로 이어가는 중 — 재진입 방지

    root = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    devlog = os.path.join(root, "DEVLOG.md")
    if not os.path.exists(devlog):
        sys.exit(0)

    if not session_edited_docs(data.get("transcript_path", "")):
        sys.exit(0)  # 문서 편집이 없던 세션 — 로그 강요하지 않음

    today = datetime.date.today().strftime("%Y-%m-%d")
    with open(devlog, encoding="utf-8") as f:
        content = f.read()
    if ("## " + today) in content:
        sys.exit(0)  # 이미 오늘 항목 있음

    sys.stderr.write(
        f"\U0001f4dd DEVLOG 미갱신: 이번 세션에서 문서를 편집했는데 DEVLOG.md 에 오늘({today}) 항목이 없음.\n"
        f"끝내기 전에 `## {today}` 헤딩을 추가하고 그 아래 한 줄로 "
        f"'무엇을 했는지 / 왜 그렇게 결정했는지 / 다음 할 일'을 남겨줘.\n"
        f"(역할 구분: 버전 확정 변경은 HISTORY.md, 외부 공유는 SHARE.md — DEVLOG.md 상단 참고)\n"
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
