/// [Project] Buddy - AI 가계부 서비스
/// [File] ExpenseStatistics - 지출 통계 데이터 모델
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 지출 통계 화면에서 사용하는 데이터 모델 정의
/// 카테고리별 지출, 일별 지출, 변화량 등을 관리
library;

/// 카테고리별 지출 데이터
class CategoryExpense {
  final String icon;
  final String name;
  final int spent;
  final int budget;
  final double percentage; // 전체 지출 대비 비율

  const CategoryExpense({
    required this.icon,
    required this.name,
    required this.spent,
    required this.budget,
    required this.percentage,
  });

  /// 예산 대비 사용 비율
  double get usageRatio => budget > 0 ? spent / budget : 0.0;

  /// 예산 초과 여부
  bool get isOverBudget => spent > budget;
}

/// 전월 대비 변화량 데이터
class CategoryChange {
  final String icon;
  final String name;
  final int difference; // 금액 차이 (양수: 증가, 음수: 감소)
  final double percentageChange; // 증감률

  const CategoryChange({
    required this.icon,
    required this.name,
    required this.difference,
    required this.percentageChange,
  });

  /// 증가 여부
  bool get isIncrease => difference > 0;
}

/// 일별 지출 데이터
class DailyExpense {
  final DateTime date;
  final int amount;

  const DailyExpense({
    required this.date,
    required this.amount,
  });
}

/// 전체 지출 통계 데이터
class ExpenseStatistics {
  final int totalExpense;
  final int totalBudget;
  final List<CategoryExpense> categories;
  final List<DailyExpense> weeklyTrend;
  final CategoryChange? biggestIncrease;
  final CategoryChange? biggestDecrease;
  final String buddyAdvice;

  const ExpenseStatistics({
    required this.totalExpense,
    required this.totalBudget,
    required this.categories,
    required this.weeklyTrend,
    this.biggestIncrease,
    this.biggestDecrease,
    required this.buddyAdvice,
  });

  /// Mock 데이터 생성
  factory ExpenseStatistics.mock() {
    return ExpenseStatistics(
      totalExpense: 1245600,
      totalBudget: 2000000,
      categories: const [
        CategoryExpense(
          icon: '🍔',
          name: '식비',
          spent: 560520,
          budget: 600000,
          percentage: 45,
        ),
        CategoryExpense(
          icon: '🛍️',
          name: '쇼핑',
          spent: 373680,
          budget: 400000,
          percentage: 30,
        ),
        CategoryExpense(
          icon: '🚗',
          name: '교통',
          spent: 186840,
          budget: 200000,
          percentage: 15,
        ),
        CategoryExpense(
          icon: '☕',
          name: '카페',
          spent: 124560,
          budget: 100000,
          percentage: 10,
        ),
      ],
      weeklyTrend: [
        DailyExpense(date: DateTime(2026, 1, 21), amount: 45000),
        DailyExpense(date: DateTime(2026, 1, 22), amount: 78000),
        DailyExpense(date: DateTime(2026, 1, 23), amount: 32000),
        DailyExpense(date: DateTime(2026, 1, 24), amount: 156000),
        DailyExpense(date: DateTime(2026, 1, 25), amount: 67000),
        DailyExpense(date: DateTime(2026, 1, 26), amount: 89000),
        DailyExpense(date: DateTime(2026, 1, 27), amount: 54000),
      ],
      biggestIncrease: const CategoryChange(
        icon: '☕',
        name: '카페/간식',
        difference: 54000,
        percentageChange: 43,
      ),
      biggestDecrease: const CategoryChange(
        icon: '🚗',
        name: '교통비',
        difference: -28000,
        percentageChange: -15,
      ),
      buddyAdvice: '준수 님, 이번 달 카페 지출이 예산을 24% 초과했어요! 집에서 커피 내려 마시는 건 어떨까요? ☕',
    );
  }
}
