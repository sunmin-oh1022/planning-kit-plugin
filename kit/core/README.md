# servicekit — 기획자 × AI 페어 작업 범용 킷 (기획 docs → 화면설계서 → 배포·형상 관리)

> 새 프로젝트를 시작하실 때 `rules/methodology/`·`CLAUDE.md`·문서 템플릿을 매번 새로 만들지 않으셔도 되도록 만든 범용 킷입니다.<br>
> starter-kit(기획 docs)에 **화면설계서 제작 + 버전·형상 관리 + 반복 프로세스 스킬**을 더한 다음 단계 킷입니다.<br>
> 📖 **처음이시면 → [`사용설명서.md`](./사용설명서.md)** — 한 바퀴가 어떻게 도는지 순서대로 읽어가는 안내서.<br>
> 🚀 **명령어·placeholder 치환·화면설계서 라이프사이클 레퍼런스는 → [`SETUP.md`](./SETUP.md)**.

## 추가된 capability (starter-kit 대비)
- **화면설계서 제작** — `prototype/` 템플릿·빌드(`_template.designspec.html` → PDF) + `rules/methodology/designspec.md`.
- **버전·형상 관리** — `rules/methodology/change-management.md`(절차 A/B) + `scripts/release-cut.sh`·`new-domain.sh`.
- **스킬** — `.claude/skills/`: `release-cut` · `designspec-version-update` · `spec-self-review` · `spec-verify-loop`(도메인/버전 검증 루프 — 멀티에이전트 교차검증, 엔진은 `.claude/workflows/`).
- **정합성 §8** — `scripts/check-docs.sh`가 화면설계서 버전 라벨·`.baseline` 무결성까지 점검.
- **Hooks(자동 강제)** — `.claude/hooks/`: 위험 동작 차단(PreToolUse)·편집 직후 정합성 검증(PostToolUse)·종료 시 DEVLOG 유도(Stop). 상세는 `CLAUDE.md` 의 Hooks 절.

## 사용법 (3단계)

### 1단계 — 폴더 복사
Finder 에서 `starter-kit` 폴더를 원하는 위치로 복사/붙여넣기 한 뒤 복사본 이름을 프로젝트 이름으로 바꿔주세요 (예: `my-new-project`).

### 2단계 — AI 에게 환경 셋업 요청
새 폴더를 Cowork(또는 Claude Code)에 연결하신 뒤, 아래 메시지를 그대로 복사해서 보내주세요:

> 이 폴더에서 환경 셋업 부탁드립니다 (Phase 0):
>
> 1. Git 저장소 만들고 첫 커밋
> 2. (선택) 다른 AI 도구 병용 시 `AGENTS.md` 로도 인식되게 연결 (심볼릭 링크)
> 3. `CLAUDE.md` 안의 `(TODO)` 자리 같이 채우기 — 프로젝트 이름·정의·기술 스택

AI 가 Git 저장소를 만들고 두 파일을 같은 진입점으로 연결한 뒤, 무엇을 채워야 할지 하나씩 질문합니다.

### 3단계 — 기획 시작
셋업이 끝나면 가장 먼저 [`rules/methodology/README.md`](./rules/methodology/README.md) 한 페이지를 읽어주세요 — 5대 원리·6 Phase·4단 체계·환경 셋업 체크리스트·마감 셀프 검토 프롬프트가 모두 들어 있습니다.

구상하는 제품 구현을 AI에게 간단하지만 구체적인 프롬프트로 요청해보세요.
docs/에 정의된 기획 문서 초안 작성을 위해 AI가 질문하고 대답하는 여정이 시작됩니다.

<details>
<summary>(참고) 터미널이 익숙하신 분 — 한 줄 명령</summary>

```bash
cp -r starter-kit ~/Documents/Claude/Projects/my-new-project
cd ~/Documents/Claude/Projects/my-new-project
git init && git add -A && git commit -m "chore: 스타터킷 초기화"
# (선택) 다른 AI 도구 병용 시: ln -s CLAUDE.md AGENTS.md
```
</details>

