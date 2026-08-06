# _labels.md — 라벨 사전 (단일 진실)

> 횡단 관심사(cross-cutting concern)를 표현하는 태그. 도메인·상태·우선순위·마일스톤으로 이미 표현되는 건 라벨로 쓰지 않는다.
> 운영 규칙: `rules/methodology/indexing.md` § 7

## 등록된 라벨
| 라벨 | 의미 | 영향받는 문서 | 비고 |
| --- | --- | --- | --- |
| `#performance` | 응답 시간·처리량 임계값에 영향 | REQ · TC · POL | 수치 기준은 PRD 비기능 |
| `#accessibility` | 스크린리더·키보드·색대비 등 접근성 | REQ · SCR · TC | TC 는 사람 확인 포함 |
| `#security` | 인증·인가·민감정보·외부 통신 | REQ · POL · TC | 외부 통신은 POL 로도 금지 가능 |
| `#i18n` | 다국어·로케일·시간대 | REQ · SCR · glossary | 표기 변형은 glossary |
| `#legal-compliance` | 법·규제 준수 (개인정보·약관 등) | POL · PRIVACY | 사유 칸에 근거 명시 |
| `#analytics-event` | 행동 로그·이벤트 발화 지점 | REQ · SCR | 이벤트명은 glossary |
| `#payment-flow` | 결제 흐름 횡단 | REQ · POL · FLOW | 금액·통화는 glossary |

## 새 라벨 추가 규칙
1. 본 표에 한 줄 추가 (의미·영향 문서·비고)
2. 추가 PR 의 commit message 에 `chore: add label #xxx`
3. 추가 후 첫 사용 항목에서 잘 작동하는지 확인 — 검색·필터로 모이는지

## 금지 라벨 (이미 다른 축에 있음)
- `#must` `#should` `#could` `#wont` → priority 필드 사용
- `#mvp` `#v1` → milestone 필드 사용
- `#draft` `#done` → status 필드 사용
- `#auth` `#pay` 같은 도메인 이름 → 도메인 prefix(REQ-AUTH-...) 로 표현
