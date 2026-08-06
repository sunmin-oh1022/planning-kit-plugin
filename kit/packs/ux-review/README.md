# packs/ux-review — 이론 기반 UX 리뷰 팩

> planning-kit core의 `rules/ux/`(공통 원칙 + 플로우별 규칙)에 **이론 근거 리뷰**를 얹는 스킬 팩. Norman의 DOET·UCSD·감성디자인을 references로 상비해두고 스킬이 참조.

## 이 팩이 필요한 경우

- 화면·플로우 결정에 "왜 그런지" 이론 근거를 대고 싶다
- 마감 전 UX 검토를 매번 손으로 프롬프트 짜기 힘들다
- SCR/FLOW 문서에 `flow: <라벨>` 만 남기면 자동으로 해당 플로우 규칙을 물어주면 좋겠다

## 무엇이 들어 있나

| 경로 | 내용 |
| --- | --- |
| `.claude/skills/ux-review/SKILL.md` | 스킬 진입점 (개념 층 리뷰 + 플로우 층 리뷰) |
| `.claude/skills/ux-review/references/_index.md` | 이론 라이브러리 인덱스 |
| `.claude/skills/ux-review/references/norman-doet.md` | Norman 《The Design of Everyday Things》 요약 |
| `.../references/norman-ucsd-1986.md` | User-Centered System Design (1986) 원리 |
| `.../references/norman-emotional-design.md` | 《Emotional Design》 3층 모형 |
| `.../references/review-checklist.md` | 이론-중립 리뷰 체크리스트 |
| `.../references/ux-trends-2026.md` | 최근 트렌드 참고 (2026) |
| `docs/UX-REVIEW.md` | 검토 결과 개인 로그 템플릿 (`.gitignore`에 자동 추가) |

## 이론 중립 방법론

스킬 자체는 특정 이론에 종속되지 않는다. references/는 **이론 라이브러리**로 상비돼 있고, 스킬이 상황에 맞는 이론을 인용해 근거 제시. 새 이론이 추가돼도 스킬명·트리거·rules/ux 경계는 안 바뀜.

## rules/ux 와의 관계

- **개념 층 (스킬 자체)** — Norman 등 이론 근거로 화면·상호작용 원리 리뷰
- **플로우 층 (rules/ux/flows/)** — 플로우별(로그인·결제 등) 필수 화면·상태·시간 규칙 대조. SCR/FLOW 문서에 `flow: <라벨>` 만 남기면 자동 매칭.

## 설치

→ [`INSTALL.md`](./INSTALL.md)
