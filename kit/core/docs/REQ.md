# REQ — 요구사항 정의서  [③ 가이드]

> 기능·비기능 요건을 우선순위와 함께. 화면·정책·테스트와 ID로 추적.
> 우선순위 = MoSCoW: Must / Should / Could / Won't(이번 제외)
> **규모가 커지면(REQ 50개+) 도메인 분할로 전환 — 가이드: `rules/methodology/indexing.md`**

## 어디에 무엇이 있나
| 단계 | 사용 위치 |
| --- | --- |
| 소규모 (REQ ≤ 50, 단일 `REQ-###`) | 본 파일의 표를 그대로 사용 |
| 중간 (REQ 50~200) | 본 파일 표 + 항목마다 `### REQ-###` 헤더 규약 도입 → INDEX.md 손 유지 |
| 대규모 (REQ 200+) | 도메인별 분할 (`domains/{도메인}/REQ.md`) + 마스터 [INDEX.md](./INDEX.md) + 라벨 사전 [_labels.md](./_labels.md) |

분할 시점·임계값은 `rules/methodology/indexing.md` § 3 참조. 본 파일은 어느 시점에든 **진입 가이드** 로 남는다.

## 항목 헤더 규약 (필수 — INDEX 자동화의 전제)
본문에 항목을 추가할 때 다음 헤더 + 메타 라인을 둔다:
```markdown
### REQ-001 — 키워드 검색
- status: approved · priority: must · milestone: mvp · owner: @sunmin
- labels: #performance
- related: SCR-001, POL-001, TC-001
```
- `status`: draft / reviewed / approved / implementing / done / deprecated
- `labels`: `_labels.md` 에 등록된 것만
- `related`: 연결된 SCR·POL·TC ID (공백 후 쉼표 구분)

## 기능 요건 — 본문 표 (소·중규모)
| 요건 ID | 구분 | 요구사항명 | 상세 | 우선순위 | 상태 | 마일스톤 | 관련 화면·정책 | 검증(TC) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| *REQ-001* | *기능* | *키워드 검색* | *키워드 2자+ 입력 시 0.3초 내 결과 노출* | *must* | *approved* | *mvp* | *SCR-001 / POL-001* | *TC-001* |
|  |  |  |  |  |  |  |  |  |

### REQ-001 — 키워드 검색
- status: approved · priority: must · milestone: mvp · owner: *(TODO)*
- labels: #performance
- related: SCR-001, POL-001, TC-001
- 상세: *키워드 2자+ 입력 시 0.3초 내 결과 노출. glossary의 '키워드' 정의를 따른다.*

## 비기능 요건
| 요건 ID | 구분 | 요구사항명 | 상세 | 우선순위 | 상태 | 마일스톤 | 관련 화면·정책 | 검증(TC) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| *REQ-101* | *접근성* | *스크린리더 지원* | *모든 셀이 의미 있는 순서로 읽힘* | *must* | *approved* | *mvp* | *(전역)* | *TC-102* |
| *REQ-102* | *성능* | *응답 0.1초* | *주요 동작 0.1초 이내 UI 반영* | *must* | *approved* | *mvp* | *(전역)* | *TC-101* |
| *REQ-103* | *보안* | *외부 통신 0* | *빌드에 네트워크 코드 0건* | *must* | *approved* | *mvp* | *(전역)* | *TC-103* |

### REQ-101 — 스크린리더 지원
- status: approved · priority: must · milestone: mvp · owner: *(TODO)*
- labels: #accessibility
- related: TC-102

### REQ-102 — 응답 0.1초
- status: approved · priority: must · milestone: mvp · owner: *(TODO)*
- labels: #performance
- related: TC-101

### REQ-103 — 외부 통신 0
- status: approved · priority: must · milestone: mvp · owner: *(TODO)*
- labels: #security
- related: TC-103

> '관련 화면·정책'이 비어 있으면 그 요건은 아직 화면/정책 미정 — 마감 전 채운다.
> 본 파일의 모든 항목은 [INDEX.md](./INDEX.md) 에 한 줄씩 미러되어야 한다.
