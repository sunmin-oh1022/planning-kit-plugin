# INSTALL — decision-log 팩 설치

> 전제: planning-kit **core**가 이미 설치된 프로젝트. 소요: 3분.

## 0. 자동 설치 (권장)

```bash
python3 /path/to/planning-kit/tools/kit-install pack decision-log <project-dir>
```

## 1. 수동 설치 — 파일 복사

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/decision-log

mkdir -p .claude/skills docs/meetings

cp -r "$PACK"/.claude/skills/decision-sync  .claude/skills/
cp "$PACK"/docs/DECISIONS.md                docs/
cp "$PACK"/docs/meetings/README.md          docs/meetings/
```

## 2. CLAUDE.md 슬롯 채우기

`<!-- PACK-SLOT:skills -->` 아래에:
```markdown
- `decision-sync` — 회의록·일정 문서에서 결정을 추출해 `docs/DECISIONS.md`(의사결정 단일 진실) 갱신. "결정 반영", 회의록 저장 직후.
```

## 3. 기존 프로젝트에 도입하는 경우 (마이그레이션)

이미 미결 항목이 흩어져 있다면 첫 실행에서 일괄 이관한다:
```
"POL/REQ의 (협의 필요), ROADMAP §6, REVIEW의 🔴 미결, 회의록 추적표를 훑어서
DECISIONS.md로 이관해줘. 결정권자·기한 빈 건 물어봐."
```
기존 회의록·일정 문서는 `docs/meetings/`로 모으고(파일명 `YYYY-MM-DD_제목.md`), 이후 원본 수정 금지.

## 4. 확인

- 새 세션에서 "결정 반영" · "요즘 뭐가 미결이지?" 트리거 → `decision-sync` 자동 제안
- `docs/DECISIONS.md` · `docs/meetings/README.md` 존재 확인

## 제거

files 목록의 dst 경로 삭제 + CLAUDE.md 1줄 제거. `DECISIONS.md`·`meetings/`는 의사결정 이력이라 보존 강력 권장.
