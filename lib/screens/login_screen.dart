import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] LoginScreen - 로그인 화면
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description]
/// Google 소셜 로그인 + 게스트(익명) 로그인
/// AuthProvider를 통해 인증 처리, go_router redirect가 자동 화면 전환
///
/// * [Collaborators Note]
/// - 광진: AuthProvider.signInWithGoogle()이 Firebase Auth + Firestore 프로필 생성
/// - 준수: UI 레이아웃 및 로딩/에러 상태 표시

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFBEA),
                Color(0xFFEBFCF4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryDark,
                  size: 100,
                ),
                const SizedBox(height: AppDimensions.paddingXLarge),
                const Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 100),
                if (authProvider.isLoading)
                  _buildLoadingIndicator()
                else
                  _buildLoginButtons(context, authProvider),
                if (authProvider.error != null) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    authProvider.error!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        CircularProgressIndicator(color: AppColors.primaryDark),
        SizedBox(height: AppDimensions.paddingMedium),
        Text(
          AppStrings.loginLoading,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        _buildButton(
          text: AppStrings.loginGoogleButton,
          color: Colors.white,
          textColor: AppColors.textPrimary,
          isOutlined: true,
          onTap: () => authProvider.signInWithGoogle(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildButton(
          text: AppStrings.loginGuestButton,
          color: Colors.white.withValues(alpha: 0.5),
          textColor: AppColors.textSecondary,
          isOutlined: false,
          onTap: () => authProvider.signInAnonymously(),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: isOutlined ? Border.all(color: AppColors.divider) : null,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
