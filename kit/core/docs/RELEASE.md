# RELEASE — (TODO 제품 이름) v(TODO 버전)

> 출시 운영용 사람-읽기 노트. 기능·정책은 `docs/` 의 단일 진실 참조 (ID 만 적고 중복 금지).
> 변경 이력 자체는 `HISTORY.md`, 외부 기능 공지는 `SHARE.md`. (역할 지도: `rules/methodology/README.md`)

## 한 줄
(TODO 제품 한 줄 요약 — PRD 와 일치)

## 출시 범위
- **In scope**: (TODO REQ-### 묶음) → `docs/REQ.md`
- **Out of scope · 다음 버전 후보(Backlog) · 핵심 차별점**: → `docs/PRD.md`

## 빌드 메타데이터 ((TODO 빌드 시스템 파일) 가 단일 진실)
| 키 | 값 |
| --- | --- |
| 표시 이름 (Display Name) | (TODO) |
| 식별자 (Bundle ID / Package / Domain 등) | (TODO) |
| 마케팅 버전 | (TODO) |
| 빌드 번호 / 리비전 | (TODO) |
| 타깃 환경·최소 사양 | (TODO 예: OS 최소 버전 / 브라우저 / 런타임) |
| 배포 채널 | (TODO 예: 스토어·웹 호스팅·패키지 레지스트리·내부 배포) |

## 출시 전 사람-결정 체크리스트 (`rules/ui.md` 의 사람 영역)
- [ ] 브랜드 자산 (로고·아이콘·OG 이미지 등 채널별 사이즈 세트)
- [ ] 채널 메타데이터 (이름·설명·키워드·카테고리·미리보기 이미지)
- [ ] 개인정보 처리방침 호스팅 — `./PRIVACY.md` 검토·문의 이메일 확정 후 공개 URL 확보
- [ ] 약관·라이선스·고지 사항
- [ ] 베타 테스트 / 내부 검증 통과 후 정식 배포 승인
- [ ] 배포 채널 업로드 / 공개

## 출시 전 AI-검증 체크리스트 (`rules/ui.md` 의 AI 영역)
- [ ] (TODO) 1초 검증 명령 그린 — `rules/commands.md` 의 빌드·테스트 명령
- [ ] (TODO) 배포 빌드 가드 그린 — Release/Production configuration
- [ ] `bash scripts/check-docs.sh` ALL GREEN
- [ ] (TODO) 외부 통신·보안 가드 통과 (TC-103 류)
- [ ] PRD 마감 체크리스트 통과 (`rules/methodology/README.md` 의 마감 체크리스트)
- [ ] 사람 실환경 확인 통과
- [ ] `rules/ux.md` 디자인 원칙 8개 자체 검증·발견 처리 완료
