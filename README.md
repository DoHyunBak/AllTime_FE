# AllTime FE

Flutter 프론트엔드 프로젝트입니다.

## 디자인 시스템

| 토큰 | 값 | 용도 |
|------|----|------|
| `primary` | `#F91F15` | 브랜드 레드 — 로고, 활성 탭, 게시판명 |
| `linkBlue` | `#056AB5` | HOT/BEST/사이드바 헤딩 링크 |
| `textPrimary` | `#444444` | 네비, 제목 |
| `textSecondary` | `#666666` | 본문, 게시글 제목 |
| `textMuted` | `#737373` | 날짜/시간 보조 텍스트 |
| `bgButton` | `#FAF9F5` | 버튼 배경 |
| `borderLight` | `#D6D6D6` | 구분선 (0.57px) |

## 프로젝트 구조

```
lib/
├── main.dart              # 진입점 (BetterFeedback + ProviderScope)
├── app.dart               # MaterialApp.router
├── core/
│   ├── theme/             # 디자인 시스템
│   ├── router/            # go_router
│   ├── network/           # 오프라인 감지
│   └── feedback/          # 인앱 피드백
├── features/
│   └── home/              # 홈 피처 (도메인별로 추가)
└── shared/
    └── widgets/           # 공용 위젯
```

## 시작하기

```bash
flutter pub get
flutter run
```

## 개발 원칙

1. **미니멀리즘** — 핵심 기능 하나에 집중
2. **현장 대응** — 오프라인 배너, 큰 터치 타겟
3. **피드백 루프** — 우하단 FAB으로 즉시 의견 수렴
