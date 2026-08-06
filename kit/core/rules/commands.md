# commands.md — 빌드/테스트/린트 (빌드·테스트 시 읽기)

> 1초 검증의 핵심. 스택에 맞게 채운다. 빌드·테스트 방법을 가장 앞에 둔다.
> **모든 명령은 프로젝트 루트에서 실행한다.** (cd로 cwd 옮기지 말 것)

```bash
# 1초 검증 (순수 로직)
(TODO)   # 예: npm test   /   pytest -q   /   go test ./...   /   cargo test   /   swift test

# 외부 통신 코드 0건 가드 (보안 비기능 — REQ-103 / TC-103)
# 매치 0건일 때 grep는 exit 1을 내므로 || 로 흡수
grep -rE --include='*.(TODO 확장자)' 'fetch\(|http(s)?://|URLSession|XMLHttpRequest' (TODO Core 경로) (TODO App 경로) \
  && { echo '✗ 실패 — 외부 통신 코드 발견'; exit 1; } \
  || echo '✓ 통과 (매치 0건)'

# 데모/시나리오 콘솔 확인
(TODO)   # 예: node scripts/demo.js   /   python -m pkg.demo   /   swift run <Demo>

# 린트 / 타입체크
(TODO)   # 예: npm run lint   /   ruff check .   /   tsc --noEmit   /   swiftformat .

# 한방 정합성 검증 — 스타터킷 골격·자동 로드 체인·심링크·methodology 링크·TODO 잔여
# 프로젝트별 빌드·테스트 명령이 정해지면 scripts/check-docs.sh 의 섹션 6 에도 추가한다.
bash scripts/check-docs.sh
```

- 진행을 **테스트 건수**로 추적한다 (예: 12 → 15건).
- 실패하면 AI가 스스로 수정 후 재검증한다.
- 큰 작업 전후로 `bash scripts/check-docs.sh` — 종료코드 0 이면 ALL GREEN.
