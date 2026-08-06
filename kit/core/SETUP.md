# SETUP — 새 프로젝트 시작 가이드 (servicekit)

> README.md = 킷이 무엇이고 왜 쓰는가(개요·빠른 시작). **본 문서 = 실전 "어떻게 시작하나"** — 특히 ★placeholder 치환 워크플로우와 화면설계서 버전·형상 관리 라이프사이클.
> 방법론 단일 진실은 [`rules/methodology/README.md`](rules/methodology/README.md).

## 0. 이 킷이 주는 것 (starter-kit의 다음 단계)
| 레이어 | 무엇 | 어디 |
| --- | --- | --- |
| 기획 docs | PRD·glossary·POL·REQ·IA·SCR·FLOW·TC (단일 진실) | `docs/` |
| **화면설계서 제작** | 프로토타입 → docs → 화면설계서(`.designspec.html` → PDF) | `prototype/` + `rules/methodology/designspec.md` |
| **버전·형상 관리** | 버전 업데이트(절차 A)·릴리스 컷(절차 B) | `rules/methodology/change-management.md` + `scripts/` |
| **반복 프로세스 스킬** | release-cut · designspec-version-update · spec-self-review | `.claude/skills/` |

## 1. 시작 지점 — 빠른 시작은 README가 단일 진실
복사 → Phase 0 환경 셋업(Git 초기화·`CLAUDE.md`의 `(TODO)` 채우기·필요 시 `ln -s CLAUDE.md AGENTS.md`) → Phase 1 기획으로 이어지는 3단계는 [`README.md`](README.md)의 "사용법"에 정리돼 있다. 본 문서는 그 3단계를 마쳤다는 전제에서, 헷갈리기 쉬운 placeholder 치환(2절)과 화면설계서 버전·형상 관리 라이프사이클(3절)을 다룬다. 기획 방법론 자체는 [`rules/methodology/README.md`](rules/methodology/README.md), 진척 확인은 `bash scripts/check-docs.sh`.

## 2. ★ placeholder 치환 가이드 (3종류 — 헷갈리기 쉬움)
킷에는 채워야 할 자리가 **세 종류**이며 치환 방식이 다르다.

### ① `(TODO …)` — 킷 본체 채움 (가장 많음)
환경 셋업·기획 문서 작성 시 채우는 원래 마커. **대부분이 여기.**
- 위치: `CLAUDE.md` · `rules/`(boundaries·commands·domain·architecture·ui·ux) · `docs/`(PRD·glossary·REQ·INDEX·SCR·TC·RELEASE·PRIVACY) · `ROADMAP.md`
- 찾기: `grep -rn "(TODO" CLAUDE.md rules/ docs/ ROADMAP.md`
- 진척: `bash scripts/check-docs.sh` §5가 남은 TODO 줄 수를 센다(0에 가까울수록 셋업 완료).

### ② `{프로젝트명}` 류 — 화면설계서 템플릿, 프로젝트당 1회
전부 `prototype/_template.designspec.html`에 있고, 템플릿을 도메인별로 복사할 때 채운다.
- 프로젝트 전역: `{프로젝트명}` `{영문명}` `{한 줄 정의}` `{핵심 목표 ①②③}` `{마일스톤}` `{단계별 일정}` `{연계…}` `{연동 사양}` `{출처…}` · 푸터 `{YYYY-MM-DD}`
- 화면별: `{화면명}` `{화면 목적}` `{원본ID}` `{해시}` `{역할 A/B}` `{케이스}` `{컴포넌트}` `{조건/결과}` `{실제 메시지 문구}` 등 (화면 .page 추가하며 채움)

### ③ `{DOMAIN}` / `{도메인}` — ⚠️ 전역 치환 아님, 만들 때마다
도메인(USER·ADMIN…)·화면을 **만들 때 그 파일에서만** 치환. `[{DOMAIN}] 화면설계서`, `SCR-{DOMAIN}-001`, `REQ-{DOMAIN}-0001`.
- **`scripts/new-domain.sh`가 ②③을 자동 처리** → 아래 3절.
- ⚠️ 안내 문서(`prototype/README.md`·`화면설계서-가이드.md`·`docs/README.md`·`INDEX.md`·`domains/_template.md`)의 `{DOMAIN}`/`{도메인}`은 **명명 규칙 설명**이라 그대로 둔다(치환하면 안내문이 깨짐).

## 3. 화면설계서 라이프사이클
```bash
# (1) 새 도메인 화면설계서 생성 — 템플릿 복사 + {DOMAIN}/{도메인} 자동 치환
bash scripts/new-domain.sh USER 사용자콘솔            # → prototype/user/[USER] 화면설계서.designspec.html
#   생성 후 남은 placeholder(②) 목록을 출력 → docs 기준으로 채운다.

# (2) 화면 작성 — VS Code로 .page 섹션(화면당 2p)을 추가하고 placeholder 채움
#     컨벤션: prototype/화면설계서-가이드.md (레이아웃·5섹션 구조)

# (3) PDF 빌드 (전달 필요 시점에만)
bash prototype/build-all.sh                          # 전부 → *_v0.1.pdf
bash prototype/build-all.sh v0.2                     # 버전 업

# (4) 정합성 검증
bash scripts/check-docs.sh                           # §8: 버전 라벨 정합·.baseline 무결성

# (5) 배포 후 다음 버전 라인 개시 (형상 관리)
bash scripts/release-cut.sh USER v0.2 v0.3           # 동결·baseline·라벨 치환·grep 검증 자동
```
- 버전 업데이트(요건·정책을 docs 거쳐 반영) = **절차 A**, 배포 후 버전 라인 분기 = **절차 B**. → `rules/methodology/change-management.md`.
- ★ 개정 이력 표·화면 상태 칩·푸터 날짜는 **기획자 직접 관리**(자동 변경 금지).

## 4. 스킬 (반복 프로세스 — 트리거 시 자동 제안)
스킬 목록과 트리거 문구는 [`CLAUDE.md`](CLAUDE.md)의 "Skills" 절이 단일 진실이다 — `release-cut` · `designspec-version-update` · `spec-self-review` · `spec-verify-loop` 네 가지. 위 3절의 라이프사이클이 각 스킬과 어떻게 맞물리는지만 여기서 짚는다(새 도메인 생성·버전업·릴리스 컷·검증).

## 5. 검증 한 줄
```bash
bash scripts/check-docs.sh      # 골격·자동 로드 체인·인덱스 정합·추적 끊김·화면설계서 버전 정합 → ALL GREEN
```
warning(CLAUDE.md 심링크·TODO 잔여·commands.md 미정)은 Phase 0/1 **진행 중 정상 신호** — 채워가면 ✓로 바뀐다.
