---
name: designspec-version-update
description: 업데이트된 프로토타입을 근거로 화면설계서 버전을 올리는 절차 A — docs(SSOT)를 먼저 동기화한 뒤 화면설계서를 파생하고 PDF를 빌드한다. "화면설계서 버전 업데이트", "프로토타입 바뀐 거 설계서에 반영", "용어/정책 바뀐 거 화면설계서까지" 류 요청에 사용. 새 요건·정책·용어가 docs에 반영되어야 할 때 쓴다. 단순히 배포 후 다음 버전 라인만 여는 형상 관리는 release-cut 스킬.
---

# designspec-version-update — 화면설계서 버전 업데이트 (절차 A)

> 단일 진실: `rules/methodology/change-management.md` **절차 A**.
> 핵심 규칙: 변경은 항상 **프로토타입 → docs → 화면설계서** 순서로 흐른다. 프로토타입에서 화면설계서로 바로 가지 않는다. docs가 SSOT, 화면설계서는 파생물.

## 언제
프로토타입을 vX.Y로 다듬으며 새로 정리된 **요건·용어·규칙·정책**을 화면설계서까지 반영해야 할 때. (버전 라벨만 분기하는 형상 관리는 → `release-cut`.)

## 절차
1. **docs 먼저 동기화** — 프로토타입에서 추가/구체화/변경된 요건·용어·규칙을 docs에 반영. 5대 원리 준수.
   - 용어 일괄 치환은 `glossary`·`_labels` 기준.
   - 정책 → `POL`, 요건 → **기존 REQ 본문 보강**(신규 REQ ID 남발 금지), 화면 구조 → `IA`·`SCR`, 흐름 → `FLOW`, 용어 → `glossary`.
2. **정합성 검증** — `bash scripts/check-docs.sh` ALL GREEN(종료코드 0). REQ↔INDEX·TC 추적 끊기면 고치고 재검증.
3. **갱신된 docs 분석** — 바뀐 REQ/IA/POL/SCR/glossary를 근거로 화면설계서 변경점(화면별 mockup·정의·IA·권한표·용어)을 도출.
4. **화면설계서 갱신 → PDF 빌드** — docs를 단일 진실로 designspec의 mockup·정의·IA·권한표·용어를 갱신하고 `bash prototype/build-all.sh vX.Y` 로 PDF 생성. 제작 컨벤션은 `rules/methodology/designspec.md` / `prototype/화면설계서-가이드.md`.
5. **버전·개정 이력** — 버전 칩·푸터·프로토타입/PDF 참조를 vX.Y로 갱신. **개정 이력 표 행은 기획자가 관리** — 자동 추가 금지(명시 승인 시만).

## 완료 체크리스트
> ⚠️ **체크리스트 SSOT = `rules/methodology/change-management.md`. 본 스킬의 체크리스트는 미러다 — 바꿀 때 둘 다 고친다.**

- [ ] 프로토타입 변경분(용어·정책·요건·상태)이 docs에 모두 반영됐다
- [ ] change-management.md '알려진 미반영' 목록을 소진했다
- [ ] `scripts/check-docs.sh` ALL GREEN
- [ ] 화면설계서가 docs와 일치한다 (용어·권한·IA·화면 구성)
- [ ] **변경분이 해당 도메인의 모든 화면 × PC/모바일 목업에 반영됐다** (누락 상습 지점 — 목업·액션 정의·유효성·상태 매트릭스까지 대조)
- [ ] 버전·참조·개정 이력·PDF가 갱신됐다

## 작업 리듬 (낭비 방지)
- **PDF 빌드는 이 절차의 마지막 1회만.** 중간 검토는 designspec HTML을 브라우저로 연다. 빌드 직전 "더 수정할 것 없나?" 한 번 확인.
- docs 동기화는 본 절차에서 **일괄** 수행(단 `POL`·`glossary`는 작업 중 즉시 반영). 상세 → change-management.md '작업 리듬'.

> ⚠️ 버전 라벨을 손댈 때는 `release-cut` 의 **블랭킷 치환 금지** 규칙을 동일하게 따른다(커버·푸터·프로토타입 참조 3종만; 상태 칩·역사 기록·개정 이력 보존).
