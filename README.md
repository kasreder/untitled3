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
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   ├── data/
│   │   │   └── dummy_user_repository.dart
│   │   ├── models/
│   │   │   ├── login_type.dart
│   │   │   ├── user.dart
│   │   │   └── user_wallet.dart
│   │   ├── services/
│   │   │   ├── crypto_service.dart
│   │   │   └── metamask_connector.dart
│   │   └── view/
│   │       └── login_page.dart
│   ├── board/
│   │   ├── controllers/
│   │   │   └── board_controller.dart
│   │   ├── data/
│   │   │   └── board_repository.dart
│   │   ├── models/
│   │   │   ├── board_comment.dart
│   │   │   └── board_post.dart
│   │   ├── view/
│   │   │   ├── board_page.dart
│   │   │   ├── post_detail_page.dart
│   │   │   └── post_editor_page.dart
│   │   └── widgets/
│   │       ├── ckeditor5.dart
│   │       ├── ckeditor5_platform_io.dart
│   │       ├── ckeditor5_platform_interface.dart
│   │       ├── ckeditor5_platform_web.dart
│   │       ├── comment_utils.dart
│   │       ├── post_gallery_tile.dart
│   │       └── post_list_tile.dart
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
- **lib/features**: 실제 화면(Feature)을 모듈 단위로 관리합니다.
  - `auth/`: 로그인, 사용자/지갑 더미 데이터, 암호화 서비스를 포함하는 인증 모듈입니다.
  - `board/`: 자유 게시판 기능(리스트/갤러리 전환, CKEditor 5 기반 에디터, 댓글/대댓글, 좋아요·싫어요·공유)을 제공합니다.
  - `simple_page/`: 개발 중인 메뉴를 대신 보여주는 플레이스홀더 화면입니다.

## 자유 게시판 데이터

- 초기 게시글 20건은 `assets/data/free_board.json`에 JSON 형식으로 저장되어 있으며, 앱 시작 시 로딩됩니다.
- 게시글 본문은 CKEditor 5에서 생성한 HTML을 그대로 저장합니다. `assets/pics` 폴더에 포함된 이미지 리소스를 커버 및 첨부 이미지로 활용합니다.

## CKEditor 5 통합

- `lib/features/board/widgets/ckeditor5.dart`는 웹에서는 `HtmlElementView` + `iframe`, 모바일/데스크톱에서는 `webview_flutter`를 사용해 CKEditor 5 클래식 에디터를 임베드합니다.
- Flutter ↔️ CKEditor 간 양방향 통신은 `window.postMessage`와 `JavaScriptChannel`을 통해 구현했습니다. 본문 변경 시 실시간으로 Flutter 상태가 갱신됩니다.
- CKEditor 5 소스는 `lib/util/editor` 디렉터리에 포함되어 있으며, 현재는 CDN 번들을 사용하지만 추후 자체 빌드로 대체할 수 있습니다.

## Database Schema (Draft)

향후 RDBMS 도입 시 고려할 기본 스키마 초안입니다. 모든 민감 정보(비밀번호, 서드파티 토큰, 지갑 서명)는 AES-256으로 암호화 후 저장하며, 키는 HSM 또는 비밀 저장소에서 관리합니다.

### `users`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | CHAR(12) | PK | 내부 식별자 (예: `USR-2024001`) |
| `name` | VARCHAR(40) | NOT NULL | 실명 |
| `email` | VARCHAR(120) | UNIQUE, NOT NULL | 로그인 ID |
| `encrypted_secret` | VARBINARY | NOT NULL | AES-256으로 암호화된 비밀번호 또는 소셜 토큰 |
| `login_type` | ENUM(`local`, `kakao`, `naver`) | NOT NULL | 로그인 채널 |
| `nickname` | VARCHAR(30) | NOT NULL | 게시글 표시용 닉네임 |
| `points` | INT | DEFAULT 0 | 포인트 잔액 |
| `joined_at` | DATETIME | NOT NULL | 가입일 |
| `updated_at` | DATETIME | NOT NULL | 최근 정보 수정일 |
| `nickname_updated_at` | DATETIME | NULL | 닉네임 변경일 |

### `user_wallets`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `user_id` | CHAR(12) | PK, FK(`users.id`) | 지갑 소유 회원 |
| `metamask_address` | VARCHAR(64) | UNIQUE, NOT NULL | MetaMask 지갑 주소 |
| `created_at` | DATETIME | NOT NULL | 최초 연동 시각 |
| `last_synced_at` | DATETIME | NOT NULL | 마지막 동기화 시각 |
| `is_active` | TINYINT(1) | DEFAULT 1 | 사용 여부 |

### `user_posts`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | BIGINT | PK | 게시글 ID |
| `user_id` | CHAR(12) | FK(`users.id`) | 작성자 |
| `nickname_snapshot` | VARCHAR(30) | NOT NULL | 게시 당시 닉네임 |
| `title` | VARCHAR(200) | NOT NULL | 게시글 제목 |
| `summary` | VARCHAR(280) | NULL | 리스트/갤러리용 요약 |
| `content_html` | MEDIUMTEXT | NOT NULL | CKEditor 5 HTML 본문 |
| `cover_image_path` | VARCHAR(120) | NULL | 대표 이미지 경로 |
| `attachment_json` | JSON | NULL | 첨부 이미지/파일 메타데이터 |
| `view_count` | INT | DEFAULT 0 | 조회수 |
| `like_count` | INT | DEFAULT 0 | 좋아요 수 |
| `dislike_count` | INT | DEFAULT 0 | 싫어요 수 |
| `created_at` | DATETIME | NOT NULL | 작성 시각 |
| `updated_at` | DATETIME | NOT NULL | 수정 시각 |

> **암호화 전략:** 비밀번호/토큰은 AES-256-CBC + PKCS7 패딩을 사용해 암호화하며, 키/IV는 안전한 비밀 저장소에서 주입합니다. 지갑 서명과 같은 민감 로그는 별도 암호화 테이블에 저장해 금융권 수준의 보안을 유지합니다.

## Getting Started

Flutter 개발이 처음이라면 아래 자료가 도움이 됩니다.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

자세한 Flutter 개발 문서는 [온라인 문서](https://docs.flutter.dev/)에서 확인할 수 있습니다.
