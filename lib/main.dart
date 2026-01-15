import 'package:flutter/material.dart';
import 'feed_header.dart';
import 'feed_card.dart';
import 'monthly_calendar.dart';
import 'persona_speech_bubble.dart';
import 'header.dart';
import 'models/persona.dart';
import 'widgets/side_menu.dart';
import 'widgets/floating_input.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [Author] 이준수 (PM & Service Logic)
/// [Description] 앱의 메인 엔트리 포인트 및 전체 내비게이션 상태를 관리합니다.
/// * [Collaborators Note]
/// - 원준: NLP 파싱 로직 및 SmartInputBar 고도화 담당
/// - 광진: 캐릭터(Persona) 애니메이션 및 그래픽 자산 연동 담당

// 화면 전환을 위한 상태 정의
enum AppScreen { dashboard, persona, statistics, settings }

void main() => runApp(
  MaterialApp(
    theme: ThemeData(
      fontFamily: 'Noto Sans KR',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5), // 메인 브랜드 컬러 (민트)
        primary: const Color(0xFF00BFA5),
        secondary: const Color(0xFFE0F2F1),
      ),
    ),
    home: const BuddyMainApp(),
    debugShowCheckedModeBanner: false,
  ),
);

class BuddyMainApp extends StatefulWidget {
  // lint 해결: 명명된 'key' 매개변수를 생성자에 추가
  const BuddyMainApp({super.key});

  @override
  State<BuddyMainApp> createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  // --- [A] 전역 상태 관리 영역 ---

  // 현재 대시보드의 세부 화면 상태 (앱바/입력바 노출 조건에 사용)
  AppScreen _currentScreen = AppScreen.dashboard;

  // 지출 입력 시 카테고리를 선택해야 하는 모드인지 여부
  bool isCategoryMode = false;

  // SmartInputBar에서 파싱되어 넘어온 임시 금액 데이터
  int? tempAmount;

  // 사이드 메뉴(Drawer)의 열림 상태
  bool isMenuOpen = false;

  // 화면 전환을 위한 컨트롤러 (로그인 -> 페르소나 선택 -> 대시보드)
  final PageController _mainController = PageController();
  final PageController _personaController = PageController();

