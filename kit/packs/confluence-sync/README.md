# packs/confluence-sync — Confluence 위키 동기화 팩

> 로컬 docs를 사내 Confluence 위키에 자동 동기화. 다른 팩과 독립 (주입 슬롯 없음).

## 이 팩이 필요한 경우

- 사내 위키(Confluence)에 기획 문서를 반영해야 한다
- 로컬 편집 → Confluence 페이지가 수동 복붙으로 관리되고 있어 자꾸 어긋난다

필요 없으면 이 팩은 안 깔면 됨. planning-kit core 기능에 전혀 영향 없음.

## 무엇이 들어 있나

| 파일 | 내용 |
| --- | --- |
| `scripts/sync.sh` | 진입 스크립트 (환경변수 로드 후 sync_confluence.py 실행) |
| `scripts/sync_confluence.py` | Confluence REST API 클라이언트 |
| `scripts/requirements.txt` | Python 의존성 |
| `.env.confluence.example` | 설정 템플릿 (URL·USER·API_TOKEN·SPACE_KEY) |

## 의존성

- **Python 3** + `pip install -r scripts/requirements.txt`
- **Confluence Cloud API 토큰** — [Atlassian 계정 → Security → API tokens](https://id.atlassian.com/manage-profile/security/api-tokens)

## 설치

→ [`INSTALL.md`](./INSTALL.md)
