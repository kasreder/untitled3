// 파일 경로: lib/features/auth/view/login_page.dart
// 파일 설명: 로컬·소셜·메타마스크 흐름을 제공하는 인터랙티브 로그인 페이지.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:untitled3/features/auth/controllers/auth_controller.dart';
import 'package:untitled3/features/auth/models/login_type.dart';

/// 다양한 인증 경로를 제공하며 로그인 완료 후 회원 정보를 보여주는 화면.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _localFormKey = GlobalKey<FormState>();
  final TextEditingController _localEmailController = TextEditingController();
  final TextEditingController _localPasswordController = TextEditingController();

  final GlobalKey<FormState> _socialFormKey = GlobalKey<FormState>();
  final TextEditingController _socialEmailController = TextEditingController();

  @override
  void dispose() {
    _localEmailController.dispose();
    _localPasswordController.dispose();
    _socialEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        final theme = Theme.of(context);
        final surfaceColor = theme.colorScheme.surface;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '로그인 및 지갑 연동',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (controller.errorMessage != null)
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        title: Text(
                          controller.errorMessage!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          onPressed: controller.clearError,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (controller.currentUser == null) ...[
                    _buildLocalLoginSection(context, controller, surfaceColor),
                    const SizedBox(height: 24),
                    _buildSocialLoginSection(context, controller, surfaceColor),
                    const SizedBox(height: 24),
                    _buildMetamaskSection(context, controller, surfaceColor),
                  ] else
                    _buildProfileOverview(context, controller, surfaceColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocalLoginSection(
    BuildContext context,
    AuthController controller,
    Color surfaceColor,
  ) {
    final theme = Theme.of(context);
    return Card(
      color: surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _localFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '로컬 로그인',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _localEmailController,
                decoration: const InputDecoration(
                  labelText: '이메일 (ID)',
                  hintText: 'member@cheongnok.kr',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요.';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _localPasswordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해 주세요.';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 8자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : () {
                        if (_localFormKey.currentState!.validate()) {
                          controller.loginWithLocal(
                            email: _localEmailController.text.trim(),
                            password: _localPasswordController.text,
                          );
                        }
                      },
                icon: const Icon(Icons.login),
                label: controller.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(
    BuildContext context,
    AuthController controller,
    Color surfaceColor,
  ) {
    final theme = Theme.of(context);
    return Card(
      color: surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _socialFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '소셜 로그인',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '카카오 또는 네이버 계정으로 로그인하려면 연동된 이메일을 입력하세요.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _socialEmailController,
                decoration: const InputDecoration(
                  labelText: '소셜 계정 이메일',
                  hintText: 'kakao-user@cheongnok.kr',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '연동된 이메일을 입력해 주세요.';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _SocialLoginButton(
                    label: '카카오 로그인',
                    icon: Icons.chat_bubble_outline,
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_socialFormKey.currentState!.validate()) {
                              controller.loginWithSocial(
                                loginType: LoginType.kakao,
                                email: _socialEmailController.text.trim(),
                              );
                            }
                          },
                  ),
                  _SocialLoginButton(
                    label: '네이버 로그인',
                    icon: Icons.nature,
                    backgroundColor: const Color(0xFF03C75A),
                    foregroundColor: Colors.white,
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_socialFormKey.currentState!.validate()) {
                              controller.loginWithSocial(
                                loginType: LoginType.naver,
                                email: _socialEmailController.text.trim(),
                              );
                            }
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetamaskSection(
    BuildContext context,
    AuthController controller,
    Color surfaceColor,
  ) {
    final theme = Theme.of(context);
    return Card(
      color: surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MetaMask 지갑 연동',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '지갑 연결 후 서명을 완료하면 등록된 회원 정보와 포인트가 자동으로 불러와집니다.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.isLoading ? null : controller.loginWithMetamask,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: controller.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('MetaMask 연결'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverview(
    BuildContext context,
    AuthController controller,
    Color surfaceColor,
  ) {
    final user = controller.currentUser!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: surfaceColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '회원 정보',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.person,
                  title: '이름',
                  value: user.name,
                ),
                _ProfileTile(
                  icon: Icons.alternate_email,
                  title: '이메일',
                  value: user.email,
                ),
                _ProfileTile(
                  icon: Icons.verified_user,
                  title: '로그인 유형',
                  value: _loginTypeLabel(user.loginType),
                ),
                _ProfileTile(
                  icon: Icons.tag,
                  title: '닉네임',
                  value: user.nickname,
                ),
                _ProfileTile(
                  icon: Icons.stars,
                  title: '포인트',
                  value: '${user.points}P',
                ),
                _ProfileTile(
                  icon: Icons.calendar_month,
                  title: '가입일',
                  value: _formatDate(user.joinedAt),
                ),
                _ProfileTile(
                  icon: Icons.update,
                  title: '내용 수정일',
                  value: _formatDate(user.updatedAt),
                ),
                _ProfileTile(
                  icon: Icons.history,
                  title: '닉네임 변경일',
                  value: _formatDate(user.nicknameUpdatedAt),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (controller.currentWallet != null)
          Card(
            color: surfaceColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '연동 지갑 정보',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: '지갑 주소',
                    value: controller.currentWallet!.metamaskAddress,
                  ),
                  _ProfileTile(
                    icon: Icons.link,
                    title: '지갑 연결일',
                    value: _formatDate(controller.currentWallet!.createdAt),
                  ),
                  _ProfileTile(
                    icon: Icons.sync,
                    title: '최근 동기화',
                    value: _formatDate(controller.currentWallet!.lastSyncedAt),
                  ),
                  _ProfileTile(
                    icon: controller.currentWallet!.isActive
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    title: '사용 상태',
                    value: controller.currentWallet!.isActive ? '정상 사용' : '일시 중지',
                  ),
                  if (controller.connectedWalletAddress != null)
                    _ProfileTile(
                      icon: Icons.fingerprint,
                      title: '최근 서명 주소',
                      value: controller.connectedWalletAddress!,
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Card(
          color: surfaceColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '내가쓴글보기',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (controller.authoredPosts.isEmpty)
                  Text(
                    '작성한 게시글이 아직 없습니다.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  ...controller.authoredPosts.map(
                    (post) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.article_outlined),
                      title: Text(post),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: controller.logout,
          icon: const Icon(Icons.logout),
          label: const Text('로그아웃'),
        ),
      ],
    );
  }

  String _loginTypeLabel(LoginType type) {
    switch (type) {
      case LoginType.local:
        return '로컬';
      case LoginType.kakao:
        return '카카오';
      case LoginType.naver:
        return '네이버';
    }
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