  int _currentPersonaIndex = 0;
  String viewMode = 'calendar'; // 'list' or 'calendar'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        physics: const NeverScrollableScrollPhysics(), // 버튼을 통한 제어만 허용 (기획 의도)
        children: [
          _buildLoginScreen(), // Index 0: 온보딩
          _buildPersonaSelectionContainer(), // Index 1: 캐릭터 선택
          _buildMainDashboard(), // Index 2: 메인 기능 영역
        ],
      ),
    );
  }

  // --- [화면 1] 로그인/온보딩 섹션 ---
  Widget _buildLoginScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBEA), Color(0xFFEBFCF4)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Color(0xFF007955),
            size: 100,
          ),
          const SizedBox(height: 32),
          const Text(
            '당신의 지갑을 위한 가장\n똑똑한 잔소리',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 100),
          _btn(
            text: '구글 로그인',
            color: Colors.white,
            textColor: Colors.black,
            isOutlined: true,
            onTap: () => _mainController.animateToPage(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // --- [화면 2] 페르소나 선택 섹션 ---
  Widget _buildPersonaSelectionContainer() {
    return Stack(
      children: [
        PageView.builder(
          controller: _personaController,
          itemCount: personaData.length,
          onPageChanged: (index) =>
              setState(() => _currentPersonaIndex = index),
          itemBuilder: (context, index) =>
              _buildPersonaContent(personaData[index], index),
        ),
        // [광진] 캐릭터 스와이프 시 시각적 힌트를 위한 화살표 버튼
        if (_currentPersonaIndex > 0)
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black26,
                size: 30,
              ),
              onPressed: () => _personaController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
            ),
          ),
        if (_currentPersonaIndex < personaData.length - 1)
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black26,
                size: 30,
              ),
              onPressed: () => _personaController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPersonaContent(Persona data, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.grad,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 80),
          const Text(
            '버디를 골라보세요',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.type,
              style: TextStyle(color: data.color, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.face_retouching_natural_rounded,
                size: 200,
                color: data.color,
              ),
            ),
          ),
          Text(
            data.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data.sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF495565),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: _btn(
              text: '버디 선택 완료',
              color: data.color,
              textColor: Colors.white,
              onTap: () => _mainController.animateToPage(
                2,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- [화면 3] 메인 대시보드 섹션 ---
  Widget _buildMainDashboard() {
    final selectedPersona = personaData[_currentPersonaIndex];
    final Color personaColor = selectedPersona.color;
    final Color brandColor = const Color(0xFF007955);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // 키보드 노출 시 레이아웃 깨짐 방지 (입력바 내부에 별도 대응)
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // [Layer 1] 스크롤 콘텐츠: 리스트 또는 달력
              Positioned.fill(
                child: _buildMainScrollArea(personaColor, brandColor),
              ),

              // [Layer 2] 암전 효과: 사이드 메뉴 열림 시 활성화
              if (isMenuOpen)
                GestureDetector(
                  onTap: () => setState(() => isMenuOpen = false),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),

              // [Layer 3] 사이드 메뉴 드로어
              _buildSideMenuDrawer(),

              // [Layer 4] 하단 입력바: 자연어 파싱 기능을 탑재한 스마트 컴포넌트
              if (!isMenuOpen && _currentScreen == AppScreen.dashboard)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: FloatingInput(
                      onAmountParsed: (amount) {
                        setState(() {
                          tempAmount = amount;
                          isCategoryMode = true; // [원준] 금액 파싱 성공 시 카테고리 선택으로 유도
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

  // [PM] 대시보드 스크롤 콘텐츠 구성 (헤더 + 리스트/달력)
  Widget _buildMainScrollArea(Color personaColor, Color brandColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120), // 입력바에 가려지지 않도록 여유 공간 확보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainHeader(
            budgetRemaining: 2847500,
            totalBudget: 5000000,
            onMenuPressed: () => setState(() => isMenuOpen = true),
          ),
          const SizedBox(height: 12),

          // [Logic] 카테고리 선택 모드 시 피드 대신 선택창 노출
          if (isCategoryMode)
            _buildCategorySelectionBoard(brandColor)
          else ...[
            FeedHeader(
              viewMode: viewMode,
              onViewModeChange: (mode) => setState(() => viewMode = mode),
            ),
            const SizedBox(height: 12),
            viewMode == 'calendar'
                ? const MonthlyCalendar()
                : _buildTransactionList(personaColor),
          ],
        ],
      ),
    );
  }

  // [Animation] 우측 슬라이드 방식의 커스텀 사이드 메뉴
  Widget _buildSideMenuDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      right: isMenuOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: Container(
        width: 250,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: SideMenu(
          isOpen: isMenuOpen,
          onClose: () => setState(() => isMenuOpen = false),
          onMenuSelected: (index) {
            setState(() {
              if (index == 1) _currentScreen = AppScreen.persona;
              if (index == 2) _currentScreen = AppScreen.statistics;
              isMenuOpen = false;
            });
          },
        ),
      ),
    );
  }

  // [Mock Data] 지출 내역 및 캐릭터 메시지 구성
  Widget _buildTransactionList(Color personaColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 12),
          const FeedCard(
            icon: "🚗",
            title: "카카오택시",
            amount: -18750,
            category: "교통",
          ),
          const SizedBox(height: 12),
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

  // [UI] 파싱된 금액 확인 후 카테고리를 선택하는 그리드 보드
  Widget _buildCategorySelectionBoard(Color brandColor) {
    final List<Map<String, dynamic>> categories = [
      {'name': '식비', 'icon': Icons.restaurant},
      {'name': '카페', 'icon': Icons.local_cafe},
      {'name': '교통', 'icon': Icons.directions_bus},
      {'name': '쇼핑', 'icon': Icons.shopping_bag},
      {'name': '편의점', 'icon': Icons.store},
      {'name': '의료', 'icon': Icons.medical_services},
      {'name': '여가', 'icon': Icons.sports_esports},
      {'name': '기타', 'icon': Icons.more_horiz},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '${tempAmount ?? 0}원',
                  style: TextStyle(color: brandColor),
                ),
                const TextSpan(text: ' 지출 카테고리를 선택하세요'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () => setState(() => isCategoryMode = false),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat['icon'], color: brandColor, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => setState(() => isCategoryMode = false),
            child: Text(
              "입력 취소",
              style: TextStyle(color: brandColor.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  // [Design System] 앱 공용 버튼 스타일 (Material 디자인 준수)
  Widget _btn({
    required String text,
    required Color color,
    required Color textColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: isOutlined
                ? Border.all(color: const Color(0xFFD6D3D0))
                : null,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
