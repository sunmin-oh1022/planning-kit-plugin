# architecture.md — 구조 (구조 맥락 필요 시 읽기)

## 두 레이어
- **Core/** — 순수 로직. UI·네트워크·플랫폼 의존 없음. → 1초 검증의 토대.
- **App/**  — UI 레이어. Core를 호출만 한다.

## 작업 파이프라인 (Phase)
로직 → 첫 화면 → 부가 기능 → 출시 준비. 검증된 토대 위에 차곡차곡.

## 폴더/모듈 배치 — (TODO 프로젝트명)
```
project/
├── (TODO Core 모듈명)/                ← 순수 로직 (스택별 패키지 형태)
│   ├── (TODO Package/manifest 파일)
│   ├── Sources/...                    ← 도메인 모델 / Store / Persistence / Clock
│   └── Tests/...                      ← TC-001 ~ TC-### 자동 검증
├── (TODO App 모듈명)/                 ← UI 레이어
│   └── ...                            ← @main / 첫 화면 (SCR-001) / 편집 (SCR-002) ...
└── docs/                              ← 기획 문서
```

## 의존 방향 (어기면 #2 위반)
- App → Core ✅
- Core → App ❌
- Core → 표준 라이브러리 외 프레임워크 ❌
