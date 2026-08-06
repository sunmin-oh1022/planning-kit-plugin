#!/bin/bash
# 화면설계서 PDF 빌드 — 페이지별 콘텐츠 높이에 맞춰 렌더(가로 297mm 고정, 세로 자동 확장).
# A4 높이에 욱여넣지 않는다. 페이지마다 높이를 측정해 정적 @page 크기로 단독 렌더 후 합친다.
# 사용:
#   prototype/build-pdf.sh                          # 기본: [USER] 화면설계서_v0.1.pdf
#   prototype/build-pdf.sh "<소스.designspec.html>" "<출력.pdf>"
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-$HERE/console/[USER] 화면설계서.designspec.html}"
OUT="${2:-$HERE/console/[USER] 화면설계서_v0.1.pdf}"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cd "$(dirname "$SRC")"; SRCB="$(basename "$SRC")"; OUTB="$(basename "$OUT")"

# 1) 페이지별 콘텐츠 높이(px) 측정 — 가로 1122px(=297mm) 기준
perl -0pe 's#</body>#<script>addEventListener("load",function(){document.querySelectorAll(".page").forEach(function(p){p.setAttribute("data-h",Math.round(p.getBoundingClientRect().height))})})</script></body>#' "$SRCB" > _meas.html
heights=$("$CHROME" --headless --disable-gpu --virtual-time-budget=2000 --window-size=1122,800 --dump-dom _meas.html 2>/dev/null | grep -oE 'data-h="[0-9]+"' | grep -oE '[0-9]+')
rm -f _meas.html
N=$(printf '%s\n' "$heights" | grep -c .)
echo "pages: $N"

# 2) 페이지별 정적 @page 크기로 단독 렌더 (다른 페이지 숨김)
i=0; parts=()
for h in $heights; do
  i=$((i+1))
  hmm=$(python3 -c "print(round($h/96*25.4 + 0.4, 1))")   # px→mm + 0.4mm 안전여유 (풀블리드 커버 흰선 방지)
  style="<style>.page:not(:nth-of-type($i)){display:none} body{background:#fff} .page{box-shadow:none!important;margin:0!important} @page{size:297mm ${hmm}mm;margin:0}</style>"
  sed "s|</head>|${style}</head>|" "$SRCB" > "_r$i.html"
  "$CHROME" --headless --disable-gpu --no-pdf-header-footer --virtual-time-budget=1500 --print-to-pdf="_p$i.pdf" "_r$i.html" 2>/dev/null
  rm -f "_r$i.html"; parts+=("_p$i.pdf")
done

# 3) 합치기 (PDFKit) + 페이지 크기 검증 출력
cat > _merge.swift <<'SWIFT'
import PDFKit
import Foundation
let out = PDFDocument()
for path in CommandLine.arguments.dropFirst(2) {
  guard let d = PDFDocument(url: URL(fileURLWithPath: path)) else { continue }
  for i in 0..<d.pageCount { out.insert(d.page(at: i)!, at: out.pageCount) }
}
out.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
let chk = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1]))!
for i in 0..<chk.pageCount { let r = chk.page(at: i)!.bounds(for: .mediaBox); print(String(format: "  p%d: %.0f x %.0fmm", i+1, r.width/72*25.4, r.height/72*25.4)) }
print("merged \(chk.pageCount) pages")
SWIFT
swift _merge.swift "$OUTB" "${parts[@]}"
rm -f _p*.pdf _merge.swift
echo "done: $OUT"
