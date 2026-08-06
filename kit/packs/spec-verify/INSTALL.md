# INSTALL — spec-verify 팩 설치

> 전제: planning-kit **core**가 이미 설치된 프로젝트. 소요: 5분.

## 1. 파일 복사

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/spec-verify

mkdir -p .claude/skills .claude/workflows

cp -r "$PACK"/.claude/skills/spec-self-review    .claude/skills/
cp -r "$PACK"/.claude/skills/spec-verify-loop    .claude/skills/
cp -r "$PACK"/.claude/skills/intent-capture      .claude/skills/
cp "$PACK"/.claude/workflows/spec-verify-loop.js .claude/workflows/
cp "$PACK"/docs/REVIEW.md                        docs/
```

## 2. CLAUDE.md 슬롯 채우기

`<!-- PACK-SLOT:skills -->` 아래에:
```markdown
- `spec-self-review` — 마감 전 기획 문서 셀프 검토(Phase 2) + 정합성 검증.
- `spec-verify-loop` — 도메인/버전 사이클 검증 루프. 7축 멀티에이전트 교차검증 + 적대적 환각 제거.
- `intent-capture` — 말 한 줄짜리 아이디어를 구조적 Q&A로 되물어 docs 초안화(Phase 1 앞단).
```

## 3. 확인

- 새 Claude Code 세션에서 "검증 루프 돌려줘" · "이 기능 구체화해줘" · "셀프 검토" 트리거 → 스킬 자동 제안
- `docs/REVIEW.md` 존재 확인

## 제거

files 목록의 dst 경로 삭제 + CLAUDE.md 3줄 제거. `docs/REVIEW.md`는 누적 검토 기록물이라 보존 권장.
