import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] LoginScreen - 로그인/온보딩 화면
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- [A] 상태 관리 영역 ---
  bool _isLoading = false;

  // --- [B] 비즈니스 로직 영역 ---

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2)); // 광진 TODO: Firebase 연동
      if (mounted) widget.onLoginSuccess();
    } catch (e) {
      if (mounted) _showErrorMessage(AppStrings.errorLoginFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) widget.onLoginSuccess();
    } catch (e) {
      if (mounted) _showErrorMessage(AppStrings.errorUnknown);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error, // 상수 적용
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- [C] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFBEA), // 온보딩 전용 그라데이션 (추후 AppColors 등록 권장)
                Color(0xFFEBFCF4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // [Section 1] 브랜드 아이콘
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryDark, // 상수 적용
                  size: 100, // 브랜드 아이콘이므로 고정 수치 유지 혹은 AppDimensions 확장
                ),
                const SizedBox(height: AppDimensions.paddingXLarge),

                // [Section 2] 브랜드 캐치프레이즈
                const Text(
                  AppStrings.loginTitle, // 상수 적용
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3, // 상수 적용 (24px, Bold)
                ),
                const SizedBox(height: 100),

                // [Section 3] 로딩 상태 또는 버튼 레이아웃
                if (_isLoading)
                  _buildLoadingIndicator()
                else
                  _buildLoginButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- [D] 컴포넌트 빌더 메서드 ---

  /// 로딩 중 표시될 인디케이터
  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        CircularProgressIndicator(color: AppColors.primaryDark),
        SizedBox(height: AppDimensions.paddingMedium),
        Text(
          AppStrings.loginLoading,
          style: AppTextStyles.bodySmall, // 상수 적용 (14px)
        ),
      ],
    );
  }

  /// 로그인 버튼 세트
  Widget _buildLoginButtons() {
    return Column(
      children: [
        _buildButton(
          text: AppStrings.loginGoogleButton,
          color: Colors.white,
          textColor: AppColors.textPrimary,
          isOutlined: true,
          onTap: _handleGoogleLogin,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildButton(
          text: AppStrings.loginGuestButton,
          color: Colors.white.withValues(alpha: 0.5),
          textColor: AppColors.textSecondary,
          isOutlined: false,
          onTap: _handleGuestLogin,
        ),
      ],
    );
  }

  /// 공용 버튼 컴포넌트
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge), // 상수 적용
            border: isOutlined
                ? Border.all(color: AppColors.divider) // 상수 적용
                : null,
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
              style: AppTextStyles.button.copyWith(color: textColor), // 상수 적용
            ),
          ),
        ),
      ),
    );
  }
}