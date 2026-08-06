#!/usr/bin/env bash
# new-domain.sh — 새 도메인 화면설계서를 템플릿에서 한 줄로 생성한다.
# _template.designspec.html 을 복사하고 {DOMAIN}·{도메인} placeholder 를 치환한다.
# (프로젝트 전역 placeholder {프로젝트명}·{영문명}·{YYYY-MM-DD} 등과 화면별 {화면명}·{해시}·
#  SCR-{DOMAIN}-00X 는 그대로 둔다 — 사람이 docs 기준으로 채운다.)
#
# 사용:  bash scripts/new-domain.sh <DOMAIN> <도메인 한글명> [폴더명]
#   예:  bash scripts/new-domain.sh USER 사용자콘솔
#        bash scripts/new-domain.sh ADMIN 관리자콘솔 admin
#   - DOMAIN      : 파일명/ID 라벨 (대문자 ASCII 권장 — [USER], SCR-USER-001)
#   - 도메인 한글명 : IA 페이지 등에 들어갈 한글 이름 ({도메인} 치환)
#   - 폴더명       : prototype/ 아래 작업 폴더 (생략 시 DOMAIN 소문자)

set -uo pipefail
cd "$(dirname "$0")/.."

D="${1:-}"; KO="${2:-}"; FOLDER="${3:-}"
if [ -z "$D" ] || [ -z "$KO" ]; then
  echo "사용: bash scripts/new-domain.sh <DOMAIN> <도메인 한글명> [폴더명]   (예: USER 사용자콘솔)"; exit 2
fi
[ -n "$FOLDER" ] || FOLDER="$(printf '%s' "$D" | tr '[:upper:]' '[:lower:]')"

TPL="prototype/_template.designspec.html"
[ -f "$TPL" ] || { echo "✗ 템플릿 없음: $TPL"; exit 1; }

DIR="prototype/$FOLDER"
OUT="$DIR/[$D] 화면설계서.designspec.html"
if [ -e "$OUT" ]; then echo "! 이미 존재 — 덮어쓰지 않음: $OUT"; exit 1; fi

# BSD(macOS) / GNU sed in-place 호환
if sed --version >/dev/null 2>&1; then SEDI=(-i); else SEDI=(-i ''); fi

mkdir -p "$DIR"
cp "$TPL" "$OUT"
sed "${SEDI[@]}" -e "s|{DOMAIN}|$D|g" -e "s|{도메인}|$KO|g" "$OUT"

echo "✓ 생성: $OUT"
echo "  ({DOMAIN}→$D, {도메인}→$KO 치환 완료)"

# 남은 placeholder 안내 (프로젝트 전역 + 화면별 — 사람이 채움)
# CSS/JS 중괄호({ prop:val; } 류)는 :;#(= 문자를 포함 → 제외. 진짜 placeholder만 남긴다.
LEFT=$(grep -oE '\{[^}]+\}' "$OUT" | grep -vE '[:;#(=]' | sort -u | grep -v '^$' || true)
if [ -n "$LEFT" ]; then
  echo ""
  echo "── 채워야 할 placeholder (docs 기준) ──"
  printf '%s\n' "$LEFT" | sed 's/^/   /'
fi
echo ""
echo "다음:"
echo "  1) 위 placeholder 를 docs/PRD·glossary·SCR 기준으로 채운다 (VS Code)."
echo "  2) 화면 섹션(.page 2개씩)을 '화면 페이지를 여기에 추가' 주석 위치에 넣는다."
echo "  3) PDF: bash prototype/build-all.sh   ·   정합성: bash scripts/check-docs.sh (§8)"
