import 'package:flutter/material.dart';
import 'feed_header.dart';
import 'feed_card.dart';
import 'monthly_calendar.dart';
import 'persona_speech_bubble.dart';
import 'header.dart'; 
import 'models/persona.dart';
import 'widgets/side_menu.dart';
import 'widgets/floating_input.dart';

// 현재 보여줄 화면을 정의하는 enum
enum AppScreen { dashboard, persona, statistics, settings }

void main() => runApp(
  MaterialApp(
    theme: ThemeData(
      fontFamily: 'Noto Sans KR',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        primary: const Color(0xFF00BFA5),
        secondary: const Color(0xFFE0F2F1),
      ),
    ),
    home: BuddyMainApp(),
    debugShowCheckedModeBanner: false,
  ),
);

class BuddyMainApp extends StatefulWidget {
  @override
  _BuddyMainAppState createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  // --- [상태 관리 변수: 반드시 클래스 내부에 위치해야 함] ---
  AppScreen _currentScreen = AppScreen.dashboard; 
  bool isCategoryMode = false;
  int? tempAmount;
  bool isMenuOpen = false;

  final PageController _mainController = PageController();
  final PageController _personaController = PageController();

  int _currentPersonaIndex = 0;
  String viewMode = 'calendar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildLoginScreen(),
          _buildPersonaSelectionContainer(),
          _buildMainDashboard(), // Index 2
        ],
      ),
    );
  }

  // --- [화면 1] 로그인 화면 ---
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
          const Icon(Icons.account_balance_wallet, color: Color(0xFF007955), size: 100),
          const SizedBox(height: 32),
          const Text('당신의 지갑을 위한 가장\n똑똑한 잔소리', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 100),
          _btn(
            text: '구글 로그인',
            color: Colors.white,
            textColor: Colors.black,
            isOutlined: true,
            onTap: () => _mainController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  // --- [화면 2] 페르소나 선택 화면 ---
  Widget _buildPersonaSelectionContainer() {
    return Stack(
      children: [
        PageView.builder(
          controller: _personaController,
          itemCount: personaData.length,
          onPageChanged: (index) => setState(() => _currentPersonaIndex = index),
          itemBuilder: (context, index) => _buildPersonaContent(personaData[index], index),
        ),
        if (_currentPersonaIndex > 0)
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black26, size: 30),
              onPressed: () => _personaController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
            ),
          ),
        if (_currentPersonaIndex < personaData.length - 1)
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 30),
              onPressed: () => _personaController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
            ),
          ),
      ],
    );
  }

  Widget _buildPersonaContent(Persona data, int index) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: data.grad)),
      child: Column(
        children: [
          const SizedBox(height: 80),
          const Text('버디를 골라보세요', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: data.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(data.type, style: TextStyle(color: data.color, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Center(child: Icon(Icons.face_retouching_natural_rounded, size: 200, color: data.color))),
          Text(data.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(data.sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF495565), height: 1.5)),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: _btn(
              text: '버디 선택 완료',
              color: data.color,
              textColor: Colors.white,
              onTap: () => _mainController.animateToPage(2, duration: const Duration(milliseconds: 600), curve: Curves.fastOutSlowIn),
            ),
          ),
        ],
      ),
    );
  }

 // --- [화면 3] 메인 대시보드 ---
Widget _buildMainDashboard() {
  print("isMenuOpen=$isMenuOpen, currentScreen=$_currentScreen");

  final selectedPersona = personaData[_currentPersonaIndex];
  final Color personaColor = selectedPersona.color;
  final Color brandColor = const Color(0xFF007955);

  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: false, // 입력바에서 직접 처리
    body: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        // height: double.infinity, // 불필요(부모 제약으로 충분). 남겨도 되지만 제거 권장
        // clipBehavior: Clip.hardEdge, // ✅ 제거: 하단 입력바/그림자 잘림 방지
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // [A] 메인 콘텐츠 레이어
            Positioned.fill(
              child: _buildMainScrollArea(personaColor, brandColor),
            ),

            // [B] 메뉴 배경 암전 (Scrim)
            if (isMenuOpen)
              GestureDetector(
                onTap: () => setState(() => isMenuOpen = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),

            // [C] 사이드 메뉴 (Drawer)
            _buildSideMenuDrawer(),

            // [D] 하단 입력바 (SmartInputBar)
            if (!isMenuOpen && _currentScreen == AppScreen.dashboard)
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
                    }
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildMainScrollArea(Color personaColor, Color brandColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120), // 하단 입력바 공간 확보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainHeader(
            budgetRemaining: 2847500,
            totalBudget: 5000000,
            onMenuPressed: () => setState(() => isMenuOpen = true),
          ),
          const SizedBox(height: 12),
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

  Widget _buildSideMenuDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      right: isMenuOpen ? 0 : -260,
      top: 0, bottom: 0,
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

  Widget _buildTransactionList(Color personaColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const FeedCard(icon: "☕", title: "스타벅스", amount: -5500, category: "카페"),
          PersonaSpeechBubble(
            previewMessage: "오늘도 스타벅스네요!",
            fullMessage: "카페 지출이 늘고 있어요. 내일은 집 커피 어떠세요?",
            type: "positive",
            relatedTo: "스타벅스",
            amount: 5500,
            color: personaColor,
          ),
          const SizedBox(height: 12),
          const FeedCard(icon: "🚗", title: "카카오택시", amount: -18750, category: "교통"),
          const SizedBox(height: 12),
          const FeedCard(icon: "🛍️", title: "백화점 쇼핑", amount: -287000, category: "쇼핑"),
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
              style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: '${tempAmount ?? 0}원', style: TextStyle(color: brandColor)),
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
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: brandColor.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(cat['icon'], color: brandColor, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(cat['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => setState(() => isCategoryMode = false),
            child: Text("입력 취소", style: TextStyle(color: brandColor.withOpacity(0.6))),
          ),
        ],
      ),
    );
  }

  Widget _btn({required String text, required Color color, required Color textColor, bool isOutlined = false, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 300, height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: isOutlined ? Border.all(color: const Color(0xFFD6D3D0)) : null,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Center(child: Text(text, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}