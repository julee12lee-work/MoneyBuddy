import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] ExpenseService - 지출 CRUD 서비스
/// [Description]
/// Firestore users/{uid}/expenses 서브컬렉션에 대한 모든 CRUD 연산 담당
///
/// * [Collaborators Note]
/// - 광진: 이 서비스가 Firestore 지출 데이터의 핵심 CRUD 레이어
/// - 원준: addExpense 호출 후 AI 피드백 요청 트리거 예정
/// - 준수: Stream을 FeedCard 리스트에 연결하여 실시간 UI 업데이트

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 유저별 expenses 컬렉션 참조 헬퍼
  CollectionReference _expensesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  /// 지출 추가 (Create)
  /// [광진] FloatingInput에서 금액+카테고리 확정 후 호출
  /// [원준] 반환된 docId로 AI 피드백 요청 후 aiComment 업데이트 예정
  Future<String> addExpense(Expense expense) async {
    final docRef = await _expensesRef(expense.uid).add(expense.toMap());
    return docRef.id;
  }

  /// 지출 내역 실시간 스트림 (Read - Stream)
  /// [광진] 월별 데이터를 Stream으로 반환, UI에서 StreamBuilder/Provider로 구독
  /// [param] month: "2026-02" 형식
  Stream<List<Expense>> getExpensesStream(String uid, {String? month}) {
    Query query = _expensesRef(uid).orderBy('createdAt', descending: true);

    // 월별 필터링
    if (month != null) {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final start = DateTime(year, m, 1);
      final end = DateTime(year, m + 1, 1);

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end));
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromDoc(doc)).toList();
    });
  }

  /// 지출 수정 (Update)
  /// [광진] FeedCard 확장 패널에서 별명/메모/감정 수정 시 호출
  Future<void> updateExpense(String uid, String expenseId, Map<String, dynamic> updates) async {
    await _expensesRef(uid).doc(expenseId).update(updates);
  }

  /// 지출 삭제 (Delete)
  /// [광진] FeedCard 스와이프 삭제 또는 삭제 버튼 시 호출
  Future<void> deleteExpense(String uid, String expenseId) async {
    await _expensesRef(uid).doc(expenseId).delete();
  }

  /// 이번 달 총 지출액 계산
  /// [광진] MainHeader의 예산 잔여 계산에 사용
  Future<int> getMonthlyTotal(String uid, String month) async {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final start = DateTime(year, m, 1);
    final end = DateTime(year, m + 1, 1);

    final snapshot = await _expensesRef(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      total += (doc['amount'] as num).toInt();
    }
    return total;
  }
}
