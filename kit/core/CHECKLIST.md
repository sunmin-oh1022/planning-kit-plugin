# 환경 셋업 체크리스트 — 새로 시작할 때 (Phase 0, 프로젝트당 1회)

> 본 파일이 환경 셋업 **실행 체크리스트의 단일 진실**. 방법론 맥락(6 Phase·5대 원리)은 `rules/methodology/README.md`.

- [ ] AI 코딩 에이전트 설치·로그인 (Claude Code 등)
- [ ] (IDE 사용 시) 에디터에 에이전트 연동
- [ ] Git 비공개 저장소 생성 + 첫 커밋
- [ ] 프로젝트를 'Core(순수 로직) / App(UI)' 두 레이어로 분리
- [ ] 진입점(CLAUDE.md / CLAUDE.md) 정리 — 항상 읽을 규칙만 import + Rule Index
- [ ] rules/ 규칙 모듈 작성 — 항상 적용(behavior·boundaries) / 작업별(나머지)
- [ ] 가드레일 정리 — boundaries.md 의 금지 + 대안 + 이유 표
- [ ] 번호 가이드 정리 — #1, #2 … 형태 ("#3 위반"처럼 짧게 지적용)
- [ ] 1초 검증 명령 확정 (rules/commands.md) — 예: `npm test` / `pytest -q` / `go test ./...` / `swift test`
- [ ] 사람/AI 검증 경계 명문화 (rules/ui.md)
- [ ] DEVLOG.md / HISTORY.md / SHARE.md 만들고 커밋
