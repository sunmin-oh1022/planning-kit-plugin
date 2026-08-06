# flows/ — 플로우별 UX 규칙 문서

플로우 단위로 반복되는 사용성 규칙을 담는 폴더. 각 파일은 [`_template.md`](_template.md) 의 일곱 자리(해결 문제 · 필수 화면·단계 · 필수 상태 · 시간·순서 규칙 · 안티 패턴 · 접근성·다국어 · 검증 체크리스트) 를 통일해서 채운다.

플로우 무관 공통 원칙은 [`../common.md`](../common.md) 에.

## 파일 목록

| 파일 | 플로우 | 상태 |
| --- | --- | --- |
| [`login.md`](login.md) | 로그인 | (파일럿) |
| [`signup.md`](signup.md) | 회원가입 | 예정 |
| [`mypage.md`](mypage.md) | 마이페이지 | 예정 |
| [`payment.md`](payment.md) | 결제 | 예정 |

## SCR / FLOW 문서와의 연결

SCR 또는 FLOW 문서 상단에 플로우 라벨을 남기면 [`ux-review`](../../../.claude/skills/ux-review/SKILL.md) 스킬이 해당 규칙 문서를 자동으로 물어 항목별로 대조한다(플로우 층). 라벨은 파일명(확장자 제외) 을 그대로 쓴다.

```md
---
scr: SCR-USER-001
flow: login
---
```

## 새 플로우 추가

1. `_template.md` 를 복사해 파일명을 정한다 (`kebab-case`, 단어 사이에 하이픈).
2. 일곱 자리를 채운다. 채우지 않는 자리는 "해당 없음"으로 명시 (자리를 지우지 않는다).
3. 위 파일 목록에 한 줄 추가.
4. SCR/FLOW 문서에 플로우 라벨을 남긴다.
