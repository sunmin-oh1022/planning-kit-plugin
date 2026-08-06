# packs/automation-hooks — 훅 자동화 팩

> boundaries.md #5("반드시 지킬 규칙은 기계 강제와 짝짓는다")의 실행체. 세 개 훅으로 위험 동작 차단·정합성 자동 검증·DEVLOG 유도.

## 이 팩이 필요한 경우

- 규칙만 문서로 두면 지나쳐지므로 기계로 강제하고 싶다
- 편집 직후 정합성 검증(`check-docs.sh`)을 자동으로 돌리고 싶다
- 세션 끝에 DEVLOG 안 남기고 나가는 걸 막고 싶다

## 무엇이 들어 있나

| 훅 | 언제 | 무엇을 |
| --- | --- | --- |
| `pre-danger-guard.py` | Bash·Edit·Write 직전 | 버전 라벨 블랭킷 치환·동결본 변경·`.baseline/` 직접 손질·광범위 `rm -rf` 차단 |
| `post-edit-check.py` | Edit·Write 직후 | `docs/**.md`·라이브 designspec 편집이면 `check-docs.sh` 실행 (FAIL 시 경고) |
| `stop-devlog.py` | 세션 종료 시 | 문서 편집 세션인데 오늘자 DEVLOG 항목 없으면 한 번 막음 |

## designspec 팩과의 관계

`pre-danger-guard.py`는 designspec 팩의 형상관리 불변식(동결본 `_vX.Y.{html,pdf}` · `.baseline/`)을 검사한다. designspec 팩 없이도 훅은 동작(다른 위험 동작만 감지)하지만, **designspec 팩과 함께 쓸 때 실효 최대**.

## 설치

→ [`INSTALL.md`](./INSTALL.md)
