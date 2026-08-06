# INDEX — 요구사항 마스터 인덱스

> **검색·추적 전용 한 줄 인덱스** (사람 읽기용 본문은 [REQ.md](./REQ.md) 또는 `domains/{도메인}/REQ.md`).
> 한 항목 = 한 줄. 멀티라인 셀 금지 — `scripts/check-docs.sh` 가 본문↔인덱스 동기화·중복 ID·끊긴 추적을 검사한다.
> 작성 규칙: `rules/methodology/indexing.md` § 4

## 갱신 방법
1. 본문(REQ.md 또는 domains/.../REQ.md)에 항목 추가/수정
2. 본 INDEX 의 해당 행 갱신 (같은 커밋에서)
3. `bash scripts/check-docs.sh` 통과 확인

> 항목이 200개를 넘기 시작하면 `scripts/build-index.sh` 류로 자동 생성 전환을 검토. 본문이 단일 진실인 것은 변하지 않음.

## 기능 요건
| ID | 제목 | 도메인 | 상태 | 우선순위 | 마일스톤 | 소유자 | 라벨 | 파일 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | 키워드 검색 | - | approved | must | mvp | *(TODO)* | #performance | [REQ.md#req-001](./REQ.md#req-001--키워드-검색) |

## 비기능 요건
| ID | 제목 | 도메인 | 상태 | 우선순위 | 마일스톤 | 소유자 | 라벨 | 파일 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-101 | 스크린리더 지원 | - | approved | must | mvp | *(TODO)* | #accessibility | [REQ.md#req-101](./REQ.md#req-101--스크린리더-지원) |
| REQ-102 | 응답 0.1초 | - | approved | must | mvp | *(TODO)* | #performance | [REQ.md#req-102](./REQ.md#req-102--응답-01초) |
| REQ-103 | 외부 통신 0 | - | approved | must | mvp | *(TODO)* | #security | [REQ.md#req-103](./REQ.md#req-103--외부-통신-0) |

## Deprecated (결번 유지 — 재사용 금지)
| ID | 제목 | 폐기 일자 | 후속 ID | 사유 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

---

## 도메인 prefix 전환 후 (REQ 200+ 도입 시 예시)
> 단일 prefix(`REQ-###`) → 도메인 prefix(`REQ-AUTH-####`) 로 마이그레이션할 때 본 인덱스를 도메인별 섹션으로 재편한다. 일괄 전환은 한 커밋으로 끝내고 DEVLOG 에 기록.

```
### AUTH 도메인
| REQ-AUTH-0001 | 이메일 로그인 | AUTH | approved | must | mvp | @sunmin | #security | domains/auth/REQ.md#req-auth-0001 |

### PAY 도메인
| REQ-PAY-0001 | 카드 결제 | PAY | draft | must | v1.0 | @sunmin | #payment-flow | domains/pay/REQ.md#req-pay-0001 |
```

도메인 코드는 `docs/glossary.md` 의 단일 진실을 따른다.
