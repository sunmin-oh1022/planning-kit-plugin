---
name: spec-verify-loop
description: 한 기획 사이클(요구사항→프로토타입→docs→화면설계서)을 돈 뒤 그 도메인이 정상적으로 진행됐는지 멀티에이전트로 자동 교차검증하는 검증 루프(방법론 Phase 2/4의 자동·도메인범위 상위호환). "검증 루프 돌려줘", "교차검증 해줘", "도메인 검증 loop", "반복 검증", "사이클 검증", "이 도메인 제대로 됐는지 봐줘" 류 요청에 사용. 기계검증(check-docs.sh) + 7축 셀프검토를 병렬 탐지하고, 각 지적을 3개 회의자가 적대적으로 반증해 환각을 제거한 뒤, 등급(🔴🟡🟢)·수정안과 함께 docs/REVIEW.md에 일자별 누적 기록한다. 탐지·제안만 하고 docs는 수정하지 않는다. 단일 패스 수동 점검은 spec-self-review, 배포 후 형상 관리는 release-cut.
---

# spec-verify-loop — 도메인/버전 검증 루프 (멀티에이전트 교차검증)

> 단일 진실: [`rules/methodology/README.md`](../../../rules/methodology/README.md) **Phase 2(셀프 검토)·Phase 4(검증 루프)**.
> 엔진: Workflow `spec-verify-loop` ([`.claude/workflows/spec-verify-loop.js`](../../workflows/spec-verify-loop.js)).
> 핵심: 사람이 매번 셀프검토 프롬프트를 손으로 돌리는 대신, **여러 에이전트가 7축을 병렬 점검 → 각 지적을 적대적으로 교차검증해 환각을 제거 → 등급·수정안 제시**. **탐지·제안만 한다 — docs는 사람이 고친다.**

## 언제
- 한 사이클(요구사항 분석 → 프로토타입 → docs → 화면설계서)을 한 바퀴 돈 **직후**, 그 도메인이 정상적으로 진행됐는지 게이트로 확인할 때.
- 마감 전 품질 게이트. 사이클 단위 = **도메인/버전**.
- 가벼운 단일 패스 수동 점검이면 [`spec-self-review`](../spec-self-review/SKILL.md), 배포 후 버전 형상 관리면 [`release-cut`](../release-cut/SKILL.md).

## 절차
### 1. 대상 확정
검증할 **도메인**(예: USER·ADMIN)을 확인한다. 미지정이면 사용자에게 묻는다(추측 금지). 버전(`vX.Y`)·깊이는 선택:
- `thoroughness: "normal"`(기본) — 7축 1라운드.
- `thoroughness: "deep"` — 7축 loop-until-dry(최대 4라운드, 2라운드 연속 신규 0이면 종료). "반복 검증"을 더 깊게.

### 2. 워크플로 호출
```
Workflow({ name: "spec-verify-loop", args: { domain: "USER", version: "v0.2", thoroughness: "normal" } })
```
워크플로가 3개 phase를 돈다:
1. **기계검증** — `scripts/check-docs.sh` 실행·파싱(ID·INDEX·추적·버전 정합).
2. **교차검증** — 7축(미정의 용어·문서 간 모순·빠진 상태·빠진 범위·검증불가 표현·빠진 비기능·추적 끊김) 병렬 탐지.
3. **적대적 검증** — 지적마다 3개 독립 회의자(근거-존재·단일진실-위반·추적-실재)가 반증 시도, 과반(≥2)이 real 이어야 확정. 환각 제거.

반환: `{ verdict, machineGate, summary{red,yellow,green,confirmed,dropped}, confirmed[], dropped[] }`.

### 3. docs/REVIEW.md 에 일자별 누적 기록
반환 리포트를 `docs/REVIEW.md`(없으면 생성)에 **오늘 날짜 + 도메인/버전 섹션**으로 추가한다. 기존 spec-self-review 포맷·등급 체계를 그대로 따른다:
- 헤더: `## YYYY-MM-DD — {도메인}{/버전} 검증 루프 (verdict)`
- 기계검증 요약(fails/warns 건수), 확정 지적 표: `등급 | 축 | 파일:줄 | 사유 | 수정안 | 상태`.
- 등급 🔴 결정 필요 / 🟡 보강 / 🟢 경미. 처리되면 상태를 🟩 로 갱신(다음 회차에 사람이).
- 환각 제거된 `dropped` 는 건수만 적어 신뢰도 신호로 남긴다(전체 나열 안 함).

### 4. 사용자 보고
- `verdict` 한 줄(GREEN / 사람 결정 필요 N건 / 보강·경미 N건)을 먼저.
- **🔴 항목을 요약 surface** 하고 다음 액션(사람 판단 필요)을 안내한다.
- 🟡·🟢 의 수정안은 REVIEW.md 에 있으니 "적용은 기획자가 결정"임을 명시.

## 경계 (사람 vs AI)
- **AI** = 기계검증 + 7축 탐지 + 적대적 교차검증(환각 제거) + REVIEW.md 기록.
- **사람(기획자)** = 🔴 결정, 수정안의 실제 적용(docs 편집), 카피·콘텐츠.
- **docs(REQ·POL·SCR·TC·glossary…)를 자동 수정하지 않는다.** 추측으로 빈칸을 메우지 않고, 근거 약한 지적은 적대 단계에서 버려진다.

## spec-self-review 와의 관계
| | spec-self-review | spec-verify-loop |
| --- | --- | --- |
| 방식 | 단일 에이전트·수동 1패스 | 멀티에이전트·적대적 교차검증 |
| 범위 | 전체 docs | 도메인/버전 |
| 환각 제거 | 없음 | 3-회의자 과반 반증 |
| 출력 | docs/REVIEW.md | docs/REVIEW.md (동일·공유) |

둘 다 같은 7축·등급 체계·REVIEW.md 를 공유한다. verify-loop 는 self-review 의 자동·도메인범위 상위호환.
