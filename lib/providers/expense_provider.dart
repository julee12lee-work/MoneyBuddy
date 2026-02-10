import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] ExpenseProvider - 지출 상태 관리
/// [Description]
/// ExpenseService를 래핑하여 지출 내역의 실시간 상태를 UI에 전달
/// 월별 데이터 스트림, 총 지출액, CRUD 연산 관리
///
/// * [Collaborators Note]
/// - 광진: ExpenseService 호출을 이 Provider가 중개
/// - 원준: addExpense 후 aiComment 업데이트 로직 연동 포인트
/// - 준수: context.watch<ExpenseProvider>()로 FeedCard 리스트 빌드

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  String? _uid;
  String _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<Expense> _expenses = [];
  int _monthlyTotal = 0;
  bool _isLoading = false;
  StreamSubscription? _expensesSub;

  /// 현재 월의 지출 내역 리스트
  List<Expense> get expenses => _expenses;

  /// 현재 월 총 지출액
  int get monthlyTotal => _monthlyTotal;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 현재 조회 중인 월 ("2026-02")
  String get currentMonth => _currentMonth;

  /// 유저 UID 설정 및 데이터 스트림 시작
  /// [광진] AuthProvider에서 로그인 성공 후 이 메서드 호출
  void setUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _listenToExpenses();
  }

  /// 월 변경
  void changeMonth(String month) {
    _currentMonth = month;
    _listenToExpenses();
  }

  /// Firestore 실시간 스트림 구독
  /// [광진] getExpensesStream이 Firestore 변경을 실시간 감지
  void _listenToExpenses() {
    _expensesSub?.cancel();

    if (_uid == null) return;

    _isLoading = true;
    notifyListeners();

    _expensesSub = _expenseService
        .getExpensesStream(_uid!, month: _currentMonth)
        .listen((expenses) {
      _expenses = expenses;
      _monthlyTotal = expenses.fold(0, (sum, e) => sum + e.amount);
      _isLoading = false;
      notifyListeners();
    });
  }

  /// 지출 추가
  /// [원준] 반환된 docId로 Gemini API 호출 후 aiComment 업데이트 예정
  Future<String?> addExpense({
    required int amount,
    required String category,
    required String icon,
    String? title,
  }) async {
    if (_uid == null) return null;

    final expense = Expense(
      uid: _uid!,
      amount: amount,
      category: category,
      icon: icon,
      title: title,
    );

    final docId = await _expenseService.addExpense(expense);
    // 스트림이 자동으로 UI를 업데이트하므로 수동 갱신 불필요
    return docId;
  }

  /// 지출 수정 (별명, 메모, 감정 등)
  /// [광진] FeedCard 확장 패널에서 호출
  Future<void> updateExpense(String expenseId, Map<String, dynamic> updates) async {
    if (_uid == null) return;
    await _expenseService.updateExpense(_uid!, expenseId, updates);
  }

  /// 지출 삭제
  Future<void> deleteExpense(String expenseId) async {
    if (_uid == null) return;
    await _expenseService.deleteExpense(_uid!, expenseId);
  }

  /// 유저 변경/로그아웃 시 정리
  void clear() {
    _expensesSub?.cancel();
    _uid = null;
    _expenses = [];
    _monthlyTotal = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _expensesSub?.cancel();
    super.dispose();
  }
}
