# planning-kit — 기획자 × AI 페어 작업 킷 (core + packs)

> `servicekit`(구 releasekit)의 후속. 하나의 모놀리식 킷 대신 **항상 필요한 core + 선택 가능한 packs** 구조로 재편.
> 관계: `planning-kit = servicekit` (동일 방법론·5대 원리·6 Phase). 다른 점 = 팩 단위로 골라 설치.

## 왜 이렇게 나눴나 (배경)

servicekit·releasekit·designspec-kit이 각자 자라며 발생한 3가지 문제 해결:
1. **SSOT 중복** — `change-management.md` 등이 두 킷에 존재하며 미묘하게 어긋남.
2. **불필요한 짐** — 화면설계서 파이프라인이 필요없는 프로젝트에도 `prototype/`·형상관리 스킬이 딸려옴.
3. **팩 경계 문서만 있고 기계는 없음** — designspec-kit이 이미 "옵션 모듈" 패턴을 시연했지만 수동 복사에 의존.

## 구조

```
planning-kit/
├── core/                        ← 모든 프로젝트 공통 (기획 방법론·문서 템플릿·기본 규칙)
│   ├── CLAUDE.md                (진입점 — 팩 슬롯 포함)
│   ├── README.md · SETUP.md · CHECKLIST.md · DEVLOG.md · HISTORY.md · SHARE.md · ROADMAP.md
│   ├── rules/                   (behavior · boundaries · architecture · commands · domain · ui · ux)
│   │   ├── methodology/         (README · templates · indexing — 5대 원리·6 Phase)
│   │   └── ux/                  (common · flows 템플릿)
│   ├── docs/                    (9개 기획 문서 템플릿 · screens · flows · domains)
│   ├── scripts/                 (check-docs.sh · new-domain.sh)
│   └── 사용설명서.md
│
├── packs/                       ← 선택 설치 (프로젝트 성격에 따라)
│   ├── designspec/              (화면설계서 파이프라인 · 형상관리 절차 A/B)
│   ├── spec-verify/             (spec-self-review · spec-verify-loop · intent-capture)
│   ├── decision-log/            (DECISIONS.md 결정 로그 · meetings/ 원본 규칙 · decision-sync)
│   ├── ux-review/               (ux-review 스킬 · Norman·UCSD·감성디자인 references)
│   ├── automation-hooks/        (PreToolUse·PostToolUse·Stop 훅 3종)
│   └── confluence-sync/         (Confluence 위키 동기화)
│
├── tools/                       ← 설치·진단 유틸
│   └── kit-install              (list · core · pack · doctor 서브명령)
│
└── docs/                        ← 킷 자체의 안내
    ├── README.md                (설치 결정 가이드)
    └── PACKS.md                 (팩 카탈로그)
```

## 설치

```bash
KIT=/path/to/planning-kit
PROJECT=/path/to/my-new-project

# 1) 사용 가능한 팩 확인
python3 "$KIT"/tools/kit-install list

# 2) core 설치 (항상 먼저)
python3 "$KIT"/tools/kit-install core "$PROJECT"

# 3) 필요한 팩 설치 (예: designspec + spec-verify)
python3 "$KIT"/tools/kit-install pack designspec  "$PROJECT"
python3 "$KIT"/tools/kit-install pack spec-verify "$PROJECT"

# 4) 상태 진단
python3 "$KIT"/tools/kit-install doctor "$PROJECT"
```

설치 후 프로젝트에 남는 것:
- `core`가 만든 진입점 (`CLAUDE.md`) + rules · docs 템플릿
- 팩별로 `.claude/skills/`·`prototype/`·훅 등이 얹혀지고, `CLAUDE.md` 슬롯에 팩 라인이 자동 주입
- 어느 팩이 뭘 넣었는지는 `<!-- pack:xxx begin -->` ~ `<!-- pack:xxx end -->` 블록으로 추적 가능

## 팩 카탈로그

