# INSTALL — designspec 팩 설치

> 전제: planning-kit **core**가 이미 설치된 프로젝트.
> 소요: 10~20분 (플레이스홀더 치환 포함)

## 1. 파일 복사

프로젝트 루트에서:

```bash
KIT=/path/to/planning-kit
PACK="$KIT"/packs/designspec

# rules
cp "$PACK"/rules/methodology/change-management.md  rules/methodology/
cp "$PACK"/rules/methodology/designspec.md         rules/methodology/

# skills
mkdir -p .claude/skills
cp -r "$PACK"/.claude/skills/designspec-version-update  .claude/skills/
cp -r "$PACK"/.claude/skills/release-cut                .claude/skills/

# prototype kit
mkdir -p prototype
cp "$PACK"/prototype/_template.designspec.html  prototype/
cp "$PACK"/prototype/build-all.sh               prototype/
cp "$PACK"/prototype/build-pdf.sh               prototype/
cp "$PACK"/prototype/화면설계서-가이드.md          prototype/
cp "$PACK"/prototype/README.md                  prototype/

# scripts
cp "$PACK"/scripts/release-cut.sh  scripts/
chmod +x prototype/*.sh scripts/release-cut.sh
```

> Checkpoint 3에서 `tools/kit-install pack designspec` 명령으로 자동화 예정. 그 전까지는 위 수동 절차 사용.

## 2. 진입점(CLAUDE.md) 슬롯 채우기

core `CLAUDE.md`의 두 마커 **아래에** 아래 라인을 추가:

**`<!-- PACK-SLOT:rule-index -->` 아래:**
```markdown
- **화면설계서 제작·버전 → `rules/methodology/designspec.md`** (designspec 작성·버전·형상 관리)
```

**`<!-- PACK-SLOT:skills -->` 아래:**
```markdown
- `release-cut` — 배포 후 다음 버전 라인 개시(형상 관리·절차 B). "vX 배포했고 다음 버전으로".
- `designspec-version-update` — docs 동기화 후 화면설계서 버전 업데이트(절차 A).
```

## 3. check-docs.sh 는 자동 활성 ✅

core `scripts/check-docs.sh`의 §8("화면설계서 버전 정합")은 `prototype/*.designspec.html`이 존재하면 **자동 실행**. 별도 설치 필요 없음.

빌드 통과 확인:
```bash
bash scripts/check-docs.sh
```

## 4. 템플릿 플레이스홀더 치환 ★

`prototype/_template.designspec.html`의 `{{...}}`를 프로젝트 값으로 치환:

| 플레이스홀더 | 넣을 값 |
| --- | --- |
| `{{PROJECT_NAME}}` / `{{PROJECT_NAME_EN}}` | 프로젝트명 (국문 / 영문) |
| `{{TEAM}}` / `{{AUTHOR}}` | 팀명 / 작성자 |
| `{{BRAND_HTML}}` / `{{ORG}}` / `{{YEAR}}` / `{{SLOGAN}}` | 표지 브랜드 표기 · 조직명 · 연도 · 슬로건 |
| `{{GOAL_ONE_LINE}}` / `{{GOAL_1~3}}` | 목표 한 줄 + 세부 3개 |
| `{{PERIOD}}` / `{{PHASES}}` | 개발 기간 · 단계 |
| `{{DEV_FORM}}` / `{{RESOLUTION}}` / `{{ENVIRONMENT}}` / `{{INTEGRATIONS}}` | 개발 형태 · 기준 해상도 · 환경 · 연계 시스템 |
| `{{REQ_SOURCE}}` / `{{API_SOURCE}}` | 요구사항 출처 · API 연계 출처 |
| `{{YYYY-MM-DD}}` / `{{초기 버전 설명}}` | 개정이력 첫 행 |

잔여 확인:
```bash
grep -o '{{[^}]*}}' prototype/_template.designspec.html | sort -u
```

## 5. 첫 화면설계서 만들기

1. `_template.designspec.html`을 `[DOMAIN] 화면설계서.designspec.html`로 복사 (DOMAIN = USER/ADMIN 등)
2. IA 페이지에 `docs/IA.md`의 해당 도메인 테이블 삽입
3. 화면별 page1(목업 70% + Description 30%)·page2(기본정보 → 액션 정의 → 유효성·메시지 → 상태 매트릭스 → 플로우) 작성
4. 빌드: `bash prototype/build-all.sh v0.1`

## 6. 설치 확인 체크리스트

- [ ] `bash scripts/check-docs.sh` 통과 (§8 포함)
- [ ] CLAUDE.md 두 슬롯이 채워졌다
- [ ] `{{PLACEHOLDER}}` 잔여 0
- [ ] `bash prototype/build-all.sh v0.1` 로 PDF 생성 확인
- [ ] `.baseline/` 디렉터리 생성됨 (첫 release-cut 시 자동)

## 제거

이 팩만 걷어내려면 1번에서 복사한 파일과 2번에서 추가한 라인을 지우면 됨. core에는 영향 없음.

`pack.yaml`의 `uninstall` 섹션에도 동일 절차가 선언돼 있어 Checkpoint 3의 `tools/kit-install uninstall designspec`이 자동 수행 예정.
