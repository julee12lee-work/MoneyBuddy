import 'package:cloud_firestore/cloud_firestore.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] UserProfile Model - 사용자 프로필 데이터 모델
/// [Description]
/// Firestore의 users/{uid} 문서와 1:1 매핑되는 모델
/// 페르소나 설정, 예산, 알림 등 사용자 설정 전체를 관리
///
/// * [Collaborators Note]
/// - 광진: Firebase Auth 로그인 시 이 문서를 생성/업데이트
/// - 광진: 탈퇴 시 이 문서 + 하위 expenses 서브컬렉션 삭제 트리거
/// - 원준: personaType 필드를 AI 피드백 톤 결정에 사용

class UserProfile {
  /// Firebase Auth UID (문서 ID로도 사용)
  final String uid;

  /// 사용자 표시 이름
  final String displayName;

  /// 프로필 이미지 URL (Google 프로필 등)
  final String? photoUrl;

  /// 선택한 페르소나 타입 ("F-type", "S-type", "T-type")
  /// [원준] 이 값으로 AI 피드백 시스템 프롬프트 분기
  final String personaType;

  /// 월 예산 (원 단위)
  /// [광진] 대시보드 MainHeader에서 이 값 표시
  final int monthlyBudget;

  /// 푸시 알림 ON/OFF
  final bool notificationEnabled;

  /// 계정 생성 시각
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.personaType = 'F-type',
    this.monthlyBudget = 0,
    this.notificationEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Firestore 저장용 Map 변환
  /// [광진] AuthService에서 신규 유저 생성 시 호출
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'personaType': personaType,
      'monthlyBudget': monthlyBudget,
      'notificationEnabled': notificationEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Firestore 문서 → UserProfile 객체 변환
  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? '사용자',
      photoUrl: data['photoUrl'],
      personaType: data['personaType'] ?? 'F-type',
      monthlyBudget: data['monthlyBudget'] ?? 0,
      notificationEnabled: data['notificationEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 수정용 copyWith
  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? personaType,
    int? monthlyBudget,
    bool? notificationEnabled,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      personaType: personaType ?? this.personaType,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt,
    );
  }
}
