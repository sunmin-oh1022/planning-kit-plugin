#!/usr/bin/env python3
"""PreToolUse(Bash|Edit|Write|MultiEdit) — 형상 관리 불변식을 깨는 위험 동작 차단.

이 키트의 '기계 강제' 가드레일(boundaries.md #5). 차단 시 exit 2 + 사유를 Claude 에게 전달.
release-cut.sh(절차 B)를 거치는 정상 경로는 통과시킨다.
"""
import sys, json, re, os


def deny(reason):
    sys.stderr.write(reason + "\n")
    sys.exit(2)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool = data.get("tool_name", "")
    ti = data.get("tool_input", {}) or {}

    # ── 편집 도구: 동결본·베이스라인 손편집 차단 ─────────────────────────
    if tool in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
        fp = (ti.get("file_path") or "").replace("\\", "/")
        base = os.path.basename(fp)

        if "/.baseline/" in fp:
            deny("\U0001f512 차단: `.baseline/` 직접 편집 금지. 배포본 동결 스냅샷의 복제본이라 "
                 "release-cut(절차 B)으로만 갱신한다.\n"
                 "→ `release-cut` 스킬 또는 `bash scripts/release-cut.sh`. "
                 "(rules/methodology/change-management.md 절차 B #2)")

        if re.search(r'_v\d+\.\d+\.(html|pdf)$', base):
            deny(f"\U0001f512 차단: 버전 동결본 `{base}` 은 불변(immutable). "
                 "`_vX.Y.html`·`_vX.Y.pdf` 는 어느 단계에서도 손으로 수정·생성하지 않는다.\n"
                 "→ 다음 버전 라인 개시는 `bash scripts/release-cut.sh` 가 cp 로 만든다. "
                 "(change-management.md 절차 B #3·#4)")
        sys.exit(0)

    # ── Bash: 위험 명령 패턴 차단 ──────────────────────────────────────
    if tool == "Bash":
        c = ti.get("command", "") or ""
        via_releasecut = "release-cut.sh" in c

        # 1) 버전 라벨 블랭킷 치환 (sed …/g) — 역사 기록·상태 칩 파괴
        if (re.search(r'\bsed\b', c)
                and re.search(r's[/|#~@]v?\d+\.\d+', c)
                and re.search(r'[/|#~@]g\b', c)
                and re.search(r'\.html|designspec', c)):
            deny("⛔ 차단: 버전 라벨 블랭킷 치환(sed …/g) 금지. designspec 의 `vX.Y` 일괄 치환은 "
                 "화면 상태 칩(`vX.Y · 개정`)·인라인 역사 기록·개정 이력을 파괴한다.\n"
                 "→ 딱 3종(커버 칩 / 푸터 토큰 / 프로토타입 참조)만 정밀 치환. `release-cut` 스킬 사용 후 "
                 "남은 vX.Y 수를 grep 으로 검증. (change-management.md ⚠️ 치환 규칙)")

        # 2) 동결본 변경·삭제·덮어쓰기
        if (re.search(r'(\brm\b|\bmv\b|\bcp\b|>{1,2}|\btee\b|\btruncate\b|sed\s+-i)', c)
                and re.search(r'_v\d+\.\d+\.(html|pdf)', c)
                and not via_releasecut):
            deny("\U0001f512 차단: 동결본 `_vX.Y.html`/`_vX.Y.pdf` 변경·삭제·덮어쓰기 금지(불변). "
                 "읽기/복사 원본으로만 쓴다.\n"
                 "→ 새 버전 라인은 release-cut(절차 B)으로. (change-management.md 절차 B #4)")

        # 3) .baseline/ 직접 변경 (release-cut.sh 경유는 허용)
        if (re.search(r'(\brm\b|\bmv\b|\bcp\b|>{1,2}|\btee\b|sed\s+-i)', c)
                and ".baseline" in c
                and not via_releasecut):
            deny("\U0001f512 차단: `.baseline/` 직접 변경 금지 — 배포본과 항상 md5 일치해야 하는 동결 소스. "
                 "손으로 바꾸면 형상 관리가 깨진다.\n"
                 "→ `bash scripts/release-cut.sh` (또는 `release-cut` 스킬)로 갱신. "
                 "(change-management.md 절차 B #2)")

        # 4) 광범위 파괴 명령
        if re.search(r'rm\s+-[a-z]*r[a-z]*f?\s+(/|~|\$HOME)(\s|/|$)', c) \
                or re.search(r'rm\s+-[a-z]*r[a-z]*f?\s+/\s*$', c):
            deny("⛔ 차단: 광범위 `rm -rf` (루트/홈 대상) — 복구 불가. 대상 경로를 좁혀서 다시.")
        if ":(){" in c and ":|:" in c:
            deny("⛔ 차단: fork bomb 패턴.")

        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