## 폴더 구조
```
my-new-project/
├── CLAUDE.md (선택: AGENTS.md 로도 연결)  ← AI 가 매 세션 가장 먼저 읽는 진입점
├── SETUP.md                          ← ★ 실전 시작 가이드 (placeholder 치환·화면설계서 라이프사이클)
├── ROADMAP.md                        ← 기획 진척 로드맵 (도메인×Phase 매트릭스·마일스톤)
├── CHECKLIST.md                      ← 환경 셋업 체크리스트
├── DEVLOG.md · HISTORY.md · SHARE.md ← 결정·버전·기능 기록
├── .claude/skills/                   ← 반복 프로세스 스킬 (트리거 시 자동 제안)
│   ├── release-cut/                              (배포 후 다음 버전 라인 개시 · 절차 B)
│   ├── designspec-version-update/                (docs 동기화 후 화면설계서 버전업 · 절차 A)
│   ├── spec-self-review/                         (마감 전 셀프 검토 · Phase 2)
│   └── spec-verify-loop/                         (도메인/버전 검증 루프 · 멀티에이전트 교차검증)
├── .claude/workflows/                ← Workflow 스크립트
│   └── spec-verify-loop.js                       (검증 루프 엔진 — 기계검증+7축 교차검증+환각 제거)
├── .claude/hooks/                    ← 자동 강제 훅 (위험 차단·정합성 검증·DEVLOG 유도)
│   └── settings.json 에서 PreToolUse·PostToolUse·Stop 에 배선
├── rules/                            ← "어떻게 일하나" — 메타 규칙
│   ├── behavior.md · boundaries.md   (항상 @import)
│   ├── architecture.md · commands.md · domain.md · ui.md · ux.md  (작업별)
│   └── methodology/                  ← 기획·작업 방법론
│       ├── README.md · templates.md
│       ├── designspec.md             ← 화면설계서 제작 방법론
│       ├── change-management.md       ← 버전·형상 관리 (절차 A/B)
│       └── indexing.md               ← 대규모 ID·인덱스·분할 정책 (REQ 200+ 시점)
├── docs/                             ← "무엇을 만드나" — 산출물 (평탄 구조)
│   ├── README.md                                 (진입 가이드 + 파일명 규칙)
│   ├── PRD.md · glossary.md · personas.md         (제품 정의·용어·페르소나)
│   ├── POL.md                                     (정책 — 대규모 분할 시 domains/{도메인}/POL)
│   ├── REQ.md · INDEX.md · _labels.md             (요건·인덱스·라벨)
│   ├── IA.md                                      (정보구조 — 메뉴↔화면 매핑)
│   ├── TC.md                                      (Given–When–Then)
│   ├── PRIVACY.md · RELEASE.md                    (출시 운영 — 개인정보 처리방침·릴리스 노트)
│   ├── screens/        SCR-### (★ 상태 매트릭스 6개)
│   ├── flows/          FLOW-### (사용자 플로우)
│   └── domains/        {도메인}/REQ · POL · SCR · TC (REQ 200+ 시 분할)
├── prototype/                        ← 화면설계서·프로토타입 산출물
│   ├── _template.designspec.html                 (★ 화면설계서 템플릿)
│   ├── build-all.sh · build-pdf.sh               (PDF 빌드 — 가로 297mm 고정·세로 자동)
│   ├── 화면설계서-가이드.md · README.md            (제작 컨벤션·도메인 매핑)
│   ├── .baseline/                                (배포 동결본 보관소)
│   └── <도메인폴더>/   [{DOMAIN}] 화면설계서·프로토타입
├── scripts/                          ← 보조 스크립트
│   ├── check-docs.sh                             (문서·화면설계서 버전 정합 점검 §1~8)
│   ├── new-domain.sh                             (새 도메인 화면설계서 생성 — 템플릿+{DOMAIN} 치환)
│   ├── release-cut.sh                            (배포 후 다음 버전 라인 개시 · 절차 B)
│   ├── sync.sh · sync_confluence.py · requirements.txt  ((선택) Confluence 동기화)
│   └── …
└── .env.confluence.example           ← 위키 연결 시 .env.confluence.local 로 복사해서 사용
```

