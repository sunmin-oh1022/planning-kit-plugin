#!/usr/bin/env bash
# release-cut.sh — 절차 B (배포 후 다음 버전 라인 개시) 자동화.
# rules/methodology/change-management.md 의 '절차 B' 를 그대로 실행한다.
#
# 사용:  bash scripts/release-cut.sh <DOMAIN> <from> <to>
#   예:  bash scripts/release-cut.sh USER v0.2 v0.3
#        bash scripts/release-cut.sh ADMIN v0.2 v0.3
#   - DOMAIN : 파일명 대괄호 안 라벨 (USER, ADMIN …)
#   - from   : 동결할 배포 버전 (vX.Y)
#   - to     : 새로 열 작업 버전 (vX.Z)
#
# 하는 일 (절차 B):
#   1. 배포본 동결 검증 — 라이브 designspec == _{from}.html (md5)
#   2. .baseline 무결성 복구 — .baseline/ 소스 ← _{from}.html
#   3. 다음 버전 라인 개시 — 프로토타입 _{from}→_{to} 복사(자기 푸터만), designspec 3종 라벨만 치환
#   4. grep 검증 — 라이브 잔존 {from} = 상태 칩 + 역사 기록만인지 보고
# 동결본(_{from}.html / _{from}.pdf)은 어느 단계에서도 건드리지 않는다.
#
# ★ 블랭킷 치환 금지: 버전 라벨은 '커버 칩·푸터 토큰·프로토타입 참조' 3종만 올린다.
#   상태 칩 `{from} · 개정`, 인라인 역사 기록 `…(from)`, 파생 출처 주석, 개정 이력 표는 보존(기획자 관리).

set -uo pipefail
cd "$(dirname "$0")/.."

D="${1:-}"; FROM="${2:-}"; TO="${3:-}"
if [ -z "$D" ] || [ -z "$FROM" ] || [ -z "$TO" ]; then
  echo "사용: bash scripts/release-cut.sh <DOMAIN> <from> <to>   (예: USER v0.2 v0.3)"; exit 2
fi

# BSD(macOS) / GNU sed in-place 호환
if sed --version >/dev/null 2>&1; then SEDI=(-i); else SEDI=(-i ''); fi
md5of(){ md5 -q "$1" 2>/dev/null || md5sum "$1" | awk '{print $1}'; }

# --- 경로 탐색 ---
# 주의: macOS는 한글 파일명을 NFC/NFD 어느 쪽으로도 저장한다. bash 의 `=` 문자열 비교는
# 정규화에 민감해 실패할 수 있으므로, 도메인은 ASCII 접두사 `[$D] ` glob 으로만 매칭한다
# (find 가 이미 live designspec 으로 한정 → 접두사로 충분). 한글 부분은 와일드카드로 흡수.
# 이후 파일 연산(cp·[ -f ]·sed -i)은 macOS 가 정규화를 무시하므로 안전하다.
LIVE=""
while IFS= read -r f; do
  case "$(basename "$f")" in "[$D] "*) LIVE="$f"; break ;; esac
done < <(find prototype -name '*.designspec.html' ! -path '*/.baseline/*' ! -name '_template.designspec.html')
[ -n "$LIVE" ] || { echo "✗ 라이브 designspec 없음: [$D] *.designspec.html"; exit 1; }

DIR="$(dirname "$LIVE")"
BN="$(basename "$LIVE")"; STEM="${BN%.designspec.html}"   # 실제 디스크 정규화 보존
FROZEN="$DIR/${STEM}_${FROM}.html"
PROTO_FROM="$DIR/[$D] 프로토타입_${FROM}.html"
PROTO_TO="$DIR/[$D] 프로토타입_${TO}.html"
BASE="prototype/.baseline/$BN"

echo "== release-cut: $D  $FROM → $TO =="
echo "   라이브: $LIVE"

