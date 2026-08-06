#!/usr/bin/env bash
# docs/ 마크다운을 Confluence로 동기화합니다 (로컬 수동 실행).
#
# 사용법:
#   scripts/sync.sh                       # docs/ 전체 (재귀)
#   scripts/sync.sh docs/PRD.md           # 특정 파일
#   scripts/sync.sh docs/screens/SCR-*.md # 글롭
#   scripts/sync.sh --dry-run docs/PRD.md # 변환만, API 호출 없음
#
# frontmatter에 confluence.page_id가 비어있는 파일은 스크립트가 자동으로 건너뜁니다.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env.confluence.local"
VENV_PY="$ROOT/.venv-confluence/bin/python"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE 가 없습니다." >&2
  echo "  CONFLUENCE_BASE_URL / CONFLUENCE_USER_EMAIL / CONFLUENCE_API_TOKEN 3개를 채워주세요." >&2
  exit 1
fi

if [ ! -x "$VENV_PY" ]; then
  echo "ERROR: $VENV_PY 가 없습니다. venv 부트스트랩:" >&2
  echo "  python3 -m venv .venv-confluence && .venv-confluence/bin/pip install -r scripts/requirements.txt" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

cd "$ROOT"
if [ "$#" -eq 0 ]; then
  find docs -type f -name '*.md' -print0 \
    | xargs -0 "$VENV_PY" scripts/sync_confluence.py
else
  exec "$VENV_PY" scripts/sync_confluence.py "$@"
fi
