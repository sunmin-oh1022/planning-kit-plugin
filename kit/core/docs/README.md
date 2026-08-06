# docs/ — 기획 산출물 진입 가이드

> "무엇을 만드나" 의 단일 진실 영역. "어떻게 일하나"의 메타 규칙은 [`../rules/`](../rules/) 에.
> 작성 방법론은 [`../rules/methodology/README.md`](../rules/methodology/README.md), 대규모 분할·인덱싱은 [`../rules/methodology/indexing.md`](../rules/methodology/indexing.md).

## 폴더 구조 (평탄)
> 아래는 `docs/` 내부만. 킷 **전체 폴더 트리의 권위는 루트 [`README.md`](../README.md)**.
```
docs/
├── README.md                       ← 본 파일 (진입 가이드 + 파일명 규칙)
├── PRD.md · glossary.md · personas.md       (제품 정의·용어·페르소나)
├── POL.md                          (정책)
├── REQ.md · INDEX.md · _labels.md  (요건·인덱스·라벨)
├── IA.md                           (정보구조 — 메뉴↔화면 매핑)
├── TC.md                           (Given–When–Then)
├── PRIVACY.md · RELEASE.md         (출시 운영 — 개인정보 처리방침·릴리스 노트)
├── screens/        SCR-###.md      (화면 — 상태 매트릭스 6개)
├── flows/          FLOW-###.md     (사용자 플로우)
└── domains/        {도메인}/REQ·POL·SCR·TC.md  (REQ 200+ 시 분할)
```

screens · flows · domains 만 폴더로 둔다. 그 외 단일 진실 문서는 모두 `docs/` 루트에 평탄하게.

## 파일명 규칙 ★

| 패턴 | 예 | 언제 쓰나 |
| --- | --- | --- |
| **대문자 약어** `XXX.md` | `PRD.md` · `POL.md` · `REQ.md` · `IA.md` · `TC.md` · `INDEX.md` | ID prefix(`POL-###`)와 1:1 정합하는 단일 진실 본문 |
| **대문자 prefix + 번호** `XXX-###.md` | `SCR-001.md` · `FLOW-001.md` · `REQ-AUTH-0001.md`(대규모) | 개별 항목 — 파일명 자체가 ID. 자릿수는 [indexing.md § 1](../rules/methodology/indexing.md) 따름 |
| **소문자 일반 명사** `xxx.md` | `glossary.md` · `personas.md` | 약어가 없는 보조·맥락 문서 |
| **`_` 접두사 + 소문자** `_xxx.md` / `_xxx/` | `_labels.md` · `_template.md` · `_archive/`(향후) | 시스템·메타·정렬상 위로 떠야 하는 파일 |
| **관습 예외** | `README.md` | Markdown/GitHub 관습 — 폴더 진입 시 자동 렌더 |

### 한 줄 요약
> **약어 = 대문자, 일반 명사 = 소문자, ID = 대문자-숫자, 시스템 = `_` 접두사.**

### 자주 묻는 케이스
- "약어인지 일반 명사인지 헷갈리는데?" — 본문에서 그 문서를 가리킬 때 `POL.md` 처럼 약어로 부르고 있으면 약어 후보. 풀어서 부르면(`glossary.md`) 일반 명사.
- "복수형으로 쓸까?" — 일반 명사는 의미 단위로. `personas` 는 여러 페르소나를 묶는 단일 문서라 복수. `glossary` 는 용어 사전 하나라 단수.
- "하이픈 vs 언더바?" — 같은 단어 안에서는 쓰지 않는다(`my-doc.md` ✗ / `mydoc.md` ✓). 하이픈은 **ID 구분자 전용**(`SCR-001`, `REQ-AUTH-0001`).
- "확장자 외 대소문자 혼용?" — 금지. 위 4분류 외엔 만들지 않는다.

## 어디에 무엇이 있나
| 찾는 것 | 위치 |
| --- | --- |
| 제품 정의·범위·KPI | [`PRD.md`](./PRD.md) |
| 용어 단일 진실 | [`glossary.md`](./glossary.md) |
| 사용자 페르소나 | [`personas.md`](./personas.md) |
| 정책·금지·예외 | [`POL.md`](./POL.md) |
| 요구사항 본문 | [`REQ.md`](./REQ.md) |
| 요구사항 마스터 인덱스 | [`INDEX.md`](./INDEX.md) |
| 정보구조 (메뉴↔화면 매핑) | [`IA.md`](./IA.md) |
| 라벨 사전 (횡단 태그) | [`_labels.md`](./_labels.md) |
| 검증 시나리오 (GWT) | [`TC.md`](./TC.md) |
| 개인정보 처리방침 (외부 공개) | [`PRIVACY.md`](./PRIVACY.md) |
| 릴리스 노트·출시 체크리스트 | [`RELEASE.md`](./RELEASE.md) |
| 화면 정의 | [`screens/`](./screens/) |
| 사용자 플로우 | [`flows/`](./flows/) |
| 도메인별 분할 (REQ 200+) | [`domains/`](./domains/) |
