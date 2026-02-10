import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/expense_statistics.dart';
import '../widgets/statistics/buddy_advice_card.dart';
import '../widgets/statistics/expense_donut_chart.dart';
import '../widgets/statistics/change_highlight_card.dart';
import '../widgets/statistics/category_detail_list.dart';
import '../widgets/statistics/weekly_trend_chart.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] StatisticsScreen - 지출 통계 화면
/// [Author] 이준수 (PM & Design)
///
/// [Description]
/// 사용자의 지출 통계를 다양한 차트와 카드로 시각화하는 화면입니다.
///
/// [주요 기능]
/// 1. 버디 조언 카드 - AI가 분석한 소비 패턴 조언
/// 2. 도넛 차트 - 카테고리별 지출 비율 시각화
/// 3. 변화 카드 - 전월 대비 증가/감소 카테고리
/// 4. 카테고리 목록 - 각 카테고리별 예산 대비 사용률
/// 5. 트렌드 차트 - 7일간 지출 추이 라인 그래프
///
/// [화면 구조]
/// ┌─────────────────────────────────┐
/// │  ← 지출 통계        [이번 달 ▼] │  ← 헤더 (뒤로가기 + 기간 선택)
/// ├─────────────────────────────────┤
/// │  🤖 버디의 직설 조언            │  ← BuddyAdviceCard
/// ├─────────────────────────────────┤
/// │      [도넛 차트]                │  ← ExpenseDonutChart
/// │      총 1,245,600원             │
/// ├─────────────────────────────────┤
/// │  가장 큰 변화 (전월 대비)       │  ← ChangeHighlightCard
/// │  ☕ 카페 +54,000원 증가         │
/// │  🚗 교통 -28,000원 절약         │
/// ├─────────────────────────────────┤
/// │  카테고리별 상세                │  ← CategoryDetailList
/// │  🍔 식비 ████████░░ 93%        │
/// ├─────────────────────────────────┤
/// │  7일간 지출 추이                │  ← WeeklyTrendChart
/// │  📈 [라인 차트]                 │
/// └─────────────────────────────────┘
///
/// [Collaborators Note]
/// - 원준: 통계 데이터 API 연동 및 캐싱 로직 담당 예정
/// - 광진: 차트 애니메이션 및 인터랙션 개선 담당 예정
/// - 추후 Firebase Analytics 연동하여 실제 데이터 반영 예정

class StatisticsScreen extends StatefulWidget {
  /// 선택된 페르소나 인덱스 (0: F-type, 1: S-type, 2: T-type)
  /// [Usage] 버디 조언 카드의 아이콘과 말투 스타일에 영향
  final int selectedPersonaIndex;

  /// 뒤로가기 버튼 클릭 시 호출되는 콜백
  /// [Usage] main.dart에서 DashboardScreen으로 복귀할 때 사용
  final VoidCallback? onBack;

  const StatisticsScreen({
    super.key,
    required this.selectedPersonaIndex,
    this.onBack,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ============================================================
  // [A] 상태 관리 영역
  // ============================================================
  // 이 섹션에서는 화면에서 사용하는 모든 상태 변수를 정의합니다.
  // 새로운 상태가 필요하면 여기에 추가하세요.
  // ============================================================

  /// 통계 데이터 객체
  /// [Note] 현재는 Mock 데이터 사용, 추후 API 연동 시 교체 필요
  late ExpenseStatistics statistics;

  /// 선택된 기간 필터 ('week' | 'month')
  /// [Usage] 헤더의 드롭다운에서 변경, 데이터 리로드에 영향
  String selectedPeriod = 'month';

  // ============================================================
  // [B] 라이프사이클 메서드
  // ============================================================
  // initState, dispose 등 위젯 생명주기 관련 메서드입니다.
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // ============================================================
  // [C] 비즈니스 로직 메서드
  // ============================================================
  // 데이터 로드, 계산, API 호출 등 비즈니스 로직을 담당합니다.
  // UI와 분리하여 테스트 및 유지보수가 용이하도록 합니다.
  // ============================================================

  /// 통계 데이터를 로드합니다.
  /// [TODO] 원준 - Firebase에서 실제 데이터 가져오는 로직으로 교체 필요
  /// [Parameters] selectedPeriod에 따라 주간/월간 데이터 분기
  void _loadStatistics() {
    // TODO: 실제 데이터 로드 로직으로 교체
    // 예시: statistics = await StatisticsService.fetch(selectedPeriod);
    statistics = ExpenseStatistics.mock();
  }

  // ============================================================
  // [D] UI 렌더링 영역
  // ============================================================
  // build 메서드와 주요 레이아웃 구성을 담당합니다.
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
      body: Center(
        child: Container(
          // 모바일 최적화: 최대 너비 430px로 제한
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundCard,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 상단 헤더 (뒤로가기 + 타이틀 + 기간 선택)
                _buildHeader(),

                // 스크롤 가능한 콘텐츠 영역
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingXLarge,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppDimensions.paddingMedium),

                        // [위젯 1] 버디 조언 카드
                        BuddyAdviceCard(
                          advice: statistics.buddyAdvice,
                          selectedPersonaIndex: widget.selectedPersonaIndex,
                        ),
                        const SizedBox(height: AppDimensions.cardSpacing),

                        // [위젯 2] 도넛 차트 (카테고리별 지출 비율)
                        ExpenseDonutChart(
                          categories: statistics.categories,
                          totalExpense: statistics.totalExpense,
                        ),
                        const SizedBox(height: AppDimensions.cardSpacing),

                        // [위젯 3] 가장 큰 변화 카드 (전월 대비)
                        ChangeHighlightCard(
                          increase: statistics.biggestIncrease,
                          decrease: statistics.biggestDecrease,
                        ),
                        const SizedBox(height: AppDimensions.cardSpacing),

                        // [위젯 4] 카테고리별 상세 목록
                        CategoryDetailList(
                          categories: statistics.categories,
                        ),
                        const SizedBox(height: AppDimensions.cardSpacing),

                        // [위젯 5] 7일간 지출 추이 라인 차트
                        WeeklyTrendChart(
                          dailyData: statistics.weeklyTrend,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // [E] 컴포넌트 빌더 메서드
  // ============================================================
  // _build로 시작하는 작은 위젯 조각들을 여기에 정의합니다.
  // 재사용성이 높으면 별도 위젯 파일로 분리하는 것을 고려하세요.
  // ============================================================

  /// 상단 헤더를 빌드합니다.
  /// [구성] 뒤로가기 버튼 | 타이틀 (중앙) | 기간 선택 드롭다운
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Stack을 사용하여 타이틀을 정확히 중앙에 배치
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 타이틀 (Stack의 중앙에 고정)
          Text(
            '지출 통계',
            style: AppTextStyles.h4,
          ),
          // 좌우 버튼들을 Row로 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 뒤로가기 버튼
              IconButton(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              // 오른쪽: 기간 선택 드롭다운
              _buildPeriodSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      onSelected: (value) {
        setState(() {
          selectedPeriod = value;
          _loadStatistics();
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'week',
          child: Row(
            children: [
              Icon(
                selectedPeriod == 'week'
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 18,
                color: selectedPeriod == 'week'
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              const Text('이번 주'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'month',
          child: Row(
            children: [
              Icon(
                selectedPeriod == 'month'
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 18,
                color: selectedPeriod == 'month'
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              const Text('이번 달'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall + 4,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedPeriod == 'week' ? '이번 주' : '이번 달',
              style: AppTextStyles.captionBold.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
