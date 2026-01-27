import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserCredential?> _signInWithGoogle() async {
    // google_sign_in은 Windows 데스크톱 지원 대상이 아님(Android/iOS/macOS/web 중심)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      throw UnsupportedError(
        'Windows에서는 Google Sign-In이 지원되지 않습니다. Android 에뮬레이터로 실행하세요.',
      );
    }

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      // v7: initialize를 1회 호출 권장
      await signIn.initialize();

      // v7: signIn() 대신 authenticate()
      final GoogleSignInAccount? googleUser = await signIn.authenticate();
      if (googleUser == null) return null; // 일부 환경에서 null로 내려올 수 있음(취소 등)

      // v7: authentication은 Future가 아니라 getter(문서 기준)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw StateError(
          'Google idToken이 null 입니다. Firebase 콘솔에 SHA-1 등록 및 google-services.json 재다운로드/교체를 확인하세요.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // ✅ 취소는 실패가 아니라 "사용자 취소"로 처리
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _signInWithGoogle();

      // 취소(null)인 경우: 실패로 처리하지 않음
      if (result == null) {
        return;
      }

      if (mounted) widget.onLoginSuccess();
    } on UnsupportedError catch (e) {
      if (mounted) {
        _showErrorMessage(e.message?.toString() ?? e.toString());
      }
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
