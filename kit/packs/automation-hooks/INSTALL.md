# INSTALL — automation-hooks 팩 설치

> 전제: planning-kit **core**가 이미 설치된 프로젝트. 소요: 5분.

## 1. 훅 파일 복사

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/automation-hooks

mkdir -p .claude/hooks

cp "$PACK"/.claude/hooks/*.py .claude/hooks/
chmod +x .claude/hooks/*.py
```

## 2. .claude/settings.json 병합

**기존 파일이 없으면**:
```bash
cp "$PACK"/.claude/settings.snippet.json .claude/settings.json
```

**기존 파일이 있으면** `.claude/settings.json`을 열어 `hooks` 키만 병합 (다른 키는 보존). `snippet.json`의 hooks 3개 항목을 복사:
```json
{
  "hooks": {
    "PreToolUse":  [{ "matcher": "Bash|Edit|Write|MultiEdit", "hooks": [{ "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/.claude/hooks/pre-danger-guard.py\"" }] }],
    "PostToolUse": [{ "matcher": "Edit|Write|MultiEdit",       "hooks": [{ "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/.claude/hooks/post-edit-check.py\""  }] }],
    "Stop":        [{ "matcher": "",                            "hooks": [{ "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/.claude/hooks/stop-devlog.py\""      }] }]
  }
}
```

## 3. CLAUDE.md 슬롯 채우기

`<!-- PACK-SLOT:hooks -->` 아래에:
```markdown
- **PreToolUse — 위험 동작 차단**(`pre-danger-guard.py`): 버전 라벨 블랭킷 치환(`sed …/g`) · 동결본 `_vX.Y.{html,pdf}` 변경 · `.baseline/` 직접 손질 · 광범위 `rm -rf` 를 막는다. `release-cut.sh` 경유는 통과.
- **PostToolUse — 정합성 자동 검증**(`post-edit-check.py`): `docs/**.md` · 라이브 `prototype/**.designspec.html` 편집 직후 `scripts/check-docs.sh` 실행. FAIL 시 경고만 surface(흐름은 막지 않음).
- **Stop — DEVLOG 유도**(`stop-devlog.py`): 문서를 편집한 세션인데 `DEVLOG.md` 에 오늘 항목이 없으면 한 번 막고 작성을 유도한다.
```

## 4. 확인

- 새 Claude Code 세션 시작 → 훅 로드 (오류 없이 시작되면 OK)
- `sed 's/v0.1/v0.2/g'` 같은 위험 명령 시도 → `pre-danger-guard`가 차단
- `docs/PRD.md` 편집 후 저장 → `post-edit-check`가 자동으로 `check-docs.sh` 실행

## 제거

files 삭제 + `.claude/settings.json`의 hooks 키에서 3개 항목만 제거(다른 키 보존) + CLAUDE.md 3줄 제거.

## 주의

- **Python 3 필요** — `python3` 명령 접근 가능해야 함
- 훅이 오작동해 흐름을 막으면 `.claude/settings.json`에서 해당 훅 항목만 지우고 재시작
