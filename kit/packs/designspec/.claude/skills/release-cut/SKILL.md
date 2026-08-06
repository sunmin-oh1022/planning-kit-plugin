---
name: release-cut
description: 배포한 화면설계서 버전을 불변 동결하고 다음 버전 라인을 개시하는 절차 B — 형상 관리 전용. "vX.Y 배포했고 오늘부터 vX.Z로", "버전 라인 새로 열어줘" 류 요청에 사용. docs 동기화는 하지 않는다(그건 designspec-version-update 스킬).
---

# release-cut — 배포 후 다음 버전 라인 개시 (절차 B)

> 단일 진실: `rules/methodology/change-management.md` **절차 B**.
> 배포한 vX.Y는 **불변 동결**, 오늘부터의 작업은 vX.Z 라인에 쌓이도록 분기한다. **docs 동기화(절차 A)와 무관.**

## 언제
화면설계서/프로토타입을 배포한 뒤 다음 작업 버전을 열 때. 새 요건·정책을 docs에 반영해야 한다면 → `designspec-version-update`.

## 절차
1. **컷 직전 정합성 스윕** — `check-docs.sh` + 개정이력↔목업 + PC↔모바일 대조. 드리프트를 다음 라인으로 넘기지 않는다.
2. **배포본 동결 검증** — 라이브 `[DOMAIN] 화면설계서.designspec.html` 와 동결본 `_vX.Y.html` 가 **바이트 동일(md5)** 인지 확인. 다르면 배포 시점 스냅샷 누락 → 기획자에게 확인.
3. **`.baseline/` 무결성 복구** — `.baseline/[DOMAIN] 화면설계서.designspec.html` 를 배포 `_vX.Y.html` 로 갱신(md5 일치 검증). **베이스라인 소스는 배포 PDF와 항상 일치**해야 한다(자주 stale됨).
4. **다음 버전 라인 개시** — `bash scripts/release-cut.sh <DOMAIN> <from> <to>`
   - 프로토타입: `_vX.Y.html` → `_vX.Z.html` 복사, **자기 버전 푸터만** vX.Z로(파생 출처 주석은 보존).
   - 라이브 designspec: 버전 라벨을 vX.Z로 — **아래 치환 규칙 엄수**.
5. **동결본 불변** — `_vX.Y.html` · `_vX.Y.pdf` 는 어느 단계에서도 건드리지 않는다. PDF 빌드와 푸터 날짜는 vX.Z 내용 확정 후.

## ⚠️ 버전 라벨 치환 규칙 (블랭킷 치환 금지)
`sed s/vX.Y/vX.Z/g` 로 일괄 치환하면 역사 기록·화면 상태가 깨진다. **딱 3종만** 올린다:
- ✅ 커버 버전 칩 `<b>Version.</b> vX.Y`
- ✅ 페이지 푸터 버전 토큰 `[DOMAIN] 화면설계서 vX.Y ` (※ 푸터 **날짜는 그대로** — 빌드 시 갱신)
- ✅ 프로토타입 참조 `프로토타입_vX.Y.html`

**보존(절대 자동 변경 금지):**
- 🔒 화면 상태 칩 `vX.Y · 개정` — 화면별 *마지막 개정 버전*. 실제 개정한 화면만 기획자가 올린다.
- 🔒 인라인 변경 기록 `…추가(vX.Y)` — 그 버전에 일어난 사실.
- 🔒 파생 출처 주석.
- 🔒 개정 이력 표 행 — 기획자 직접 관리.

치환 후 **남은 `vX.Y` 수 = 상태 칩 + 역사 기록 수** 와 일치하는지 `grep` 으로 검증한다.

## 완료 체크리스트
> ⚠️ **체크리스트 SSOT = `rules/methodology/change-management.md`. 본 스킬의 체크리스트는 미러다 — 바꿀 때 둘 다 고친다.**

- [ ] 컷 직전 정합성 스윕 완료(check-docs · 개정이력↔목업 · PC↔모바일)
- [ ] 라이브 == 동결본 `_vX.Y.html` md5 일치(배포 무결) 확인
- [ ] `.baseline/` 소스 = 배포본으로 갱신(md5 일치)
- [ ] 다음 버전 프로토타입 `_vX.Z.html` 개시(자기 버전 푸터만)
- [ ] designspec 버전 라벨 3종만 vX.Z (상태 칩·역사 기록·개정 이력 보존, grep 검증)
- [ ] 동결본 `_vX.Y.*` 무변경
