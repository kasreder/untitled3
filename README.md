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
│   │   │   └── asset_user_post_repository.dart
│   │   ├── models/
│   │   │   ├── post_comment.dart
│   │   │   └── user_post.dart
│   │   ├── view/
│   │   │   ├── board_page.dart
│   │   │   ├── post_detail_page.dart
│   │   │   └── post_editor_page.dart
│   │   └── widgets/
│   │       ├── comment_thread.dart
│   │       ├── post_gallery_view.dart
│   │       ├── post_list_view.dart
│   │       └── post_meta_row.dart
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
  - `board/`: CKEditor 5 기반 게시판. 목록/갤러리 전환, 글 작성·수정·삭제, 대댓글, 좋아요·싫어요·공유 등 상호작용을 제공합니다. 데이터는 `assets/data/user_posts.json`에 포함된 20개의 더미 글에서 로드됩니다.
  - `simple_page/`: 개발 중인 메뉴를 대신 보여주는 플레이스홀더 화면입니다.

## Community Board

자유 게시판은 웹과 앱 모두에서 동일하게 동작하도록 반응형으로 구현했습니다.

- **레이아웃 전환**: 상단 `SegmentedButton`으로 리스트형 ↔ 갤러리형을 즉시 전환합니다. 두 레이아웃은 `post_list_view.dart`와 `post_gallery_view.dart`로 분리돼 있어 확장과 유지보수가 쉽습니다.
- **글 작성/수정**: `PostEditorPage`에서 CKEditor 5 (`lib/util/editor`)를 활용한 리치 텍스트 편집을 제공합니다. 모바일/데스크톱에서는 `webview_flutter`, 웹에서는 `HtmlElementView`로 에디터를 임베드했습니다.
- **글 삭제 & 공유**: 상세 페이지에서 삭제 확인 다이얼로그, 조회수 자동 증가, 링크 복사 기반 공유 버튼을 지원합니다.
- **반응형 상세 화면**: 작성/수정일, 닉네임, 태그, 첨부 이미지, 조회수·좋아요·싫어요 통계를 모두 노출합니다.
- **댓글/대댓글**: `CommentThread`가 트리 구조를 렌더링하고, 닉네임과 내용을 입력받아 대댓글까지 작성할 수 있습니다.
- **더미 데이터**: `assets/data/user_posts.json`에는 20개의 환경/커뮤니티 주제 글과 대댓글이 포함되어 있어 개발 중에도 다양한 상태를 확인할 수 있습니다.

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
| `nickname` | VARCHAR(30) | NOT NULL | 화면에 노출될 닉네임 (실명 대신) |
| `title` | VARCHAR(200) | NOT NULL | 게시글 제목 |
| `summary` | VARCHAR(400) | NOT NULL | 목록·갤러리용 요약 텍스트 |
| `content` | LONGTEXT | NOT NULL | CKEditor 5에서 작성한 HTML 본문 |
| `thumbnail_path` | VARCHAR(255) | NULL | 대표 이미지 경로 |
| `attachments_json` | JSON | NULL | 첨부 미디어 경로 배열 |
| `views` | INT | DEFAULT 0 | 조회수 |
| `likes` | INT | DEFAULT 0 | 좋아요 수 |
| `dislikes` | INT | DEFAULT 0 | 싫어요 수 |
| `share_slug` | VARCHAR(80) | UNIQUE | 공유 URL 생성을 위한 슬러그 |
| `created_at` | DATETIME | NOT NULL | 작성 시각 |
| `updated_at` | DATETIME | NOT NULL | 수정 시각 |

> **암호화 전략:** 비밀번호/토큰은 AES-256-CBC + PKCS7 패딩을 사용해 암호화하며, 키/IV는 안전한 비밀 저장소에서 주입합니다. 지갑 서명과 같은 민감 로그는 별도 암호화 테이블에 저장해 금융권 수준의 보안을 유지합니다.

## Getting Started

Flutter 개발이 처음이라면 아래 자료가 도움이 됩니다.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

자세한 Flutter 개발 문서는 [온라인 문서](https://docs.flutter.dev/)에서 확인할 수 있습니다.
