import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/main_header.dart';
import '../widgets/feed_header.dart';
import '../widgets/feed_card.dart';
import '../widgets/persona_speech_bubble.dart';
import '../widgets/monthly_calendar.dart';
import '../widgets/side_menu.dart';
import '../widgets/floating_input.dart';
import '../widgets/category_selection_board.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] DashboardScreen - 메인 대시보드 화면
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 사용자의 지출 내역을 관리하고 AI 버디의 피드백을 받는 메인 화면
/// 리스트 뷰와 캘린더 뷰를 전환할 수 있으며, 자연어 입력을 통한 지출 기록 기능 제공
/// 
/// * [Collaborators Note]
/// - 원준: SmartInputBar(FloatingInput)의 NLP 파싱 로직 고도화 담당
/// - 광진: 사이드 메뉴 애니메이션 및 페르소나 말풍선 인터랙션 개선 담당
/// - 추후 백엔드 연동 시 Mock 데이터를 API 호출로 교체 예정

class DashboardScreen extends StatefulWidget {
  final int selectedPersonaIndex;
  final VoidCallback? onNavigateToPersona;
  final VoidCallback? onNavigateToStatistics;
  final VoidCallback? onNavigateToSettings;

  const DashboardScreen({
    super.key,
    required this.selectedPersonaIndex,
    this.onNavigateToPersona,
    this.onNavigateToStatistics,
    this.onNavigateToSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- [A] 상태 관리 영역 ---
  
  bool isCategoryMode = false;
  int? tempAmount;
  bool isMenuOpen = false;
  String viewMode = 'list'; // ← [Fix] 'calendar' → 'list'로 변경!

  // --- [B] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    // [Data] 선택된 페르소나 데이터 및 브랜드 컬러 로드
    final selectedPersona = personaData[widget.selectedPersonaIndex];
    final Color personaColor = selectedPersona.color;
    const Color brandColor = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _buildMainScrollArea(personaColor, brandColor),
              ),

              if (isMenuOpen)
                GestureDetector(
                  onTap: () => setState(() => isMenuOpen = false),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),

              _buildSideMenuDrawer(),

              if (!isMenuOpen && !isCategoryMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: FloatingInput(
                      onAmountParsed: (amount) {
                        setState(() {
                          tempAmount = amount;
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

  // --- [C] 컴포넌트 빌더 메서드 ---

  Widget _buildMainScrollArea(Color personaColor, Color brandColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppDimensions.bottomInputPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainHeader(
            budgetRemaining: 2847500,
            totalBudget: 5000000,
            selectedPersonaIndex: widget.selectedPersonaIndex,
            onMenuPressed: () => setState(() => isMenuOpen = true),
          ),
          const SizedBox(height: AppDimensions.cardSpacing),

          if (isCategoryMode)
            CategorySelectionBoard(
              amount: tempAmount ?? 0,
              brandColor: brandColor,
              onCategorySelected: (category) {
                setState(() => isCategoryMode = false);
              },
              onCancel: () {
                setState(() {
                  isCategoryMode = false;
                  tempAmount = null;
                });
              },
            )
          else ...[
            FeedHeader(
              viewMode: viewMode,
              onViewModeChange: (mode) => setState(() => viewMode = mode),
            ),
            const SizedBox(height: AppDimensions.cardSpacing),
            viewMode == 'calendar'
                ? const MonthlyCalendar()
                : _buildTransactionList(personaColor),
          ],
        ],
      ),
    );
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
            if (index == 1 && widget.onNavigateToPersona != null) {
              widget.onNavigateToPersona!();
            } else if (index == 2 && widget.onNavigateToStatistics != null) {
              widget.onNavigateToStatistics!();
            } else if (index == 3 && widget.onNavigateToSettings != null) {
              widget.onNavigateToSettings!();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList(Color personaColor) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium + 4),
      child: Column(
        children: [
          const FeedCard(
            icon: "☕",
            title: "스타벅스",
            amount: -5500,
            category: "카페",
          ),
          PersonaSpeechBubble(
            previewMessage: "오늘도 스타벅스네요!",
            fullMessage: "카페 지출이 늘고 있어요. 내일은 집 커피 어떠세요?",
            type: "positive",
            relatedTo: "스타벅스",
            amount: 5500,
            color: personaColor,
          ),
          const SizedBox(height: AppDimensions.cardSpacing),
          const FeedCard(
            icon: "🚗",
            title: "카카오택시",
            amount: -18750,
            category: "교통",
          ),
          const SizedBox(height: AppDimensions.cardSpacing),
          const FeedCard(
            icon: "🛍️",
            title: "백화점 쇼핑",
            amount: -287000,
            category: "쇼핑",
          ),
          PersonaSpeechBubble(
            previewMessage: "예산을 조금 넘겼어요!",
            fullMessage: "우와, 이번 지출은 조금 컸네요!",
            type: "warning",
            relatedTo: "백화점 쇼핑",
            amount: 287000,
            color: personaColor,
          ),
        ],
      ),
    );
  }
}