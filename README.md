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
│   │   │   ├── user_grade.dart
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
│   │   │   ├── post_editor_page.dart
│   │   │   └── widgets/
│   │   │       ├── post_gallery_tile.dart
│   │   │       └── post_list_tile.dart
│   │   └── widgets/
│   │       ├── ckeditor5.dart
│   │       ├── ckeditor5_platform_interface.dart
│   │       ├── ckeditor5_platform_io.dart
│   │       ├── ckeditor5_platform_web.dart
│   │       └── comment_utils.dart
│   └── simple_page/
│       └── simple_page.dart
├── util/
│   └── editor/
│       ├── package.json 외 CKEditor 5 빌드 설정 파일 다수
└── main.dart
```

### 핵심 폴더 설명

- **lib/main.dart**: 앱 실행 진입점으로 `AppRoot`만 실행합니다.
- **lib/app**: 앱 전역 구성을 담당합니다.
  - `app_root.dart`: 테마, 라우터, 의존성 주입을 관리합니다.
  - `navigation/`: 내비게이션 관련 컨트롤러와 공용 위젯, 목적지 정의를 포함합니다.
  - `router/`: `GoRouter` 구성을 담당합니다.
- **lib/features**: 실제 화면(Feature)을 모듈 단위로 관리합니다.
  - `auth/`: 로그인 UI(`view/login_page.dart`), AES-256 암호화(`services/crypto_service.dart`), 메타마스크 연동(`services/metamask_connector.dart`), 등급·회원 모델(`models/user_grade.dart`, `models/user.dart`)과 더미 데이터 저장소(`data/dummy_user_repository.dart`)를 포함합니다.
  - `board/`: 자유 게시판 기능(리스트/갤러리 전환, CKEditor 5 기반 에디터, 댓글/대댓글, 좋아요·싫어요·공유)을 제공합니다. 뷰 전용 위젯(`view/widgets/`), 에디터 브리지(`widgets/ckeditor5*.dart`), 상태 관리(`controllers/board_controller.dart`)가 역할별로 분리되어 있습니다.
  - `simple_page/`: 개발 중인 메뉴를 대신 보여주는 플레이스홀더 화면입니다.
- **lib/util/editor**: CKEditor 5 원본 소스와 pnpm 기반 빌드 설정을 보관합니다.

## 자유 게시판 데이터

- 초기 게시글 20건은 `assets/data/free_board.json`에 JSON 형식으로 저장되어 있으며, 앱 시작 시 로딩됩니다.
- 게시글 본문은 CKEditor 5에서 생성한 HTML을 그대로 저장합니다. `assets/pics` 폴더에 포함된 이미지 리소스를 커버 및 첨부 이미지로 활용합니다.

## CKEditor 5 통합

- `lib/features/board/widgets/ckeditor5.dart`는 웹에서는 `HtmlElementView` + `iframe`, 모바일/데스크톱에서는 `webview_flutter`를 사용해 CKEditor 5 클래식 에디터를 임베드합니다.
- Flutter ↔️ CKEditor 간 양방향 통신은 `window.postMessage`와 `JavaScriptChannel`을 통해 구현했습니다. 본문 변경 시 실시간으로 Flutter 상태가 갱신됩니다.
- CKEditor 5 소스는 `lib/util/editor` 디렉터리에 포함되어 있으며, 현재는 CDN 번들을 사용하지만 추후 자체 빌드로 대체할 수 있습니다.

## Database Schema

플랫폼이 정식 서비스로 전환될 경우를 대비해, 현재 도메인 모델과 기능 요구사항(로그인, 포인트, 지갑 연동, 자유 게시판)을 반영한 관계형 스키마를 정리했습니다. 모든 민감 정보(비밀번호, 서드파티 토큰, 지갑 서명)는 AES-256-CBC(+PKCS7)으로 암호화하고, 키/IV는 HSM 또는 비밀 저장소에서 주입합니다.

### Entity Relationship Overview

- `users` ↔ `user_wallets` : 1:0..1 — 회원당 최대 한 개의 메타마스크 지갑을 연동합니다.
- `users` ↔ `board_posts` : 1:N — 게시글 작성 시 작성자의 닉네임 스냅샷을 함께 저장해 닉네임 변경 이력을 보존합니다.
- `board_posts` ↔ `board_post_assets` : 1:N — 커버 이미지와 첨부 파일을 유형별로 관리합니다.
- `board_posts` ↔ `board_post_reactions` : 1:N — 좋아요/싫어요 이력을 회원 단위로 기록해 중복 반응을 방지합니다.
- `board_posts` ↔ `board_comments` : 1:N — 대댓글은 `parent_comment_id` 자기 참조 컬럼으로 트리 구조를 이룹니다.
- `board_comments` ↔ `board_comment_reactions` : 1:N — 댓글 좋아요/싫어요 기록.

### `users`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | CHAR(12) | PK | 내부 식별자 (예: `USR-2024001`) |
| `name` | VARCHAR(40) | NOT NULL | 실명 |
| `email` | VARCHAR(120) | UNIQUE, NOT NULL | 로그인 ID |
| `encrypted_secret` | VARBINARY(512) | NOT NULL | AES-256으로 암호화된 비밀번호/소셜 토큰 |
| `login_type` | ENUM(`local`, `kakao`, `naver`) | NOT NULL | 로그인 채널 |
| `grade` | ENUM(`all`, `regular`, `semi_expert`, `expert`, `admin1`, `admin2`, `developer`, `master`) | DEFAULT `regular` | 회원 등급 (`UserGrade` 열거형과 매핑) |
| `nickname` | VARCHAR(30) | NOT NULL | 게시글 표시용 닉네임 |
| `points` | INT | DEFAULT 0 | 포인트 잔액 |
| `authored_post_titles_cache` | JSON | DEFAULT ('[]') | "내가 쓴 글" 목록 캐시 (최근 게시글 제목 배열) |
| `joined_at` | DATETIME | NOT NULL | 가입일 |
| `updated_at` | DATETIME | NOT NULL | 최근 정보 수정일 |
| `nickname_updated_at` | DATETIME | NULL | 닉네임 변경일 |

> **인덱스 제안:** `idx_users_login_type` (login_type), `idx_users_grade` (grade), `idx_users_joined_at` (joined_at DESC).

### `user_wallets`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `user_id` | CHAR(12) | PK, FK(`users.id`) | 지갑 소유 회원 |
| `metamask_address` | VARCHAR(64) | UNIQUE, NOT NULL | MetaMask 지갑 주소 |
| `created_at` | DATETIME | NOT NULL | 최초 연동 시각 |
| `last_synced_at` | DATETIME | NOT NULL | 마지막 동기화 시각 |
| `is_active` | TINYINT(1) | DEFAULT 1 | 사용 여부 |

> **연동 정책:** `is_active = 0`일 경우 지갑 연결 UI에서는 비활성화 처리하고, 백오피스에서 재연동 절차를 진행합니다.

### `board_posts`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | BIGINT | PK, AUTO_INCREMENT | 게시글 ID |
| `user_id` | CHAR(12) | FK(`users.id`) | 작성자 |
| `nickname_snapshot` | VARCHAR(30) | NOT NULL | 게시 당시 닉네임 |
| `title` | VARCHAR(200) | NOT NULL | 게시글 제목 |
| `summary` | VARCHAR(280) | NULL | 리스트/갤러리용 요약 |
| `content_html` | MEDIUMTEXT | NOT NULL | CKEditor 5 HTML 본문 |
| `cover_image_path` | VARCHAR(255) | NULL | 대표 이미지 경로 |
| `view_count` | INT | DEFAULT 0 | 조회수 |
| `like_count` | INT | DEFAULT 0 | 좋아요 수 |
| `dislike_count` | INT | DEFAULT 0 | 싫어요 수 |
| `comment_count` | INT | DEFAULT 0 | 댓글 수 캐시 |
| `created_at` | DATETIME | NOT NULL | 작성 시각 |
| `updated_at` | DATETIME | NOT NULL | 수정 시각 |
| `published_at` | DATETIME | NULL | 공개 시각 (예약 발행 지원 시 사용) |

> **인덱스 제안:** `idx_board_posts_user_created` (user_id, created_at DESC), `idx_board_posts_published` (published_at DESC) 로 최신 글/작성자별 조회를 최적화합니다.

### `board_post_assets`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | BIGINT | PK, AUTO_INCREMENT | 첨부 자원 ID |
| `post_id` | BIGINT | FK(`board_posts.id`) | 소속 게시글 |
| `asset_type` | ENUM(`cover`, `image`, `attachment`) | NOT NULL | 자원 유형 |
| `file_path` | VARCHAR(255) | NOT NULL | 저장 경로 또는 URL |
| `order_index` | TINYINT UNSIGNED | DEFAULT 0 | 노출 순서 |
| `metadata_json` | JSON | NULL | 파일 크기, 썸네일 등 부가 정보 |
| `created_at` | DATETIME | NOT NULL | 등록 시각 |

> **제약 조건:** `(post_id, asset_type, order_index)` UNIQUE — 동일 유형 자원의 순서 중복 방지.

### `board_post_reactions`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `post_id` | BIGINT | FK(`board_posts.id`) | 대상 게시글 |
| `user_id` | CHAR(12) | FK(`users.id`) | 반응한 회원 |
| `reaction_type` | ENUM(`like`, `dislike`) | NOT NULL | 반응 종류 |
| `reacted_at` | DATETIME | NOT NULL | 반응 등록 시각 |

> **Primary Key:** `(post_id, user_id)` — 회원당 하나의 반응만 허용합니다. 통계 수치는 배치/트리거로 `board_posts`에 집계합니다.

### `board_comments`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `id` | BIGINT | PK, AUTO_INCREMENT | 댓글 ID |
| `post_id` | BIGINT | FK(`board_posts.id`) | 소속 게시글 |
| `user_id` | CHAR(12) | FK(`users.id`) | 작성자 |
| `nickname_snapshot` | VARCHAR(30) | NOT NULL | 작성 당시 닉네임 |
| `content` | TEXT | NOT NULL | 댓글 본문 (CKEditor 5의 plain text/간단 HTML) |
| `parent_comment_id` | BIGINT | FK(`board_comments.id`), NULL | 대댓글일 경우 상위 댓글 |
| `depth` | TINYINT UNSIGNED | DEFAULT 0 | 트리 깊이 (0=최상위) |
| `like_count` | INT | DEFAULT 0 | 좋아요 수 |
| `dislike_count` | INT | DEFAULT 0 | 싫어요 수 |
| `created_at` | DATETIME | NOT NULL | 작성 시각 |
| `updated_at` | DATETIME | NOT NULL | 수정 시각 |
| `deleted_at` | DATETIME | NULL | 운영자/작성자 삭제 시각 |

> **인덱스 제안:** `idx_board_comments_post_depth_created` (post_id, depth, created_at) — 스레드/대댓글 조회 최적화.

### `board_comment_reactions`

| 컬럼 | 타입 | 제약 | 설명 |
| --- | --- | --- | --- |
| `comment_id` | BIGINT | FK(`board_comments.id`) | 대상 댓글 |
| `user_id` | CHAR(12) | FK(`users.id`) | 반응한 회원 |
| `reaction_type` | ENUM(`like`, `dislike`) | NOT NULL | 반응 종류 |
| `reacted_at` | DATETIME | NOT NULL | 반응 등록 시각 |

> **Primary Key:** `(comment_id, user_id)` — 댓글 당 회원 1회 반응 제한.

### 운영 및 보안 메모

- 모든 AES-256 키는 KMS/HSM에서 주입하고, 애플리케이션에는 암호화된 환경 변수로만 전달합니다.
- `board_posts`, `board_comments` 테이블에는 감사(audit) 트리거를 추가해 수정/삭제 이력을 별도 테이블에 적재할 것을 권장합니다.
- 정적 자산(`board_post_assets.file_path`)은 CDN 경로를 저장하고, 실제 파일 메타데이터는 오브젝트 스토리지 태그에 기록합니다.

## Getting Started

Flutter 개발이 처음이라면 아래 자료가 도움이 됩니다.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

자세한 Flutter 개발 문서는 [온라인 문서](https://docs.flutter.dev/)에서 확인할 수 있습니다.
