import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../services/firestore_service.dart';

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
  bool _isLoading = false;

  Future<UserCredential?> _signInWithGoogle() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      throw UnsupportedError(
        'Windows에서는 Google Sign-In이 지원되지 않습니다. Android 에뮬레이터로 실행하세요.',
      );
    }

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize();

      final GoogleSignInAccount? googleUser = await signIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw StateError(
          'Google idToken이 null 입니다. Firebase 콘솔 SHA-1 등록 및 google-services.json 재다운로드/교체를 확인하세요.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
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
      if (result == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.ensureUserDocument(user);
      }

      if (mounted) widget.onLoginSuccess();
    } on UnsupportedError catch (e) {
      if (mounted) _showErrorMessage(e.message?.toString() ?? e.toString());
    } catch (_) {
      if (mounted) _showErrorMessage(AppStrings.errorLoginFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      final user = cred.user;
      if (user != null) {
        await FirestoreService.ensureUserDocument(user);
      }

      if (mounted) widget.onLoginSuccess();
    } catch (_) {
      if (mounted) _showErrorMessage(AppStrings.errorUnknown);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                if (_isLoading) _buildLoadingIndicator() else _buildLoginButtons(),
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
