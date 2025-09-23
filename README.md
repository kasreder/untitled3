# untitled3

청록 네트워크 웹 애플리케이션의 Flutter 프로젝트입니다. 라우팅, 내비게이션, 화면 구성을 역할별로 분리해 유지보수가 쉽도록 리팩터링했습니다.

## Project Structure

```
lib/
├── app/
│   ├── app_root.dart
│   ├── navigation/
│   │   ├── adaptive_navigation_shell.dart
│   │   ├── app_destinations.dart
│   │   └── navigation_controller.dart
│   └── router/
│       └── app_router.dart
├── features/
│   └── simple_page/
│       └── simple_page.dart
└── main.dart
```

### 핵심 폴더 설명

- **lib/main.dart**: 앱 실행 진입점으로 `AppRoot`만 실행합니다.
- **lib/app**: 앱 전역 구성을 담당합니다.
  - `app_root.dart`: 테마, 라우터, 의존성 주입을 관리합니다.
  - `navigation/`: 내비게이션 관련 컨트롤러와 공용 위젯, 목적지 정의를 포함합니다.
  - `router/`: `GoRouter` 구성을 담당합니다.
- **lib/features**: 실제 화면(Feature)을 모듈 단위로 관리합니다. 현재는 플레이스홀더인 `SimplePage`만 포함되어 있으며, 향후 기능별 하위 폴더를 추가할 수 있습니다.

## Getting Started

Flutter 개발이 처음이라면 아래 자료가 도움이 됩니다.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

자세한 Flutter 개발 문서는 [온라인 문서](https://docs.flutter.dev/)에서 확인할 수 있습니다.
