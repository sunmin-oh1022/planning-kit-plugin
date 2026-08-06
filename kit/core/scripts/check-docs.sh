#!/usr/bin/env bash
# 문서·정합성 검증 (스타터킷 generic 버전).
#   - 스타터킷 기본 골격 파일이 모두 있나
#   - CLAUDE.md → behavior.md → rules/methodology 자동 로드 체인이 살아 있나
#   - AGENTS.md 심링크 (다른 AI 도구 병용 시 선택) — 없으면 정상, 잘못 가리키면 실패
#   - methodology 내부 상호 링크 (README ↔ templates ↔ indexing)
#   - `(TODO …)` 플레이스홀더 잔여 수 — Phase 1 채움 진행 신호
#   - 인덱스 정합성 (rules/methodology/indexing.md 기반)
#       · ID 포맷 (REQ-### 또는 REQ-{DOMAIN}-####)
#       · 본문 ↔ INDEX.md 동기화 (집합 차이)
#       · 중복 ID
#       · 추적 끊김 (TC → REQ, REQ → TC/SCR)
#       · ROADMAP.md 존재
#   - 프로젝트별 1초 검증은 자리만 마련해두고, 채우는 건 본 프로젝트의 일
# 사용: bash scripts/check-docs.sh   (루트 어디서 호출해도 OK)
# 종료 코드: 0 = 통과 (warning 무관), 1 = 한 가지라도 실패

