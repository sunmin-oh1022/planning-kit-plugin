# INSTALL — confluence-sync 팩 설치

> 전제: planning-kit **core** 설치된 프로젝트. Python 3 사용 가능. Confluence Cloud API 토큰 발급 완료.

## 1. 파일 복사

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/confluence-sync

cp "$PACK"/scripts/sync.sh              scripts/
cp "$PACK"/scripts/sync_confluence.py   scripts/
cp "$PACK"/scripts/requirements.txt     scripts/
cp "$PACK"/.env.confluence.example      ./
chmod +x scripts/sync.sh
```

## 2. Python 의존성 설치

```bash
pip install -r scripts/requirements.txt
```

## 3. 로컬 시크릿 설정

```bash
cp .env.confluence.example .env.confluence.local
# 편집기로 .env.confluence.local 열어서 아래 4개 값 입력:
#   CONFLUENCE_URL=https://your-org.atlassian.net/wiki
#   CONFLUENCE_USER=you@example.com
#   CONFLUENCE_API_TOKEN=<Atlassian API token>
#   CONFLUENCE_SPACE_KEY=<space key>
```

## 4. .gitignore 확인

`.env.confluence.local`이 반드시 `.gitignore`에 있어야 함 (API 토큰 유출 방지).

## 5. 첫 동기화

```bash
bash scripts/sync.sh
```

## 제거

파일 삭제 + `.env.confluence.local`은 개인 시크릿이라 백업 후 판단.
