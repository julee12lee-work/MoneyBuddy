import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] AuthService - 인증 서비스
/// [Description]
/// Firebase Auth를 통한 인증 및 Firestore 유저 프로필 관리
///
/// * [Collaborators Note]
/// - 광진: 이 서비스가 Firebase Auth + Firestore 유저 생성의 핵심 로직
/// - 광진: 탈퇴 시 서브컬렉션(expenses, budgets) 삭제 로직 포함
/// - 원준: 로그인 후 UserProfile.personaType으로 AI 프롬프트 분기

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인한 유저
  User? get currentUser => _auth.currentUser;

  /// 인증 상태 변화 스트림
  /// [광진] main.dart에서 StreamBuilder로 로그인/로그아웃 감지에 사용
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google 소셜 로그인
  /// [Flow] GoogleSignIn → Firebase Auth → Firestore 유저 문서 생성
  /// [광진] 이 메서드가 전체 로그인 파이프라인
  Future<UserCredential?> signInWithGoogle() async {
    // Windows 데스크톱은 Google Sign-In 미지원
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      throw UnsupportedError(
        'Windows에서는 Google Sign-In이 지원되지 않습니다. '
        'Android 에뮬레이터 또는 웹으로 실행하세요.',
      );
    }

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
    if (googleUser == null) return null; // 사용자 취소

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw StateError(
        'Google idToken이 null입니다. '
        'Firebase 콘솔에서 SHA-1 등록 및 google-services.json을 확인하세요.',
      );
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // [광진] 신규 유저일 경우 Firestore에 프로필 문서 생성
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await _createUserProfile(userCredential.user!);
    }

    return userCredential;
  }

  /// 게스트 로그인 (익명 인증)
  /// [광진] 익명 유저도 Firestore 프로필 생성
  Future<UserCredential> signInAnonymously() async {
    final UserCredential userCredential = await _auth.signInAnonymously();

    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await _createUserProfile(userCredential.user!);
    }

    return userCredential;
  }

  /// Firestore에 신규 유저 프로필 생성
  /// [광진] users/{uid} 문서 생성
  Future<void> _createUserProfile(User user) async {
    final profile = UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? '사용자',
      photoUrl: user.photoURL,
    );

    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
  }

  /// 현재 유저 프로필 조회
  /// [광진] SideMenu, DashboardScreen에서 유저 정보 표시에 사용
  Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserProfile.fromDoc(doc);
  }

  /// 유저 프로필 업데이트 (페르소나, 예산, 알림 등)
  /// [광진] 설정 변경 시 호출
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  /// 로그아웃
  /// [광진] SideMenu의 로그아웃 버튼에서 호출
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 회원 탈퇴
  /// [광진] 유저 데이터 삭제 → Firebase Auth 계정 삭제 순서 중요
  /// [주의] 서브컬렉션(expenses, budgets)은 Cloud Functions 트리거로 삭제 권장
  ///        여기서는 클라이언트 측 삭제로 우선 구현
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;

    final String uid = user.uid;

    // 1. 서브컬렉션 삭제 (expenses)
    final expenses = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }

    // 2. 서브컬렉션 삭제 (budgets)
    final budgets = await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();
    for (final doc in budgets.docs) {
      await doc.reference.delete();
    }

    // 3. 유저 프로필 문서 삭제
    await _firestore.collection('users').doc(uid).delete();

    // 4. Firebase Auth 계정 삭제
    await user.delete();
  }
}
