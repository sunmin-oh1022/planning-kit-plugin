#!/usr/bin/env python3
"""PostToolUse(Edit|Write|MultiEdit) — 편집 직후 문서 정합성 자동 검증 (경고만).

docs/**.md 또는 prototype/**.designspec.html 을 건드린 직후에만 scripts/check-docs.sh 를
돌려, REQ↔INDEX 동기화·추적 끊김·ID 중복·버전 라벨 정합·.baseline 무결성을 점검한다.
FAIL 이면 결과를 additionalContext 로 Claude 에게 surface 하되 작업 흐름은 막지 않는다.
"""
import sys, json, subprocess, os


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    ti = data.get("tool_input", {}) or {}
    fp = (ti.get("file_path") or "").replace("\\", "/")

    root = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()

    # 검증 대상 판정: docs 마크다운 또는 라이브 designspec(.baseline·_template 제외)
    relevant = False
    if "/docs/" in fp and fp.endswith(".md"):
        relevant = True
    if (fp.endswith(".designspec.html") and "/prototype/" in fp
            and "/.baseline/" not in fp
            and not fp.endswith("_template.designspec.html")):
        relevant = True
    if not relevant:
        sys.exit(0)

    check = os.path.join(root, "scripts", "check-docs.sh")
    if not os.path.exists(check):
        sys.exit(0)

    proc = subprocess.run(["bash", check], cwd=root,
                          capture_output=True, text=True)
    if proc.returncode == 0:
        sys.exit(0)  # ALL GREEN — 조용히 통과

    out = (proc.stdout or "") + (proc.stderr or "")
    fail_lines = [l for l in out.splitlines() if ("✗" in l or "FAILED" in l)]
    detail = "\n".join(fail_lines) if fail_lines else out[-1500:]

    msg = ("⚠️ 정합성 검증 실패 (scripts/check-docs.sh) — 방금 편집이 "
           "docs/designspec 정합성을 깼을 수 있음:\n" + detail +
           "\n전체 출력: bash scripts/check-docs.sh")

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": msg,
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