set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
ok()      { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()    { printf '  \033[33m!\033[0m %s\n' "$*"; }
miss()    { printf '  \033[31m✗\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }
section() { printf '\n== %s ==\n' "$*"; }

section "1. 스타터킷 기본 골격 파일 존재"
PATHS=(
  CLAUDE.md ROADMAP.md SETUP.md
  CHECKLIST.md README.md
  # DEVLOG.md·HISTORY.md·SHARE.md 는 프로젝트별 작업 일지 — gitignore 로 로컬 전용이라 골격 필수에서 제외
  docs/PRIVACY.md docs/RELEASE.md
  rules/behavior.md rules/boundaries.md rules/architecture.md
  rules/commands.md rules/domain.md rules/ui.md rules/ux.md
  rules/methodology/README.md rules/methodology/templates.md rules/methodology/indexing.md
  rules/methodology/designspec.md rules/methodology/change-management.md
  prototype/_template.designspec.html prototype/build-all.sh prototype/build-pdf.sh
  prototype/화면설계서-가이드.md prototype/README.md
  scripts/release-cut.sh scripts/new-domain.sh
  .claude/skills/release-cut/SKILL.md
  .claude/skills/designspec-version-update/SKILL.md
  .claude/skills/spec-self-review/SKILL.md
  .claude/skills/spec-verify-loop/SKILL.md
  .claude/workflows/spec-verify-loop.js
  docs/README.md
  docs/PRD.md docs/glossary.md docs/personas.md
  docs/REQ.md docs/INDEX.md docs/_labels.md docs/IA.md
  docs/flows/FLOW-001.md
  docs/POL.md
  docs/screens/SCR-001.md
  docs/TC.md
)
for p in "${PATHS[@]}"; do
  if [ -e "$p" ] || [ -L "$p" ]; then ok "$p"; else miss "$p"; fi
done

section "2. 자동 로드 체인 (CLAUDE.md → behavior.md → methodology)"
grep -q '@rules/behavior.md'   CLAUDE.md && ok 'CLAUDE.md @rules/behavior.md'   || miss 'CLAUDE.md @rules/behavior.md 누락'
grep -q '@rules/boundaries.md' CLAUDE.md && ok 'CLAUDE.md @rules/boundaries.md' || miss 'CLAUDE.md @rules/boundaries.md 누락'
grep -q 'rules/methodology'    CLAUDE.md && ok 'CLAUDE.md → rules/methodology'  || miss 'CLAUDE.md → rules/methodology 누락'

section "3. 진입점 배치 (본체 CLAUDE.md · 선택 심링크 AGENTS.md)"
if [ -L CLAUDE.md ]; then
  miss 'CLAUDE.md 가 심링크 — 구버전 배치. CLAUDE.md 를 본체 파일로 전환하라'
elif [ ! -e AGENTS.md ]; then
  ok 'CLAUDE.md 본체 (AGENTS.md 없음 — Claude 전용, 정상)'
elif [ -L AGENTS.md ] && [ "$(readlink AGENTS.md)" = 'CLAUDE.md' ]; then
  ok 'CLAUDE.md 본체 + AGENTS.md -> CLAUDE.md (병용 구성)'
else
  miss 'AGENTS.md 가 CLAUDE.md 를 가리키지 않음 — `ln -sf CLAUDE.md AGENTS.md` 로 정리하라'
fi

section "4. methodology 내부 상호 링크"
grep -qF '[templates.md](./templates.md)' rules/methodology/README.md     && ok 'README → templates' || miss 'README → templates 끊김'
grep -qF '[README.md](./README.md)'       rules/methodology/templates.md  && ok 'templates → README' || miss 'templates → README 끊김'
grep -qF 'indexing.md'                    rules/methodology/README.md     && ok 'README → indexing' || miss 'README → indexing 끊김'
grep -qF 'designspec.md'                  rules/methodology/README.md     && ok 'README → designspec' || miss 'README → designspec 끊김'
grep -qF 'change-management.md'           rules/methodology/README.md     && ok 'README → change-management' || miss 'README → change-management 끊김'

section "5. (TODO) 플레이스홀더 잔여 — Phase 1 채움 진행 신호"
TODO_LINES=$(grep -rE '\(TODO' CLAUDE.md rules/ docs/ ROADMAP.md 2>/dev/null | wc -l | tr -d ' ')
TODO_FILES=$(grep -rlE '\(TODO' CLAUDE.md rules/ docs/ ROADMAP.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$TODO_LINES" -gt 0 ]; then
  warn "TODO 잔여 — ${TODO_FILES}개 파일, ${TODO_LINES}개 줄 (Phase 1 진행 중이면 정상. 모두 채워지면 ✓ 로 바뀜)"
else
  ok 'TODO 잔여 없음 — Phase 1 완료 신호'
fi

# ============================================================
# 6. 인덱스 정합성 (rules/methodology/indexing.md 기반)
# ============================================================
# 본문 ID 추출 정규식:
#   - 단일 prefix: REQ-001 / POL-007 / SCR-013 / TC-022 / FLOW-001
#   - 도메인 prefix: REQ-AUTH-0001 / POL-PAY-0007
# 본문에서는 '### REQ-XXX' 헤더 또는 표 첫 칸에서 추출
# INDEX.md 에서는 '| REQ-XXX |' 형태에서 추출
section "6. 인덱스 정합성"

# 임시 작업 파일 (mktemp 없는 환경 대비 변수로 캡쳐)
extract_ids() {
  # $1: 정규식 prefix(REQ|POL|SCR|TC|FLOW), $2..: 파일들
  # 본문에서 ### 헤더 형식의 ID 만 단일 진실로 인정 (표는 사람 요약용)
  local prefix="$1"; shift
  strip_code_blocks "$@" \
    | grep -hoE "^### ${prefix}-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4}" \
    | sed 's/^### //' \
    | sort -u
}

# INDEX.md 등에서는 표 첫 칸의 ID 가 단일 진실
extract_index_ids() {
  local prefix="$1"; shift
  strip_code_blocks "$@" \
    | grep -hoE "^\| ${prefix}-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4} " \
    | grep -oE "${prefix}-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4}" \
    | sort -u
}

# 모든 ID 위치 (표 첫 칸 + ### 헤더) — 추적 끊김 검사용
extract_all_ids() {
  local prefix="$1"; shift
  strip_code_blocks "$@" \
    | grep -hoE "${prefix}-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4}" \
    | sort -u
}

# 코드블록 ``` ... ``` 안의 내용을 제거 (예시 ID 가 검사에 잡히지 않도록)
strip_code_blocks() {
  awk 'BEGIN{inblock=0} /^```/{inblock=!inblock; next} !inblock{print}' "$@" 2>/dev/null
}

# 6-1. 본문 REQ 와 INDEX.md REQ 집합 비교
if [ -f docs/REQ.md ] && [ -f docs/INDEX.md ]; then
  # 본문 ID 는 ### 헤더에서만 추출 (표는 사람용 요약, 단일 진실은 헤더)
  REQ_BODY_FILES=(docs/REQ.md)
  while IFS= read -r f; do
    [ -n "$f" ] && [ "$(basename "$f")" != "_template.md" ] && REQ_BODY_FILES+=("$f")
  done < <(find docs/domains -name 'REQ*.md' 2>/dev/null)

  BODY_REQ=$(extract_ids REQ "${REQ_BODY_FILES[@]}" 2>/dev/null)
  INDEX_REQ=$(extract_index_ids REQ docs/INDEX.md 2>/dev/null)

  # 본문에 있는데 인덱스에 없는 ID
  MISSING_IN_INDEX=$(comm -23 <(echo "$BODY_REQ") <(echo "$INDEX_REQ") | grep -v '^$' || true)
  # 인덱스에 있는데 본문에 없는 ID
  MISSING_IN_BODY=$(comm -13 <(echo "$BODY_REQ") <(echo "$INDEX_REQ") | grep -v '^$' || true)

  if [ -z "$MISSING_IN_INDEX" ] && [ -z "$MISSING_IN_BODY" ]; then
    ok 'REQ 본문 ↔ INDEX.md 동기화'
  else
    [ -n "$MISSING_IN_INDEX" ] && miss "INDEX.md 에 누락된 REQ ID: $(echo $MISSING_IN_INDEX | tr '\n' ' ')"
    [ -n "$MISSING_IN_BODY" ]  && miss "본문에 없는데 INDEX.md 에만 있는 REQ ID: $(echo $MISSING_IN_BODY | tr '\n' ' ')"
  fi
else
  warn 'REQ.md 또는 INDEX.md 누락 — 동기화 검사 스킵'
fi

# 6-2. 중복 ID — ### 헤더가 같은 ID 로 두 번 이상 (단일 진실 위반)
check_duplicates() {
  local prefix="$1"; shift
  local files=("$@")
  local dups
  dups=$(strip_code_blocks "${files[@]}" \
    | grep -hoE "^### ${prefix}-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4}" \
    | sed 's/^### //' \
    | sort | uniq -d)
  if [ -n "$dups" ]; then
    miss "$prefix 중복 ID: $(echo $dups | tr '\n' ' ')"
  else
    ok "$prefix 중복 ID 없음"
  fi
}

REQ_FILES=(docs/REQ.md)
[ -d docs/domains ] && while IFS= read -r f; do
  [ -n "$f" ] && [ "$(basename "$f")" != "_template.md" ] && REQ_FILES+=("$f")
done < <(find docs/domains -name 'REQ*.md' 2>/dev/null)
check_duplicates REQ "${REQ_FILES[@]}"

POL_FILES=(docs/POL.md)
[ -d docs/domains ] && while IFS= read -r f; do POL_FILES+=("$f"); done < <(find docs/domains -name 'POL*.md' 2>/dev/null)
check_duplicates POL "${POL_FILES[@]}"

SCR_FILES=()
[ -d docs/screens ] && while IFS= read -r f; do SCR_FILES+=("$f"); done < <(find docs/screens -name 'SCR*.md' 2>/dev/null)
[ -d docs/domains ] && while IFS= read -r f; do SCR_FILES+=("$f"); done < <(find docs/domains -name 'SCR*.md' 2>/dev/null)
if [ ${#SCR_FILES[@]} -gt 0 ]; then check_duplicates SCR "${SCR_FILES[@]}"; else warn 'SCR 파일 없음'; fi

TC_FILES=(docs/TC.md)
[ -d docs/domains ] && while IFS= read -r f; do TC_FILES+=("$f"); done < <(find docs/domains -name 'TC*.md' 2>/dev/null)
check_duplicates TC "${TC_FILES[@]}"

# 6-3. ID 포맷 (예외: 임시·잘못된 prefix 검출)
# 허용되지 않는 패턴 예: REQ-TEMP-1, REQ-abc-001(소문자), REQ-01(자릿수 부족)
# 코드블록은 예시 ID 가 들어 있을 수 있어 제외
BAD_FMT=$(strip_code_blocks "${REQ_FILES[@]}" "${POL_FILES[@]}" ${SCR_FILES[@]+"${SCR_FILES[@]}"} "${TC_FILES[@]}" 2>/dev/null \
  | grep -hoE '\b(REQ|POL|SCR|TC|FLOW)-[A-Za-z0-9_-]+' \
  | grep -vE '^(REQ|POL|SCR|TC|FLOW)-([A-Z][A-Z0-9]{1,5}-){0,2}[0-9]{3,4}$' \
  | grep -vE '^(REQ|POL|SCR|TC|FLOW)-###$' \
  | sort -u || true)
if [ -n "$BAD_FMT" ]; then
  warn "ID 포맷 규칙 위반 의심: $(echo $BAD_FMT | tr '\n' ' ') (REQ-### 또는 REQ-{DOMAIN}-####)"
else
  ok 'ID 포맷 규칙 통과'
fi

# 6-4. 추적 끊김 (TC → REQ)
# TC.md 의 '대상 REQ' 컬럼에 적힌 REQ ID 가 본문에 실제로 존재하는지
if [ -f docs/TC.md ]; then
  TC_REFS=$(strip_code_blocks "${TC_FILES[@]}" \
    | grep -hoE 'REQ-([A-Z][A-Z0-9]{0,5}-){0,2}[0-9]{3,4}' \
    | sort -u)
  BODY_REQ_SET=${BODY_REQ:-$(extract_ids REQ "${REQ_FILES[@]}" 2>/dev/null)}
  ORPHANS=$(comm -23 <(echo "$TC_REFS") <(echo "$BODY_REQ_SET") | grep -v '^$' | grep -v '^REQ-###$' || true)
  if [ -z "$ORPHANS" ]; then
    ok 'TC → REQ 추적 끊김 없음'
  else
    miss "TC 가 가리키는 미존재 REQ: $(echo $ORPHANS | tr '\n' ' ')"
  fi
fi

# 6-5. REQ → TC 누락 (모든 REQ 는 최소 1개 TC 와 연결되어야 함)
if [ -n "${BODY_REQ:-}" ]; then
  MISSING_TC=""
  for rid in $BODY_REQ; do
    # 예시(REQ-###) 무시
    [ "$rid" = "REQ-###" ] && continue
    if ! grep -q "$rid" "${TC_FILES[@]}" 2>/dev/null; then
      MISSING_TC="$MISSING_TC $rid"
    fi
  done
  if [ -z "$MISSING_TC" ]; then
    ok 'REQ → TC 연결 누락 없음'
  else
    warn "TC 연결이 없는 REQ:$MISSING_TC (마감 전 채움)"
  fi
fi

section "7. 프로젝트별 1초 검증 (TODO — rules/commands.md 채운 뒤 여기 호출 추가)"
# 본 프로젝트의 빌드·테스트 명령을 여기에 추가한다. 예시:
#   - npm test  /  pytest -q  /  go test ./...
#   - cargo test  /  swift test --package-path Core
# 그리고 외부 통신 0건 가드(TC-103)도 함께. 채워지면 위 warn 을 ok 로 바꾼다.
warn '아직 미정 — `rules/commands.md` 에 빌드·테스트 명령 채우고 이 섹션에 호출 추가'

# ============================================================
# 8. 화면설계서(designspec) 버전 정합 — 형상 관리 가드 (절차 B)
#    rules/methodology/change-management.md / scripts/release-cut.sh 와 짝.
#    - 버전 라벨 정합: 라이브 커버 버전과 다른 버전이 푸터에 섞여 있지 않나(블랭킷 치환 누락/과다)
#    - .baseline 무결성: .baseline 소스 == 자기 커버 버전 동결 스냅샷(_vX.Y.html) md5 일치
#    실제 designspec 이 없으면(_template 만 있는 킷 초기 상태) 통째로 스킵.
# ============================================================
md5of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | awk '{print $1}'; }
DS_LIVE=()
while IFS= read -r f; do DS_LIVE+=("$f"); done < <(
  find prototype -name '*.designspec.html' ! -path '*/.baseline/*' ! -name '_template.designspec.html' 2>/dev/null | sort)

if [ ${#DS_LIVE[@]} -gt 0 ]; then
  section "8. 화면설계서 버전 정합 (형상 관리)"
  for live in "${DS_LIVE[@]}"; do
    base="$(basename "$live")"; dir="$(dirname "$live")"
    label="${base%% *}"   # 예: [USER]
    cover_ver=$(grep -oE '<b>Version\.</b> v[0-9]+\.[0-9]+' "$live" | grep -oE 'v[0-9]+\.[0-9]+' | head -1)
    if [ -z "$cover_ver" ]; then warn "$base — 커버 버전(<b>Version.</b> vX.Y) 미검출"; continue; fi

    # 8-1. 푸터 버전 라벨이 커버와 일치하나 (status 칩 `vX · 개정` 은 형식이 달라 무관)
    other=$(grep -oE '화면설계서 v[0-9]+\.[0-9]+ ' "$live" | grep -oE 'v[0-9]+\.[0-9]+' | sort -u | grep -vx "$cover_ver" || true)
    if [ -z "$other" ]; then
      ok "$base — 버전 라벨 정합 ($cover_ver, 푸터 일치)"
    else
      miss "$base — 푸터에 커버($cover_ver)와 다른 버전 라벨: $(echo $other | tr '\n' ' ') (블랭킷 치환 누락/과다 의심)"
    fi

    # 8-2. .baseline 무결성 — baseline 소스가 자기 커버 버전 동결본과 일치하나
    bfile="$dir/../.baseline/$base"
    if [ -f "$bfile" ]; then
      bver=$(grep -oE '<b>Version\.</b> v[0-9]+\.[0-9]+' "$bfile" | grep -oE 'v[0-9]+\.[0-9]+' | head -1)
      frozen="$dir/${base%.designspec.html}_${bver}.html"
      if [ -n "$bver" ] && [ -f "$frozen" ]; then
        if [ "$(md5of "$bfile")" = "$(md5of "$frozen")" ]; then
          ok "$label .baseline 무결 ($bver 동결본과 md5 일치)"
        else
          miss "$label .baseline 가 $bver 동결본과 불일치(stale) — release-cut.sh 로 복구"
        fi
      else
        warn "$label .baseline 버전($bver) 동결본 없음 — 비교 스킵"
      fi
    else
      warn "$label .baseline 소스 없음 — 배포 후 release-cut.sh 가 생성"
    fi
  done
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf '\033[32mALL GREEN\033[0m  (warning 은 Phase 0/1 진행 신호일 수 있음)\n'
  exit 0
else
  printf '\033[31mFAILED — %d 항목 실패\033[0m\n' "$FAIL"
  exit 1
fi
