#!/bin/bash
# 모든 화면설계서(*화면설계서.designspec.html)를 PDF로 한 번에 빌드한다.
# (_template.designspec.html 은 제외 — 이름이 다름. 프로토타입은 빌드 불필요.)
#
# 사용:
#   bash prototype/build-all.sh           # 전부 → *_v0.1.pdf
#   bash prototype/build-all.sh v0.2      # 전부 → *_v0.2.pdf (버전 올릴 때)
HERE="$(cd "$(dirname "$0")" && pwd)"
VER="${1:-v0.1}"
echo "== 화면설계서 일괄 빌드 (버전 $VER) =="
found=0
# 한글 파일명 정규화(NFC/NFD) 이슈 회피: '*.designspec.html'로 찾고 _template만 제외
while IFS= read -r src; do
  case "$(basename "$src")" in _template.designspec.html) continue ;; esac
  found=1
  base="$(basename "$src")"
  name="${base%.designspec.html}"                 # 예: [USER] 화면설계서
  out="$(dirname "$src")/${name}_${VER}.pdf"
  echo "▶ ${name}_${VER}.pdf"
  bash "$HERE/build-pdf.sh" "$src" "$out" 2>&1 | sed 's/^/   /'
done < <(find "$HERE" -name '*.designspec.html' | sort)
if [ "$found" = 1 ]; then echo "✓ 완료"; else echo "designspec 파일을 찾지 못했습니다"; fi
