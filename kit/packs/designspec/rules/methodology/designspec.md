# designspec.md — 화면설계서 제작 방법론 (rules측 진입점)

> 화면설계서(`*.designspec.html` → PDF)는 docs(SSOT)를 시각화한 **파생물**이다.
> 제작 컨벤션의 단일 진실 = [`prototype/화면설계서-가이드.md`](../../prototype/화면설계서-가이드.md) (재사용 킷, 레이아웃·CSS 고정값·빌드 상세).
> 본 문서는 **rules측 진입점** — '언제·어떤 순서로·어떤 규율로' 만드는가. 상세 제작법은 가이드로.

## 1. 산출물 관계 (단일 진실)
```
프로토타입(동작 검토)  →  docs(SSOT)  →  화면설계서(파생물)
   먼저 바뀔 수 있음      단일 진실        docs를 시각화
```
- **프로토타입** = 탐색·검토용 동작 HTML. 화면별 단위(`[D] 프로토타입_vX.Y.html`).
- **docs** = REQ·IA·POL·glossary·SCR·TC·FLOW. 모든 사실의 단일 진실.
- **화면설계서** = 도메인 멀티페이지(`[D] 화면설계서.designspec.html` → `_vX.Y.pdf`). docs를 mockup·정의·IA·권한표·용어로 시각화.

**핵심 규칙: 프로토타입에서 화면설계서로 바로 가지 않는다.** 새 요건·용어·정책은 반드시 docs를 경유한다([change-management.md](./change-management.md) 절차 A).

## 2. 문서 구조 (페이지 순서 — 가이드 §2 단일 진실)
표지 → 개요(PRD 기준) → **개정 이력(★기획자 직접 관리)** → IA → 공통 정의(권한·표시·메시지) → 화면별 2페이지.
- 화면 page1 = 목업 70% + Description 30%(번호 뱃지 ❶~ 1:1).
- 화면 page2 = 표준 5섹션 고정 순서: 기본 정보 → 컴포넌트 액션 정의 → 유효성·메시지 정의 → 상태 매트릭스 → 플로우.

## 3. 버전·형상 관리 (★ 본 방법론의 핵심 규율)
화면설계서는 버전을 타는 배포 산출물이다. 두 작업을 **혼동하지 않는다**:

| 작업 | 무엇 | 스킬 | 규칙 |
| --- | --- | --- | --- |
| **절차 A · 버전 업데이트** | docs 동기화 후 화면설계서 파생 | `designspec-version-update` | [change-management.md](./change-management.md) 절차 A |
| **절차 B · 릴리스 컷** | 배포 후 다음 버전 라인 분기·동결 | `release-cut` | 절차 B + `scripts/release-cut.sh` |

### ⚠️ 버전 라벨 치환 규칙 (블랭킷 치환 금지)
designspec의 `vX.Y`를 일괄 치환하면 역사 기록·화면 상태가 깨진다. **올릴 3종**(커버 칩·푸터 토큰·프로토타입 참조)과 **보존 4종**(상태 칩 `vX.Y · 개정`·인라인 역사 기록·파생 출처 주석·개정 이력 표)을 구분한다. 상세는 [change-management.md](./change-management.md).

## 4. 자동화·검증
- 버전 라인 개시: `bash scripts/release-cut.sh <DOMAIN> <from> <to>`
- PDF 빌드: `bash prototype/build-all.sh vX.Y`
- 정합성: `bash scripts/check-docs.sh` §8(화면설계서 버전 정합 — baseline 무결성·버전 라벨 정합)

## 5. 사람 / AI 경계
- 사람(기획자) = 개정 이력 표 행, 실제 개정 화면의 상태 칩, 카피·콘텐츠, 푸터 날짜 확정, 배포 결정.
- AI = docs 동기화, 라벨 치환(3종 한정), 동결·baseline 검증, PDF 빌드, 정합성 검증.

## 참고
- 제작 컨벤션 상세(레이아웃·CSS·빌드) → [`prototype/화면설계서-가이드.md`](../../prototype/화면설계서-가이드.md)
- 파일명·버전 매핑(프로토타입 ↔ 화면설계서) → [`prototype/README.md`](../../prototype/README.md)
- 형상 관리 절차 A/B → [change-management.md](./change-management.md)
