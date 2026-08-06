# packs/spec-verify — 기획 문서 검증 자동화 팩

> planning-kit core의 **Phase 2(셀프 검토)·Phase 4(구현·검증 루프)** 를 도구화. 사람이 매번 셀프검토 프롬프트를 손으로 돌리는 대신 스킬 트리거로 실행.

## 이 팩이 필요한 경우

- 문서 마감 전 셀프 검토를 매번 손으로 돌리기 힘들다
- REQ ↔ SCR ↔ TC 추적 끊김·미정의 용어·검증불가 표현 같은 7축 점검을 자동화하고 싶다
- 도메인/버전 사이클 단위로 여러 에이전트가 교차검증(환각 제거)해주면 좋겠다
- 말 한 줄짜리 아이디어를 구조적 질문으로 되물어 docs 초안까지 만들고 싶다

## 무엇이 들어 있나

| 경로 | 내용 |
| --- | --- |
| `.claude/skills/spec-self-review/` | 단일 에이전트 · 수동 1패스 셀프 검토 (가벼운 마감 점검) |
| `.claude/skills/spec-verify-loop/` | 멀티에이전트 교차검증 (7축 병렬 탐지 + 3-회의자 적대적 반증 + 등급·수정안) |
| `.claude/skills/intent-capture/` | 말 한 줄 → AskUserQuestion 웨이브 → docs 초안(draft) 자동 정리 (Phase 1 앞단) |
| `.claude/workflows/spec-verify-loop.js` | verify-loop 엔진 (Workflow 스크립트) |
| `docs/REVIEW.md` | 검토 기록 템플릿 (스킬 실행 결과가 일자별로 누적) |

## 스킬 비교

| | spec-self-review | spec-verify-loop | intent-capture |
| --- | --- | --- | --- |
| 언제 | 마감 전 가벼운 훑기 | 도메인/버전 사이클 완료 후 | 아이디어 있고 docs 초안 없을 때 |
| 방식 | 단일 에이전트 · 1패스 | 멀티에이전트 · 적대적 교차검증 | AskUserQuestion 웨이브 |
| 범위 | 전체 docs | 도메인/버전 | 새 기능·새 도메인 |
| 환각 제거 | 없음 | 3-회의자 과반 반증 | 사람 답변 기반이라 무관 |
| 출력 | docs/REVIEW.md | docs/REVIEW.md | REQ·POL·SCR draft |

셋 다 planning-kit core의 **5대 원리**(단일 진실·ID 추적·모든 상태·Out of scope·GWT)를 검증 축으로 사용.

## 설치

→ [`INSTALL.md`](./INSTALL.md)
