# TC — 테스트 시나리오 / QA 체크리스트  [④ 검증]

> Given–When–Then 형식. 그대로 자동 테스트로 변환 가능.
> 요구사항·정책 ID와 연결하면 '이 요건이 검증됐는가'를 한눈에 추적.

## 기능 검증 — 자동 가능 (Core 단위 테스트)
| TC ID | 대상 REQ | Given (전제) | When (행동) | Then (결과) | 관련 정책 |
| --- | --- | --- | --- | --- | --- |
| *TC-001* | *REQ-001* | *(TODO)* | *(TODO)* | *(TODO)* | *POL-001* |
|  |  |  |  |  |  |

## 비기능 검증 예시
```
TC-101 (성능)
  Given  (TODO 측정 조건)
  When   (TODO 행동)
  Then   (TODO 임계값) 이내

TC-102 (접근성 — 사람 확인)
  Given  실환경에서 스크린리더 ON
  When   첫 셀에 포커스가 간다
  Then   "(TODO 의미 있는 라벨 순서)" 로 읽힌다

TC-103 (보안·오프라인 — 자동)
  Given  프로젝트 빌드 산출물
  When   grep -rE "fetch\(|http(s)?://|URLSession" (TODO 경로) 실행
  Then   매치 0건
```

> 사람 확인 항목(TC-102 등)은 실환경에서 확인 후 DEVLOG에 결과 기록.
