import 'package:cloud_firestore/cloud_firestore.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] Expense Model - 지출 데이터 모델
/// [Description]
/// Firestore users/{uid}/expenses 서브컬렉션과 매핑되는 핵심 모델
///
/// * [Collaborators Note]
/// - 광진: toMap()/fromDoc()으로 Firestore CRUD 연동
/// - 원준: category, aiComment 필드를 AI 피드백에 활용
/// - 준수: FeedCard에서 이 모델을 직접 수신

class Expense {
  final String id;

  /// [광진] 소유자 UID (users/{uid}/expenses 경로에 사용)
  final String uid;

  final String title;
  final String category;
  final String icon;
  final int amount; // 지출은 음수
  final Timestamp? createdAt;

  /// [원준] AI 피드백 코멘트 (Gemini API 응답 저장용)
  final String? aiComment;

  /// 사용자 메모
  final String? memo;

  const Expense({
    this.id = '',
    this.uid = '',
    required this.title,
    required this.category,
    required this.icon,
    required this.amount,
    this.createdAt,
    this.aiComment,
    this.memo,
  });

  /// Firestore 저장용 Map 변환
  /// [광진] ExpenseService.addExpense에서 호출
  Map<String, dynamic> toMap() {
    final now = Timestamp.now();
    return {
      'title': title,
      'category': category,
      'icon': icon,
      'amount': amount,
      'createdAt': createdAt ?? now,
      'serverCreatedAt': FieldValue.serverTimestamp(),
      'updatedAt': now,
      'serverUpdatedAt': FieldValue.serverTimestamp(),
      if (aiComment != null) 'aiComment': aiComment,
      if (memo != null) 'memo': memo,
    };
  }

  /// Firestore 문서 → Expense 객체 변환
  factory Expense.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Expense(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      title: (d['title'] as String?)?.trim().isNotEmpty == true
          ? d['title'] as String
          : (d['category'] as String? ?? '지출'),
      category: d['category'] as String? ?? '기타',
      icon: d['icon'] as String? ?? '🧾',
      amount: (d['amount'] as num?)?.toInt() ?? 0,
      createdAt: d['createdAt'] as Timestamp?,
      aiComment: d['aiComment'] as String?,
      memo: d['memo'] as String?,
    );
  }

  /// 수정용 copyWith
  Expense copyWith({
    String? title,
    String? category,
    String? icon,
    int? amount,
    String? aiComment,
    String? memo,
  }) {
    return Expense(
      id: id,
      uid: uid,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      amount: amount ?? this.amount,
      createdAt: createdAt,
      aiComment: aiComment ?? this.aiComment,
      memo: memo ?? this.memo,
    );
  }
}
