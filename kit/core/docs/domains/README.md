# domains/ — 도메인별 산출물 (대규모 분할용)

> REQ 가 50개를 넘거나 도메인이 3개 이상이 되면 단일 `REQ.md`·`POL.md`·`TC.md` 를 도메인별로 쪼갠다.
> 200+ 시점부터는 추가로 ID 네임스페이스를 도메인 prefix(`REQ-AUTH-####`)로 전환한다.
> 분할 정책: `../../rules/methodology/indexing.md` § 3 / prefix 전환: 같은 문서 § 1.2 · § 9

## 폴더 규칙
```
domains/
├── {도메인소문자}/
│   ├── REQ.md                          ← 이 도메인의 REQ-{DOMAIN}-#### 본문
│   ├── POL.md                          ← (도메인 전용 정책이 있을 때)
│   ├── SCR-{DOMAIN}-####.md            ← 이 도메인의 화면 (한 파일 = 한 화면)
│   ├── TC.md                           ← 이 도메인의 검증 시나리오
│   └── flows/FLOW-{DOMAIN}-####.md
```

파일명은 [`../README.md`](../README.md) 의 4분류 규칙을 따른다 — 약어는 대문자, 개별 항목은 ID 형식, 폴더명은 소문자.

도메인 이름은 `docs/glossary.md` 의 도메인 코드 표를 따른다 (단일 진실).

## 예시
```
domains/auth/REQ.md     → REQ-AUTH-0001 ~
domains/pay/REQ.md      → REQ-PAY-0001 ~
domains/search/REQ.md   → REQ-SEARCH-0001 ~
```

## 도메인 추가 절차
1. `docs/glossary.md` 에 도메인 코드 추가 (예: `AUTH` → 인증)
2. `domains/{이름}/REQ.md` 파일 생성 — 본 폴더의 [_template.md](./_template.md) 복사
3. `docs/INDEX.md` 에 해당 도메인 섹션 추가
4. `bash scripts/check-docs.sh` 로 정합성 확인
