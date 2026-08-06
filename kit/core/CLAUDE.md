# CLAUDE.md — 진입점 (얇게 유지, 권장 200줄 이하)

> 이 파일은 AI 코딩 에이전트가 매 세션 가장 먼저 읽는 프로젝트 설명서다.
> 본체는 CLAUDE.md다 (팀 표준: Claude). Codex 등 AGENTS.md를 읽는 도구와 병용할 때만: `ln -s CLAUDE.md AGENTS.md`

## 이 프로젝트는 — (TODO 프로젝트명)
- (TODO 한 줄 정의) → `docs/PRD.md` 참조
- 두 레이어:
  - **(TODO Core 모듈명)/** — 순수 로직. (TODO 표준 API)만, UI·네트워크 의존 없음.
  - **(TODO App 모듈명)/** — UI 레이어. Core 호출만.

## 항상 적용 (자동 로드)
@rules/behavior.md
@rules/boundaries.md

## Rule Index (작업에 맞는 것만 추가로 읽는다 — 전부 읽지 않는다)
- 구조·아키텍처 맥락       → `rules/architecture.md`
- 빌드 / 테스트 / 린트     → `rules/commands.md`
- 화면·UI 작업            → `rules/ui.md`, `rules/ux.md`
- 도메인 로직·규칙 수정     → `rules/domain.md`
- **기획 방법론·작업 프로세스 → `rules/methodology/README.md`** (새 기능 기획, 마감 전 셀프 검토 시)
- **요건 200개+·도메인 3개+ → `rules/methodology/indexing.md`** (ID 네임스페이스·분할·INDEX 운영)

<!-- PACK-SLOT:rule-index — 설치된 팩이 여기에 자기 규칙 진입점을 추가한다 -->
<!-- 예: - **화면설계서 제작·버전 → `rules/methodology/designspec.md`** (designspec 팩) -->

## Skills (반복 프로세스 — `.claude/skills/`, 트리거 시 자동 제안)

<!-- PACK-SLOT:skills — 설치된 팩이 여기에 자기 스킬 목록을 추가한다 -->
<!-- 예 (designspec 팩): -->
<!-- - `release-cut` — 배포 후 다음 버전 라인 개시(형상 관리·절차 B). "vX 배포했고 다음 버전으로". -->
<!-- - `designspec-version-update` — docs 동기화 후 화면설계서 버전 업데이트(절차 A). -->

## Hooks (자동 강제 — `.claude/settings.json` → `.claude/hooks/`)
> boundaries.md #5("반드시 지킬 규칙은 기계 강제와 짝짓는다")의 실행체. 세션 시작 시 자동 로드되며, 끄려면 `.claude/settings.json` 의 해당 항목을 지운다.

<!-- PACK-SLOT:hooks — automation-hooks 팩 설치 시 여기에 훅 목록이 채워진다 -->

## 기획 문서 (무엇을 만드나)
- 정의·범위         → `docs/PRD.md`
- 용어(단일 진실)    → `docs/glossary.md`
- 요건 목록          → `docs/REQ.md` (마스터 인덱스 → `docs/INDEX.md`)
- 라벨 사전          → `docs/_labels.md`
- 정책·금지         → `docs/POL.md`
- 정보구조(메뉴체계) → `docs/IA.md`
- 화면(상태매트릭스) → `docs/screens/SCR-001.md` 등
- 사용자 플로우      → `docs/flows/FLOW-001.md`
- 검증 기준(GWT)    → `docs/TC.md`
- **기획 진척 로드맵 → `ROADMAP.md`** (도메인×Phase 매트릭스·마일스톤)

## 1초 검증
프로젝트 루트에서 실행한다. `rules/commands.md` 참조.

## 작업 지시 예시 (핸드오프 — 한 줄)
> REQ-001 을 SCR-001 에 구현해. POL-001 정책 지키고 TC-001 통과시켜.
> 상태 매트릭스 모든 케이스를 구현하고, glossary.md 표기를 그대로 따라.
