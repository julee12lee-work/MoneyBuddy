import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] AuthProvider - 인증 상태 관리
/// [Description]
/// AuthService를 래핑하여 앱 전체에서 인증 상태를 공유하는 ChangeNotifier
/// Provider 패턴으로 UI에 반응형 상태 전달
///
/// * [Collaborators Note]
/// - 광진: AuthService 호출을 이 Provider가 중개
/// - 원준: userProfile.personaType으로 AI 프롬프트 분기
/// - 준수: Consumer/context.watch로 UI 바인딩

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  /// 현재 Firebase Auth 유저
  User? get user => _user;

  /// 현재 유저 프로필 (Firestore)
  UserProfile? get userProfile => _userProfile;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 로그인 여부
  bool get isLoggedIn => _user != null;

  /// 에러 메시지
  String? get error => _error;

  AuthProvider() {
    // 앱 시작 시 인증 상태 리스닝
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// 인증 상태 변경 콜백
  /// [광진] Firebase Auth 상태가 바뀔 때 자동 호출
  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;

    if (user != null) {
      _userProfile = await _authService.getUserProfile();
    } else {
      _userProfile = null;
    }

    notifyListeners();
  }

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        // 사용자 취소
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on UnsupportedError catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '로그인에 실패했습니다. 다시 시도해주세요.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 게스트 로그인
  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '로그인에 실패했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 페르소나 타입 업데이트
  /// [원준] 페르소나 변경 시 AI 프롬프트도 함께 변경됨
  Future<void> updatePersonaType(String personaType) async {
    await _authService.updateUserProfile({'personaType': personaType});
    _userProfile = _userProfile?.copyWith(personaType: personaType);
    notifyListeners();
  }

  /// 월 예산 업데이트
  Future<void> updateMonthlyBudget(int budget) async {
    await _authService.updateUserProfile({'monthlyBudget': budget});
    _userProfile = _userProfile?.copyWith(monthlyBudget: budget);
    notifyListeners();
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    // _onAuthStateChanged가 자동으로 상태 정리
  }

  /// 회원 탈퇴
  /// [광진] 서브컬렉션 삭제 → 프로필 삭제 → Auth 삭제
  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount();
    } catch (e) {
      _error = '탈퇴 처리 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
