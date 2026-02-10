import 'package:cloud_firestore/cloud_firestore.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] Budget Model - 예산/목표 데이터 모델
/// [Description]
/// 월별 예산 목표를 관리하는 모델
/// Firestore의 users/{uid}/budgets/{month} 문서와 매핑
///
/// * [Collaborators Note]
/// - 광진: 예산 설정 화면에서 Firestore에 저장/수정
/// - 원준: AI 피드백 시 예산 초과 여부 판단에 사용

class Budget {
  /// Firestore 문서 ID (형식: "2026-02")
  final String month;

  /// 소유자 UID
  final String uid;

  /// 목표 금액 (원 단위)
  final int targetAmount;

  /// 목표 설명 (예: "여행 자금 모으기")
  final String? goalDescription;

  Budget({
    required this.month,
    required this.uid,
    required this.targetAmount,
    this.goalDescription,
  });

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'uid': uid,
      'targetAmount': targetAmount,
      'goalDescription': goalDescription,
    };
  }

  /// Firestore 문서 → Budget 객체 변환
  factory Budget.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      month: data['month'] ?? doc.id,
      uid: data['uid'] ?? '',
      targetAmount: data['targetAmount'] ?? 0,
      goalDescription: data['goalDescription'],
    );
  }
}
