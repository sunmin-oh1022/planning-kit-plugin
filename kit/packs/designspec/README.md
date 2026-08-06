# packs/designspec — 화면설계서 파이프라인 팩

> planning-kit의 첫 팩. 프로토타입(HTML) → docs(SSOT) → **화면설계서(PDF)** 를 버전·형상 관리와 함께 운영.

## 이 팩이 필요한 경우

- 화면설계서를 **버전을 매겨 반복 배포**한다 (v0.1 → v0.2 → …)
- 프로토타입과 화면설계서를 **함께 굴리는데 자꾸 어긋난다**
- 산출물이 **PDF로 나가야 하고**, 배포본은 불변으로 남겨야 한다

반대로 PDF 배포나 버전 관리가 필요 없다면 이 팩은 불필요 — planning-kit core만으로 충분.

## 무엇이 들어 있나

| 경로 | 내용 |
| --- | --- |
| `rules/methodology/change-management.md` | **형상 관리 가드레일** — 절차 A(버전 업데이트)/B(릴리스 컷), 버전 라벨 치환 규칙, 작업 리듬, 완료 체크리스트 |
| `rules/methodology/designspec.md` | 화면설계서 방법론 진입점 (언제·어떤 순서로·어떤 규율로) |
| `.claude/skills/designspec-version-update/` | 절차 A 실행 스킬 |
| `.claude/skills/release-cut/` | 절차 B 실행 스킬 |
| `prototype/_template.designspec.html` | 화면설계서 템플릿 (표지·개요·개정이력·IA·공통정의 + page1/page2 스켈레톤) |
| `prototype/build-all.sh` · `build-pdf.sh` | HTML → PDF 빌드 |
| `prototype/화면설계서-가이드.md` | 제작 컨벤션 단일 진실 |
| `prototype/README.md` | 파일명·버전 매핑, 화면 크기 정책 |
| `scripts/release-cut.sh` | 버전 라인 분기 자동화 |
| `pack.yaml` | 팩 메타데이터 · 주입 슬롯 · 플레이스홀더 명세 |

## 핵심 개념 3가지

**1. 산출물 관계는 단방향이다**
```
프로토타입(동작 검토) → docs(SSOT) → 화면설계서(파생물)
   먼저 바뀔 수 있음      단일 진실       docs를 시각화
```
**프로토타입에서 화면설계서로 바로 가지 않는다.** 새 요건·용어·정책은 반드시 docs를 경유한다.

**2. 두 작업을 혼동하지 않는다**

| | 절차 A · 버전 업데이트 | 절차 B · 릴리스 컷 |
| --- | --- | --- |
| 무엇 | docs 동기화 후 화면설계서 파생 | 배포본 동결 + 다음 버전 라인 분기 |
| 트리거 | "화면설계서 버전 업데이트" | "vX.Y 배포했고 오늘부터 vX.Z로" |
| docs 건드림 | ✅ | ❌ |

**3. 버전 라벨은 블랭킷 치환하지 않는다**
`sed s/v0.2/v0.3/g` 한 번이면 역사 기록이 통째로 날아간다. **올릴 3종**(커버 칩·푸터 토큰·프로토타입 참조)과 **보존 4종**(상태 칩·인라인 역사·파생 출처·개정 이력)을 구분한다.

## ⚠️ 알려진 함정

**① 체크리스트가 두 곳에 존재한다 — SSOT는 change-management.md**
완료 체크리스트가 `rules/methodology/change-management.md`와 `.claude/skills/*/SKILL.md` **양쪽에** 있다. 실행 시점에 실제로 읽히는 건 **스킬 쪽**이라, change-management만 고치면 규칙이 반만 작동.
> **체크리스트를 바꿀 때는 반드시 둘 다 고친다.**

**② 파일명 규칙에 강결합돼 있다**
`release-cut.sh`와 core의 `check-docs.sh §8`은 아래 네이밍을 전제로 동작한다:
```
[DOMAIN] 화면설계서.designspec.html      ← 라이브(작업본)
[DOMAIN] 화면설계서_vX.Y.html            ← 배포 동결본
[DOMAIN] 화면설계서_vX.Y.pdf             ← 배포 PDF
[DOMAIN] 프로토타입_vX.Y.html            ← 프로토타입
.baseline/[DOMAIN] 화면설계서.designspec.html  ← 베이스라인
```

**③ 개정 이력은 사람이 관리한다**
개정 이력 표의 행 추가·수정은 **기획자 전용**. AI가 자동으로 건드리지 않도록 템플릿 HTML 주석과 규칙 문서 양쪽에 명시.

**④ PDF 빌드는 배포 행위다**
중간 검토는 designspec HTML을 브라우저로 본다. 빌드를 검토용으로 돌리면 한 세션에 5~6회씩 낭비. 상세는 `change-management.md` '작업 리듬'.

## 설치

→ [`INSTALL.md`](./INSTALL.md)

## 의존성

- **Chrome / Chromium** (헤드리스 렌더) — PDF 빌드에 필요
- **Node.js + pdfkit** — `build-pdf.sh` 참조
- bash · awk · sed · grep (표준)

## 라이선스 / 출처

실제 프로젝트 운영(기획자 1인 + AI 페어, 화면설계서 v0.1→v0.3 반복 배포)에서 도출·검증. 프로젝트 고유 정보는 모두 제거하고 `{{PLACEHOLDER}}`로 치환.
