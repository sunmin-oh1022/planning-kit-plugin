# indexing.md — 대규모 요구사항·기능 명세 인덱싱

> 한 프로젝트의 REQ·POL·SCR·FLOW·TC 가 수천~수만 개로 늘어도 **찾기·추적·중복 방지·정합성 검증** 이 깨지지 않게.
> 5대 원리(특히 '단일 진실', 'ID로 추적')를 대규모로 살리는 운영 규칙.
> 작은 프로젝트(요건 100개 미만)는 § 1 만 읽고 넘어가도 됨. § 2~ 는 도메인이 3개 이상이거나 REQ 가 200개를 넘기 시작할 때.

## 0. 한 문장 요약
> **ID는 검색 가능하게, 파일은 분할 가능하게, 인덱스는 grep 한 줄로.**

상세 본문(REQ-### 표 한 칸)은 사람이 읽지만, 인덱스(INDEX.md)는 AI·스크립트가 본다. 둘을 섞지 않는다.

---

## 0. 파일명 규칙 (상세는 [`docs/README.md`](../../docs/README.md))

> 단일 진실은 `docs/README.md`. 본 문서는 ID 네임스페이스와 직결되는 핵심만 다시 적는다.

| 패턴 | 예 | 의미 |
| --- | --- | --- |
| 약어 `XXX.md` | `PRD.md` · `POL.md` · `REQ.md` · `TC.md` · `INDEX.md` | ID prefix 와 1:1 정합하는 단일 진실 본문 |
| ID `XXX-###.md` | `SCR-001.md` · `REQ-AUTH-0001.md` | 개별 항목 — 파일명 = ID (자릿수는 § 1) |
| 일반 명사 `xxx.md` | `glossary.md` · `personas.md` | 약어 없는 보조 문서 |
| 시스템 `_xxx.md` | `_labels.md` · `_template.md` · `_archive/` | 메타·정렬상 위로 떠야 하는 파일 |

핵심 한 줄: **약어 = 대문자, 일반 명사 = 소문자, ID = 대문자-숫자, 시스템 = `_` 접두사.**

---

## 1. ID 네임스페이스 (작은~중간 규모)

### 1.1 단일 prefix (요건 ≤ 200, 도메인 1~2개)
`REQ-001 · POL-001 · SCR-001 · TC-001 · FLOW-001` — 기존 5대 원리 그대로.

### 1.2 도메인 prefix (요건 200~수천, 도메인 3개~)
`REQ-{DOMAIN}-{NNNN}` 형태로 확장.

| 요소 | 규칙 | 예 |
| --- | --- | --- |
| 타입 prefix | 대문자, 고정(REQ/POL/SCR/TC/FLOW) | `REQ` |
| 도메인 코드 | 대문자 영문 2~6자, glossary 등록 필수 | `AUTH` / `PAY` / `SEARCH` |
| 일련번호 | 4자리 zero-padded, 도메인 내 단조 증가 | `0042` |

조합: `REQ-AUTH-0042` / `POL-PAY-0007` / `SCR-SEARCH-0013`

> '도메인 코드' 는 glossary.md 에 한 번만 정의한다(단일 진실). 코드가 두 글자(`PAY` ↔ `PMT`) 로 혼용되면 인덱스가 깨진다.

### 1.3 영역 prefix (요건 수천~수만, 한 도메인 안에서도 세분 필요)
`REQ-{DOMAIN}-{AREA}-{NNNN}`. AREA 는 도메인 안에서만 유일.

| 예 | 의미 |
| --- | --- |
| `REQ-AUTH-LOGIN-0001` | 인증 도메인 / 로그인 영역 / 1번 |
| `REQ-AUTH-SIGNUP-0001` | 인증 도메인 / 가입 영역 / 1번 |
| `REQ-PAY-CARD-0042` | 결제 도메인 / 카드 영역 / 42번 |

> AREA 도입 시점: 한 도메인의 REQ 가 100개를 넘어가면 영역으로 쪼갠다. 그 전엔 평면 유지.

### 1.4 ID 발번 규칙
- **연속이 아니어도 된다** — 삭제된 ID 는 결번으로 둔다(재사용 금지). 추적 끊김을 만든다.
- **블록 예약 금지** — "PAY 는 1000번대" 같은 예약은 도메인 prefix 가 이미 처리. 번호는 항상 0001 부터.
- **임시 ID 금지** — `REQ-TEMP-1` 같은 건 인덱스를 오염시킨다. 발번 즉시 정식 도메인으로.
- **suffix(`-a`, `-b`) 금지** — 같은 REQ 의 케이스가 여러 개여도 `TC-003a/b/c` 식 알파벳 접미사를 붙이지 않는다. 케이스마다 별도 번호 (`TC-003 / TC-004 / TC-005`) 를 부여한다. 이유: ① 검사 스크립트의 ID 포맷 규칙(`TC-###`)이 깨짐 ② 인덱스 정렬·grep 이 흐려짐. **REQ → TC 가 1:N 일 때는 REQ 표의 'TC' 칸에 쉼표로 나열한다** (예: `TC-003, TC-004, TC-005`).

---

## 2. 다축 인덱싱 (ID 외에 더 필요한 것)

ID 는 위치만 알려준다. '상태가 Approved 인 Must 요건' 같은 뷰는 ID 만으로 못 만든다. → **메타 4축** 을 매 항목에 단다.

| 축 | 값 (Enum) | 어디에 |
| --- | --- | --- |
| **status** | `draft` / `reviewed` / `approved` / `implementing` / `done` / `deprecated` | 매 항목 |
| **priority** | `must` / `should` / `could` / `wont` (MoSCoW) | 기능 요건 |
| **milestone** | `mvp` / `v1.0` / `v1.1` / `backlog` (PRD 마일스톤과 정합) | 기능 요건 |
| **owner** | 사람 이름 1명 (책임자 — 작성자 ≠ 책임자 가능) | 매 항목 |

**라벨(tag)** 은 위 4축과 직교하는 횡단 관심사: `#performance` `#i18n` `#accessibility` `#payment-flow`. 라벨은 자유롭게 늘어도 되지만 **정의는 glossary 의 라벨 표에 단일 진실로 둔다**.

### 2.1 status 라이프사이클
```
draft → reviewed → approved → implementing → done
                                          ↘ deprecated (어느 단계에서든)
```
- `draft` → `reviewed`: 셀프 검토 프롬프트 통과(methodology/README.md Phase 2)
- `approved` → `implementing`: 핸드오프(Phase 3) 시점
- `done`: TC 모두 통과 + DEVLOG 기록
- `deprecated`: ID 는 남기되 본문에 후속 ID 명시 (`→ REQ-AUTH-0099 로 대체, 2026-05-01`)

---

## 3. 파일 분할 정책

### 3.1 임계값 (경험치)

| 한 파일 안 REQ/POL/TC 행 수 | 권장 조치 |
| --- | --- |
| ≤ 50 | 단일 파일 유지 (`REQ.md`) |
| 50 ~ 200 | 도메인별 파일로 분할 (`domains/auth/REQ.md`) |
| 200+ | 도메인 안에서 영역별 파일 (`domains/auth/login/REQ.md`) 또는 ID 묶음 파일 (`REQ-AUTH-0001-0050.md`) |

> 분할 기준은 '읽는 사람의 컨텍스트' 다. 한 화면(SCR)에서 참조하는 REQ가 한 파일에 같이 있으면 좋다 — 도메인 분할이 자연스러운 이유.

### 3.2 분할 후에도 사람이 보는 진입점은 하나
- `docs/REQ.md` — 진입 가이드 (어디에 무엇이 있는지) + 단일 prefix 모드일 때만 본문 표
- `docs/INDEX.md` — 모든 항목 한 줄 요약 (자동 생성 권장, § 5)
- `docs/domains/{도메인}/REQ.md` — 도메인별 본문

### 3.3 폴더 구조 (수천 개 이상 규모)
> 대규모 분할 변형. 기본/전체 트리의 권위는 루트 [`README.md`](../../README.md).
```
docs/                              ← 평탄 구조 (소~중규모는 docs/ 바로 아래에 .md)
├── PRD.md · glossary.md · personas.md
├── POL.md                         ← 정책 (대규모면 domains/{도메인}/POL.md 로 분할)
├── REQ.md                         ← 진입 가이드 (작은 규모면 본문 그대로)
├── INDEX.md                       ← 마스터 인덱스 (한 줄/항목)
├── IA.md                          ← 정보구조 (메뉴↔화면; 대규모면 domains/{도메인}/ 분할)
├── _labels.md                     ← 라벨 사전 (glossary 보조)
├── TC.md                          ← 검증 (대규모면 domains/{도메인}/TC.md 로 분할)
├── screens/
│   ├── INDEX.md
│   └── SCR-*.md                   (대규모 시 domains/{도메인}/SCR-*.md)
├── flows/
│   └── FLOW-*.md                  ← 도메인 횡단 플로우
└── domains/                       ← REQ 200+/도메인 3+ 시 도메인별 분할
    ├── auth/
    │   ├── REQ.md                 (또는 login/, signup/ 로 더 분할)
    │   ├── POL.md
    │   ├── SCR-*.md
    │   ├── TC.md
    │   └── flows/FLOW-AUTH-*.md   (도메인 내 플로우)
    ├── pay/
    └── search/
```

---

## 4. INDEX.md — 한 줄 인덱스 포맷 (★ 핵심)

본문은 사람이 읽고, INDEX 는 grep·AI·스크립트가 본다. **포맷이 깨지면 검증 스크립트가 깨진다**.

### 4.1 포맷
```
| ID | 제목 | 도메인 | 상태 | 우선순위 | 마일스톤 | 소유자 | 라벨 | 파일 |
| REQ-AUTH-0001 | 이메일 로그인 | AUTH | approved | must | mvp | @sunmin | #security | domains/auth/REQ.md#REQ-AUTH-0001 |
```

규칙:
- **한 항목 = 한 줄** (줄바꿈 금지, 멀티라인 셀 금지)
- 제목은 본문의 '요구사항명' 과 정확히 일치 (단일 진실)
- '파일' 열은 본문 위치(`경로#앵커`) — 클릭/grep 가능
- 라벨은 공백 구분 `#tag1 #tag2`

### 4.2 본문 ↔ 인덱스 동기화
- **본문이 단일 진실**, INDEX 는 미러.
- 본문에 항목 추가/수정 → INDEX 한 줄 갱신 (같은 PR/커밋에서).
- `scripts/check-docs.sh` 가 본문 ID 와 INDEX ID 의 집합 차이를 검사.

### 4.3 본문 항목 헤더 규약 (앵커용)
도메인별 REQ.md 의 각 항목 위에 명시 헤더를 둔다:
```markdown
### REQ-AUTH-0001 — 이메일 로그인
- status: approved · priority: must · milestone: mvp · owner: @sunmin
- labels: #security
- related: SCR-AUTH-0001, POL-AUTH-0003, TC-AUTH-0001
- (본문/표)
```
`### REQ-AUTH-0001` 형태 헤더는 GitHub 자동 앵커가 `#req-auth-0001` 로 잡힌다 → INDEX 의 파일 열에서 그대로 링크.

---

## 5. 인덱스 자동 생성 (선택)

INDEX.md 를 손으로 유지하면 결국 깨진다. 본문 항목 헤더 규약(§ 4.3)을 지키면 스크립트로 생성 가능.

권장 흐름:
1. 본문은 사람이 쓴다 (`REQ.md` 의 `### REQ-###` 헤더 + 메타 라인).
2. `scripts/build-index.sh` (선택 도구) 가 본문을 훑어 `INDEX.md` 를 덮어쓴다.
3. `scripts/check-docs.sh` 가 본문 ↔ INDEX 동기화 + 중복 ID + 끊긴 추적을 검사.

> 스크립트 도입은 REQ 가 100개를 넘기 시작할 때부터 고려. 그 전엔 손 유지로 충분.

---

## 6. 추적성 (REQ ↔ SCR ↔ TC, 끊김 검출)

5대 원리의 'ID로 추적' 을 대규모에서 살리는 규칙:

| 항목 | 필수 연결 |
| --- | --- |
| REQ (기능) | 최소 1개 SCR + 최소 1개 TC |
| REQ (비기능) | 최소 1개 TC (SCR 은 '전역' 가능) |
| SCR | 최소 1개 REQ |
| TC | 정확히 1개 REQ (또는 POL) |
| POL | 최소 1개 REQ 또는 SCR 의 상태 매트릭스에서 참조 |

**끊김(orphan) 검출 룰** (scripts/check-docs.sh 가 검사):
- REQ 인데 어떤 TC 도 가리키지 않으면 → ✗
- SCR 인데 어떤 REQ 도 가리키지 않으면 → ✗
- TC 인데 대상 REQ ID 가 존재하지 않으면 → ✗
- POL 인데 어떤 REQ/SCR 도 참조하지 않으면 → ! (경고만, '전역 정책'일 수 있음)

---

## 7. 라벨 운영 (#tag)

- 라벨은 **횡단 관심사** 만 — 이미 ID/도메인/상태로 표현 가능한 건 라벨로 쓰지 않는다.
- 좋은 라벨 예: `#performance` `#i18n` `#accessibility` `#legal-compliance` `#analytics-event`
- 나쁜 라벨 예: `#must` (priority 와 중복), `#auth` (도메인 prefix 와 중복), `#v1` (milestone 과 중복)
- 새 라벨은 `docs/_labels.md` 에 정의 추가 후 사용 (PR 단위).

---

## 8. 변경·폐기 (deprecation)

- 항목 삭제 금지 — `status: deprecated` 로 전환.
- deprecated 항목은 본문 표 맨 아래로 이동, 후속 ID 와 폐기 사유·일자 명시.
- 6개월 후 archive 폴더로 이동 가능 (`docs/_archive/`). INDEX 에서는 제거.

> ID 재사용 금지가 핵심. 폐기된 `REQ-AUTH-0007` 이 새 요건으로 부활하면 과거 DEVLOG·HISTORY 의 의미가 깨진다.

---

## 9. 도입 단계 (작은 프로젝트 → 큰 프로젝트로)

| 시점 | 적용 |
| --- | --- |
| 0~50 REQ | 단일 prefix(`REQ-001`) + 단일 `REQ.md`. INDEX 불필요. |
| 50~200 REQ | 단일 prefix 유지, **§ 4.3 본문 헤더 규약**만 도입. INDEX.md 손 유지. |
| 200~수천 | 도메인 prefix(`REQ-AUTH-0001`) 전환 + 도메인별 파일 분할 + INDEX 자동 생성 도입. |
| 수천~ | 영역 prefix 추가, archive 정책 운영, check-docs 의 인덱스 검증 절대 끄지 않기. |

> 한 번에 다 도입하지 않는다. 단계마다 'ID 변경 마이그레이션' 은 한 번의 커밋으로 완결 — DEVLOG 에 'REQ-### → REQ-AUTH-### 일괄 전환' 기록.

---

## 10. 안티패턴 (자주 깨지는 곳)

1. **본문과 INDEX 가 다른 값** — 어느 쪽이 진실인지 불명. ⇒ 본문 단일 진실, INDEX 는 자동 생성/검증.
2. **ID 재사용** — 삭제 후 같은 번호에 다른 요건. ⇒ 결번 유지.
3. **도메인 코드 혼용** — `PAY` 와 `PMT` 가 같이 등장. ⇒ glossary 단일 진실.
4. **라벨 폭증** — 자유 태그가 200개. ⇒ `_labels.md` PR 단위 등록.
5. **표 가운데 멀티라인** — 마크다운 표 셀에 `<br>` 남발. ⇒ 인덱스 깨짐. 본문은 항목 헤더 + 표 분리.
6. **임시 ID** — `REQ-TEMP-1`. ⇒ 발번 즉시 정식.
7. **TODO 만 잔뜩** — 빈 행이 INDEX 에 들어감. ⇒ `(TODO)` 행은 INDEX 제외.
8. **알파벳 suffix 케이스** — `TC-003a/b/c` 식. ⇒ § 1.4 — 별도 번호 부여 + 표 한 칸 쉼표 나열.
9. **`REQ-XXX` placeholder** — 가이드 문구에 임시 표기로 적은 게 검사에 잡힘. ⇒ 모든 placeholder 는 `REQ-###` 로 통일 (검사 스크립트가 예외 처리함).
