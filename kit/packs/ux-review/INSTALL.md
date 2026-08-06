# INSTALL — ux-review 팩 설치

> 전제: planning-kit **core**가 이미 설치된 프로젝트. 소요: 3분.

## 1. 파일 복사

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/ux-review

mkdir -p .claude/skills

cp -r "$PACK"/.claude/skills/ux-review  .claude/skills/
cp "$PACK"/docs/UX-REVIEW.md            docs/
```

## 2. CLAUDE.md 슬롯 채우기

`<!-- PACK-SLOT:skills -->` 아래에:
```markdown
- `ux-review` — 이론 근거 리뷰(개념 층) + 플로우 문서 항목별 대조(플로우 층). 결과는 `docs/UX-REVIEW.md`.
```

## 3. .gitignore 갱신

`docs/UX-REVIEW.md`는 개인 로그(공유 금지). `.gitignore` 하단에 추가:
```
# ux-review 팩 — 개인 UX 검토 로그 (공유 금지)
docs/UX-REVIEW.md
```

## 4. core rules/ux.md 슬롯 (선택)

core `rules/ux.md`는 이미 ux-review 스킬을 참조하는 문구가 있다. 팩 설치 후 자동 활성. 추가 편집 불필요.

## 5. 확인

- 새 세션에서 "UX 리뷰해줘" · "이 화면 사용성 점검" 트리거 → 스킬 자동 제안
- SCR/FLOW 문서에 `flow: <라벨>` 남기면 해당 플로우 규칙 자동 물음

## 제거

files 삭제 + CLAUDE.md·`.gitignore` 주입 라인 제거. `docs/UX-REVIEW.md`는 개인 로그라 백업 후 판단.