파일명 규칙(약어/ID/일반 명사/시스템 4분류)은 [`docs/README.md`](./docs/README.md) 가 단일 진실입니다.

## 프로젝트별로 채워지는 (TODO) 자리

> 사람이 손으로 메우는 체크리스트가 아니다. 무엇을 채울지는 사람이 정하고, 실제로 문서에 적는 일은 AI 가 맡는다. 진행 상황은 `scripts/check-docs.sh` §5 가 남은 `(TODO)` 줄 수로 알려준다.

| 파일 | 무엇이 들어가나 |
| --- | --- |
| `CLAUDE.md` | 프로젝트 정의 1줄 + Core/App 레이어 이름 |
| `ROADMAP.md` | 도메인 행 + 마일스톤 목표 일자 + Out of scope |
| `rules/boundaries.md` | 도메인 고유 가드레일 (시간·네이밍·외부 의존 등) |
| `rules/architecture.md` | 폴더 배치 (스택별로 다름) |
| `rules/commands.md` | 1초 검증 명령 (`npm test` / `pytest` / `go test` / `swift test` ...) |
| `rules/domain.md` | 도메인 단일 출처 규칙 |
| `docs/PRD.md` | 정의·범위·KPI·비기능 |
| `docs/glossary.md` | 용어·데이터 단일 진실 (대규모 시 도메인 코드 표 포함) |
| `docs/POL.md` | 정책 표 (사유 + 적용 시점 필수) |
| `docs/REQ.md` | 요건 표 (MoSCoW + 화면·정책·TC ID) + 항목 헤더 규약 |
| `docs/INDEX.md` | 본문 항목의 한 줄 미러 (검색·검증 전용) |
| `docs/IA.md` | 정보구조 — 메뉴 체계·화면(SCR) 매핑 표 |
| `docs/_labels.md` | 라벨 사전 (횡단 관심사만) |
| `docs/screens/SCR-###.md` | 화면별 상태 매트릭스 6개 |
| `docs/TC.md` | Given–When–Then |

## ID 체계
- 소·중규모: `REQ-### → SCR-### → TC-###`, 정책 `POL-###`, 플로우 `FLOW-###`
- 대규모(요건 200+·도메인 3+): `REQ-{DOMAIN}-####` (예: `REQ-AUTH-0001`) — 상세는 `rules/methodology/indexing.md`
- 한 줄 핸드오프 예: "REQ-001 을 SCR-001 에 구현해 주세요. POL-001 지키고 TC-001 통과시켜 주세요."

## 기획 문서 4단 체계 (넓은 맥락에서 구체적 검증으로)

| 단계 | 파일 |
| --- | --- |
| ① 상시 브리프 | `docs/PRD.md` · `ROADMAP.md` |
| ② 가드레일 | `docs/POL.md` · `docs/glossary.md` · `docs/_labels.md` · `rules/boundaries.md` |
| ③ 가이드 | `docs/REQ.md` · `docs/INDEX.md` · `docs/IA.md` · `docs/flows/FLOW-001.md` · `docs/screens/SCR-001.md` |
| ④ 검증·기록 | `docs/TC.md` · `DEVLOG.md` · `HISTORY.md` |


## 작업 흐름 (기능마다 Phase 1→5 반복)
상세는 [`rules/methodology/README.md`](./rules/methodology/README.md) 참조. 요약하면:

1. 기획 문서 작성 (PRD/REQ/POL/SCR/TC) + ROADMAP 행 갱신
2. 셀프 검토 — 가볍게는 `spec-self-review`, 도메인/버전 단위로 꼼꼼히는 `spec-verify-loop`(멀티에이전트 교차검증). 인덱스 동기화·추적 끊김도 함께 점검
3. 한 줄 핸드오프 — "REQ-### 을 SCR-### 에 구현. POL-### 지키고 TC-### 통과."
4. AI 구현 + 1초 검증 (`commands.md`) + 정합성 검증 (`scripts/check-docs.sh`) + 사람 실환경 확인
5. DEVLOG · HISTORY · ROADMAP 기록