| 팩 | 필요한 경우 | 필요 없는 경우 |
| --- | --- | --- |
| `designspec` | 화면설계서를 버전 매겨 PDF로 반복 배포 | PDF 산출·형상관리 없이 코드로만 배포 |
| `spec-verify` | 마감 전 문서 셀프 검토를 자동화·교차검증 | 소규모 개인 프로젝트 |
| `decision-log` | 회의록·일정 변경이 잦아 결정 상태의 단일 진실이 필요 | 결정 주체가 1인이고 미결이 거의 없음 |
| `ux-review` | 화면·플로우에 이론 기반 UX 검토 필요 | UX 결정을 사람만이 함 |
| `automation-hooks` | 위험 동작 차단·자동 정합성 검증을 훅으로 강제 | 훅 없이 규칙에 의존 |
| `confluence-sync` | 사내 위키(Confluence)에 문서 동기화 | 위키 사용 안 함 |

상세는 `docs/PACKS.md`.

## 마이그레이션 매핑 (구 킷 → planning-kit)

| 구 위치 | 새 위치 |
| --- | --- |
| `releasekit/*` | **폐기** — `.archive/releasekit-2026-06-30/` 로 이동 |
| `servicekit/rules/{behavior,boundaries,architecture,commands,domain,ui,ux}.md` | `core/rules/` |
| `servicekit/rules/methodology/{README,templates,indexing}.md` | `core/rules/methodology/` |
| `servicekit/rules/methodology/{change-management,designspec}.md` | `packs/designspec/rules/methodology/` |
| `servicekit/rules/ux/*` | `core/rules/ux/` |
| `servicekit/docs/{PRD,glossary,personas,...}.md` | `core/docs/` |
| `servicekit/docs/REVIEW.md` | `packs/spec-verify/docs/` |
| `servicekit/docs/UX-REVIEW.md` | `packs/ux-review/docs/` |
| `servicekit/prototype/*` | `packs/designspec/prototype/` |
| `servicekit/scripts/{check-docs,new-domain}.sh` | `core/scripts/` |
| `servicekit/scripts/release-cut.sh` | `packs/designspec/scripts/` |
| `servicekit/scripts/{sync,sync_confluence}.*` | `packs/confluence-sync/scripts/` |
| `servicekit/.claude/skills/{release-cut,designspec-version-update}` | `packs/designspec/.claude/skills/` |
| `servicekit/.claude/skills/{spec-self-review,spec-verify-loop,intent-capture}` | `packs/spec-verify/.claude/skills/` |
| `servicekit/.claude/skills/ux-review` | `packs/ux-review/.claude/skills/` |
| `servicekit/.claude/workflows/spec-verify-loop.js` | `packs/spec-verify/.claude/workflows/` |
| `servicekit/.claude/hooks/*.py` | `packs/automation-hooks/.claude/hooks/` |

## 현재 상태 (2026-07-29 · v1.0 초기 릴리스)

- [x] releasekit 아카이브 (`.archive/releasekit-2026-06-30/`)
- [x] core/ 뼈대 + servicekit 코어 파일 이식
- [x] designspec 팩 이식
- [x] spec-verify · ux-review · automation-hooks · confluence-sync 팩 카빙
- [x] `tools/kit-install` CLI (list · core · pack · doctor)
- [x] servicekit·designspec-kit 아카이브 (`.archive/`)
- [x] decision-log 팩 추가 (2026-07-30 — 글로컬 AI 성장센터 대시보드 현행화 지연 사례에서 도출)
- [x] **서비스화 M1** (2026-07-30) — Cowork 플러그인 패키징: `plugin/` 소스 + `planning-start` 인터뷰형 셋업 스킬 + `tools/build-plugin` → `dist/planning-kit.plugin`. 기획안: `docs/SERVICE-PLAN.md`
- [x] **진입점 CLAUDE.md 전환** (2026-07-30) — 본체 CLAUDE.md · AGENTS.md는 선택 심링크 (구버전 폴백 유지)
- [x] **서비스화 M2** (2026-07-30) — `planning-coach` 스킬 (상태 브리핑·복귀 플로우·다음 행동 결정 트리) + 사용자 언어 사전. 플러그인 v0.2.0

**검증 통과** — 임시 프로젝트에 core + 5개 팩 전부 설치 → `check-docs.sh` ALL GREEN, doctor 6/6 GREEN.
