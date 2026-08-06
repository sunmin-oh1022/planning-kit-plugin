# references/ — 이론 라이브러리 인덱스

이 폴더는 `ux-review` 스킬의 판단 근거가 되는 설계 이론과 리뷰 자산을 담는다. 스킬 본문(`../SKILL.md`)의 방법론은 이론 중립이고, "왜 그렇게 설계하나"의 근거는 전부 여기서 온다. 새 이론 추가 규약은 SKILL.md의 "이론 라이브러리 확장" 참조.

## 이론

| 파일 | 이론 | 지지하는 UX 차원 (review-checklist 기준) |
| --- | --- | --- |
| [`norman-ucsd-1986.md`](norman-ucsd-1986.md) | Norman — User Centered System Design (1986) | A 개념 모델 · B 실행 간극 · C 평가 간극 · E 기억 · F 중단 · G 선제적 도움 |
| [`norman-doet.md`](norman-doet.md) | Norman — The Design of Everyday Things | B 실행 간극(어포던스·시그니파이어·제약·매핑) · C 평가 간극(피드백) · D 오류(slip/mistake) · E 기억 |
| [`norman-emotional-design.md`](norman-emotional-design.md) | Norman — Emotional Design | H 감성 3수준(본능/행동/반성) |

## 리뷰·트렌드 자산 (이론 중립)

| 파일 | 용도 |
| --- | --- |
| [`review-checklist.md`](review-checklist.md) | 리뷰 모드 개념 층 점검표. **UX 차원별**(A~I)로 묶여 있고 각 항목이 이론을 인용한다. 새 이론은 여기에 새 섹션을 만들지 말고 해당 차원에 인용을 덧붙인다. |
| [`ux-trends-2026.md`](ux-trends-2026.md) | 2026 UX 트렌드 9가지를 이론으로 재해석. AI·개인화·멀티모달·크로스플랫폼 요소가 있을 때 읽는다. |

## 차원 축 (새 이론이 붙는 자리)

`review-checklist.md`의 차원은 이론가가 아니라 사용자 경험 기준으로 나뉜다. 이 축이 확장의 뼈대다.

- **A. 개념 모델 일관성** — 디자인/사용자 모델, 은유 충돌, 사용자 언어
- **B. 실행의 간극** — 시그니파이어, 매핑, 제약, 행동 비용
- **C. 평가의 간극** — 피드백, 상태 가시성, 완료 확신
- **D. 오류 설계** — undo, slip/mistake, 비난 없는 메시지
- **E. 기억 부담** — 재인 > 재생, 정보 이월
- **F. 중단 내성** — 입력 보존, 복귀 위치
- **G. 선제적 도움** — 엠프티 스테이트, 상황별 힌트
- **H. 감성 수준** — 본능/행동/반성, 다크 패턴
- **I. 현 시점 트렌드** — AI·에이전트·개인화·멀티모달·크로스플랫폼

> 예: Nielsen 10 휴리스틱을 추가하면 — "visibility of system status" → C, "error prevention" → D, "recognition rather than recall" → E 에 인용을 덧붙인다. 대개 새 차원은 필요 없다.
