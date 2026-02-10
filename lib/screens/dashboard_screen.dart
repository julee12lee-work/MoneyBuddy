import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../models/expense.dart';
import '../models/expense_draft.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

import '../widgets/main_header.dart';
import '../widgets/feed_header.dart';
import '../widgets/feed_card.dart';
import '../widgets/persona_speech_bubble.dart';
import '../widgets/monthly_calendar.dart';
import '../widgets/side_menu.dart';
import '../widgets/floating_input.dart';
import '../widgets/category_selection_board.dart';
import '../widgets/budget_setting_dialog.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] DashboardScreen - 메인 대시보드
/// [Description]
/// Provider에서 유저/지출 데이터를 구독하여 실시간 렌더링
///
/// * [Collaborators Note]
/// - 광진: ExpenseProvider가 Firestore 실시간 스트림 제공
/// - 원준: PersonaSpeechBubble의 AI 코멘트 연동 예정
/// - 준수: FeedCard, FloatingInput 등 위젯 조합
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isCategoryMode = false;
  int? tempAmount; // 양수 금액
  String? tempTitle;

  bool isMenuOpen = false;
  String viewMode = 'list';

  DateTime _calendarSelectedDate = DateTime.now();

  // 삭제 UI 문구(상수 파일에 없을 수 있어서 여기서 직접 관리)
  static const String _deleteTitle = '지출 삭제';
  static const String _deleteMessage = '이 내역을 삭제할까요?';
  static const String _cancelText = '취소';
  static const String _deleteText = '삭제';
  static const String _deletedSnack = '삭제되었습니다.';
  static const String _deleteFailedSnack = '삭제에 실패했습니다.';

  @override
  Widget build(BuildContext context) {
    // [광진] AuthProvider에서 페르소나 인덱스 가져오기
    final authProvider = context.watch<AuthProvider>();
    final personaType = authProvider.userProfile?.personaType ?? 'F-type';
    final selectedPersonaIndex = personaData.indexWhere((p) => p.type == personaType).clamp(0, personaData.length - 1);
    final selectedPersona = personaData[selectedPersonaIndex];
    final Color personaColor = selectedPersona.color;
    const Color brandColor = AppColors.primary;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          constraints:
          const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _buildMainScrollArea(
                  uid: user.uid,
                  personaColor: personaColor,
                  brandColor: brandColor,
                  selectedPersonaIndex: selectedPersonaIndex,
                ),
              ),
              if (isMenuOpen)
                GestureDetector(
                  onTap: () => setState(() => isMenuOpen = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              _buildSideMenuDrawer(),
              if (!isMenuOpen && !isCategoryMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: FloatingInput(
                      // 기존 파서(금액만)
                      onAmountParsed: (amount) {
                        setState(() {
                          tempAmount = amount;
                          isCategoryMode = true;
                        });
                      },
                      // 개선 파서(제목 포함)
                      onDraftParsed: (ExpenseDraft draft) {
                        setState(() {
                          tempAmount = draft.amountAbs;
                          tempTitle = draft.title;
                          isCategoryMode = true;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBudgetSettingDialog({
    required String uid,
    required int currentBudget,
    required int currentStartDay,
  }) {
    BudgetSettingDialog.show(
      context: context,
      currentBudget: currentBudget,
      currentStartDay: currentStartDay,
      onSave: (budget, startDay) async {
        try {
          await FirestoreService.setBudgetSettings(
            uid: uid,
            monthlyBudget: budget,
            startDay: startDay,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('예산이 설정되었습니다.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('예산 설정 실패: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildMainScrollArea({
    required String uid,
    required Color personaColor,
    required Color brandColor,
    required int selectedPersonaIndex,
  }) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirestoreService.watchBudgetSettings(uid),
      builder: (context, budgetSnapshot) {
        final budgetData = budgetSnapshot.data ?? {'monthlyBudget': 1000000, 'budgetStartDay': 1};
        final int totalBudget = budgetData['monthlyBudget'] as int;
        final int startDay = budgetData['budgetStartDay'] as int;

        return StreamBuilder<List<Expense>>(
          stream: FirestoreService.watchThisMonthExpenses(uid),
          builder: (context, snapshot) {
            final expenses = snapshot.data ?? const <Expense>[];

            final int sum = expenses.fold<int>(0, (s, e) => s + e.amount);
            final int budgetRemaining = totalBudget + sum;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppDimensions.bottomInputPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeader(
                    budgetRemaining: budgetRemaining,
                    totalBudget: totalBudget,
                    selectedPersonaIndex: selectedPersonaIndex,
                    onMenuPressed: () => setState(() => isMenuOpen = true),
                    onBudgetTapped: () => _openBudgetSettingDialog(
                      uid: uid,
                      currentBudget: totalBudget,
                      currentStartDay: startDay,
                    ),
                  ),
              const SizedBox(height: AppDimensions.cardSpacing),

              if (isCategoryMode)
                CategorySelectionBoard(
                  amount: tempAmount ?? 0,
                  brandColor: brandColor,
                  onCategorySelected: (category) async {
                    await _saveExpense(uid: uid, category: category);
                  },
                  onCancel: () {
                    setState(() {
                      isCategoryMode = false;
                      tempAmount = null;
                      tempTitle = null;
                    });
                  },
                )
              else ...[
                FeedHeader(
                  viewMode: viewMode,
                  onViewModeChange: (mode) => setState(() => viewMode = mode),
                ),
                const SizedBox(height: AppDimensions.cardSpacing),

                // ✅ 여기(달력/리스트 분기) 문법 깨졌던 부분을 정상 형태로 정리
                viewMode == 'calendar'
                    ? Column(
                  children: [
                    MonthlyCalendar(
                      expenses: expenses,
                      onDateSelected: (date) {
                        setState(() => _calendarSelectedDate = date);
                      },
                    ),
                    const SizedBox(height: AppDimensions.cardSpacing),
                    _buildSelectedDayExpenses(
                      expenses: expenses,
                      selectedDate: _calendarSelectedDate,
                      personaColor: personaColor,
                    ),
                  ],
                )
                    : _buildTransactionList(
                  uid: uid,
                  expenses: expenses,
                  personaColor: personaColor,
                ),
              ],
            ],
          ),
        );
          },
        );
      },
    );
  }

  Future<void> _saveExpense({
    required String uid,
    required String category,
  }) async {
    final amountAbs = tempAmount;
    if (amountAbs == null || amountAbs <= 0) return;

    final title =
    (tempTitle?.trim().isNotEmpty == true) ? tempTitle!.trim() : category;

    try {
      await FirestoreService.addExpense(
        uid: uid,
        title: title,
        category: category,
        amountAbs: amountAbs,
      );

      if (!mounted) return;
      setState(() {
        isCategoryMode = false;
        tempAmount = null;
        tempTitle = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지출이 저장되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSideMenuDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      right: isMenuOpen ? 0 : -(AppDimensions.sideMenuWidth + 10),
      top: 0,
      bottom: 0,
      child: Container(
        width: AppDimensions.sideMenuWidth,
        decoration: const BoxDecoration(
          color: AppColors.background,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: SideMenu(
          isOpen: isMenuOpen,
          onClose: () => setState(() => isMenuOpen = false),
          onMenuSelected: (index) {
            setState(() => isMenuOpen = false);
            if (index == 1) {
              context.go('/persona');
            } else if (index == 2) {
              context.go('/statistics');
            } else if (index == 3) {
              context.go('/settings');
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList({
    required String uid,
    required List<Expense> expenses,
    required Color personaColor,
  }) {
    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium + 4),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: const Text(
            '아직 이번 달 지출 내역이 없어요.\n아래 입력창에서 "커피 1000"처럼 입력해보세요!',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final widgets = <Widget>[];

    for (final e in expenses) {
      widgets.add(
        Dismissible(
          key: ValueKey('expense_${e.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '삭제',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(_deleteTitle),
                content: const Text(_deleteMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(_cancelText),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(_deleteText),
                  ),
                ],
              ),
            );
            return ok ?? false;
          },
          onDismissed: (_) async {
            try {
              await FirestoreService.deleteExpense(uid: uid, expenseId: e.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(_deletedSnack),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(_deleteFailedSnack),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: FeedCard(
            icon: e.icon,
            title: e.title,
            amount: e.amount,
            category: e.category,
          ),
        ),
      );

      // 말풍선 로직 유지
      final abs = e.amount.abs();
      if (e.category == '카페') {
        widgets.add(
          PersonaSpeechBubble(
            previewMessage: "카페 지출이 기록됐어요!",
            fullMessage: "${e.title}에 ${abs}원 썼네요. 내일은 집커피도 좋아요 🙂",
            type: "positive",
            relatedTo: e.title,
            amount: abs,
            color: personaColor,
          ),
        );
      }

      widgets.add(const SizedBox(height: AppDimensions.cardSpacing));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium + 4),
      child: Column(children: widgets),
    );
  }

  Widget _buildSelectedDayExpenses({
    required List<Expense> expenses,
    required DateTime selectedDate,
    required Color personaColor,
  }) {
    bool isSameDate(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final dayExpenses = expenses.where((e) {
      final ts = e.createdAt;
      if (ts == null) return false;
      return isSameDate(ts.toDate(), selectedDate);
    }).toList();

    final title = '${selectedDate.month}월 ${selectedDate.day}일 내역';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium + 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (dayExpenses.isEmpty)
              const Text(
                '선택한 날짜에 지출 내역이 없어요.',
                style: TextStyle(color: Colors.black54),
              )
            else
              Column(
                children: dayExpenses.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FeedCard(
                      icon: e.icon,
                      title: e.title,
                      amount: e.amount,
                      category: e.category,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