# --- 1. 배포본 동결 검증 ---
[ -f "$FROZEN" ] || { echo "✗ 1. 동결본 없음: $FROZEN — $FROM 이 배포·동결됐는지 확인"; exit 1; }
if [ "$(md5of "$LIVE")" = "$(md5of "$FROZEN")" ]; then
  echo "✓ 1. 동결 검증: 라이브 == $(basename "$FROZEN") (md5 일치)"
else
  echo "✗ 1. 라이브 ≠ 동결본 — 배포 스냅샷 누락이거나 라이브가 이미 수정됨."
  echo "      $FROM 배포 후 작업이 라이브에 섞였다면 그건 $TO 라인 것 — 기획자와 먼저 정리하세요."
  exit 1
fi

# --- 2. .baseline 무결성 복구 ---
if [ -e "$BASE" ]; then cp "$FROZEN" "$BASE"; else
  echo "! 2. .baseline 파일 없음 — 생성: $BASE"; cp "$FROZEN" "$BASE"
fi
if [ "$(md5of "$BASE")" = "$(md5of "$FROZEN")" ]; then
  echo "✓ 2. .baseline 갱신: ← $(basename "$FROZEN") (md5 일치)"
else
  echo "✗ 2. .baseline 복사 실패"; exit 1
fi

# --- 3a. 프로토타입 다음 버전 개시 (자기 버전 푸터만; 파생 출처 주석 보존) ---
if [ ! -f "$PROTO_FROM" ]; then
  echo "! 3a. 프로토타입 $(basename "$PROTO_FROM") 없음 — 스킵"
elif [ -e "$PROTO_TO" ]; then
  echo "! 3a. $(basename "$PROTO_TO") 이미 존재 — 덮어쓰지 않음(스킵)"
else
  cp "$PROTO_FROM" "$PROTO_TO"
  sed "${SEDI[@]}" \
    -e "s|\[$D\] 프로토타입_${FROM}\.html|[$D] 프로토타입_${TO}.html|g" \
    -e "s|\[$D\] 화면설계서_${FROM}\.pdf|[$D] 화면설계서_${TO}.pdf|g" \
    -e "s|(${FROM})|(${TO})|g" \
    "$PROTO_TO"
  echo "✓ 3a. 프로토타입 개시: $(basename "$PROTO_TO")"
fi

# --- 3b. 라이브 designspec 3종 라벨만 치환 ---
sed "${SEDI[@]}" \
  -e "s|<b>Version.</b> ${FROM}|<b>Version.</b> ${TO}|g" \
  -e "s|\[$D\] 화면설계서 ${FROM} |[$D] 화면설계서 ${TO} |g" \
  -e "s|프로토타입_${FROM}\.html|프로토타입_${TO}.html|g" \
  "$LIVE"
echo "✓ 3b. 라이브 designspec 라벨 치환 (커버 칩·푸터 토큰·프로토타입 참조)"

# --- 4. grep 검증: 잔존 FROM = 상태 칩 + 역사 기록만 ---
echo ""
echo "== 4. 치환 후 검증 =="
RESID="$(grep -nF "$FROM" "$LIVE" || true)"
RESID_N="$(printf '%s' "$RESID" | grep -c . || true)"
CHIP_N="$(printf '%s' "$RESID" | grep -c "chip\">$FROM" || true)"
TO_N="$(grep -cF "$TO" "$LIVE" || true)"
echo "   라이브 $TO 라벨: ${TO_N}곳"
echo "   라이브 잔존 $FROM: ${RESID_N}곳 (그중 상태 칩 ${CHIP_N}곳)"
if [ "${RESID_N:-0}" -gt 0 ]; then
  echo "   ── 잔존 목록 — '상태 칩 · 개정' 또는 인라인 역사 기록인지 육안 확인 ──"
  printf '%s\n' "$RESID" | sed 's/^/     /'
fi

echo ""
echo "✓ 완료 — $D $FROM → $TO 라인 개시. 동결본 $(basename "$FROZEN") 은 불변 보존."
echo "  남은 일(기획자 직접): 개정 이력 표 행 추가 · 실제 개정 화면의 상태 칩 · 푸터 날짜·PDF 빌드(bash prototype/build-all.sh $TO)."
