# Paperlogy 폰트 적용 방법

테마는 이미 `fontFamily: 'Paperlogy'` 를 1순위로 사용하도록 설정돼 있습니다.
( `lib/core/theme/app_theme.dart` ) — 폰트 파일이 없으면 Pretendard → Apple SD Gothic Neo 순으로 안전하게 폴백됩니다.

## 1) 폰트 파일 다운로드
Paperlogy(페이퍼로지)는 9가지 굵기를 제공합니다. 공식 배포처에서 받은 `.ttf` 파일을
이 디렉터리(`assets/fonts/`)에 아래 이름으로 넣어주세요.

```
Paperlogy-100Thin.ttf
Paperlogy-200ExtraLight.ttf
Paperlogy-300Light.ttf
Paperlogy-400Regular.ttf
Paperlogy-500Medium.ttf
Paperlogy-600SemiBold.ttf
Paperlogy-700Bold.ttf
Paperlogy-800ExtraBold.ttf
Paperlogy-900Black.ttf
```

## 2) pubspec.yaml 에 아래 블록 추가
`flutter:` 하위에 붙여넣으면 됩니다.

```yaml
  fonts:
    - family: Paperlogy
      fonts:
        - asset: assets/fonts/Paperlogy-100Thin.ttf
          weight: 100
        - asset: assets/fonts/Paperlogy-200ExtraLight.ttf
          weight: 200
        - asset: assets/fonts/Paperlogy-300Light.ttf
          weight: 300
        - asset: assets/fonts/Paperlogy-400Regular.ttf
          weight: 400
        - asset: assets/fonts/Paperlogy-500Medium.ttf
          weight: 500
        - asset: assets/fonts/Paperlogy-600SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Paperlogy-700Bold.ttf
          weight: 700
        - asset: assets/fonts/Paperlogy-800ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/Paperlogy-900Black.ttf
          weight: 900
```

## 3) 적용
`flutter pub get` 후 재실행하면 전 화면에 Paperlogy가 적용됩니다.
(테마 코드는 이미 준비돼 있어 추가 수정 불필요)
