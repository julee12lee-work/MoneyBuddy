import 'package:flutter/material.dart';
import 'floating_input.dart';
import 'feed_header.dart';
import 'feed_card.dart';
import 'monthly_calendar.dart';
import 'persona_speech_bubble.dart';
import 'header.dart'; // 예산 게이지가 포함된 메인 헤더

void main() => runApp(
  MaterialApp(
    theme: ThemeData(
      fontFamily: 'Noto Sans KR',
      useMaterial3: true,
      // --- [브랜드 컬러] ---
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5), // 기준이 되는 색상
        primary: const Color(0xFF00BFA5),
        secondary: const Color(0xFFE0F2F1), // 앱의 메인 브랜드 컬러
      ),
    ),
    home: BuddyMainApp(),
    debugShowCheckedModeBanner: false,
  ),
);

/// [BuddyMainApp] 앱의 전체 상태와 메인 내비게이션을 관리하는 최상위 위젯입니다.
class BuddyMainApp extends StatefulWidget {
  @override
  _BuddyMainAppState createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  // --- [상태 관리 및 컨트롤러] ---

  /// 화면 전체 페이지 전환을 관리 (0:로그인, 1:버디선택, 2:대시보드)
  final PageController _mainController = PageController();

  /// 버디(페르소나) 선택 화면의 가로 스와이프 관리
  final PageController _personaController = PageController();

  int _currentPersonaIndex = 0; // 현재 선택 중인 버디 인덱스
  String viewMode = 'calendar'; // 대시보드 보기 모드 ('list' 또는 'calendar')

  /// [버디 데이터셋] PM 기획안에 따른 F/S/T 타입별 정의
  /// - F(Feeling): 공감형, 가을 딥(#D4734B) 컬러 활용
  /// - S(Sensible): 밸런스형, 초록색 계열
  /// - T(Thinking): 데이터형, 남색 계열
  final List<Map<String, dynamic>> personaData = [
    {
      'type': 'F-type',
      'title': '따뜻한 위로가 필요할 때!',
      'sub': '따뜻한 격려와 공감으로 지치지 않고\n즐겁게 아끼는 습관을 만들어 드릴게요.',
      'color': Color(0xFFD4734B),
      'grad': [Color(0xFFFFFBEA), Color(0xFFFEF0F1)],
      'image': 'assets/images/character_f.png',
    },
    {
      'type': 'S-type',
      'title': '센스있는 밸런스가 필요할 때!',
      'sub': '상황에 맞는 유연한 조언으로 공감과 절약,\n두 마리 토끼를 다 잡는 소비를 이끌어낼게요.',
      'color': Color(0xFF6EA12A),
      'grad': [Color(0xFFF5FFEA), Color(0xFFCCFFCE)],
      'image': 'assets/images/character_s.png',
    },
    {
      'type': 'T-type',
      'title': '뼈 때리는 팩트가 필요할 때!',
      'sub': '냉철한 데이터 분석과 팩트로 낭비 없는\n확실한 저축 목표를 달성하게 도와드려요.',
      'color': Color(0xFF47758B),
      'grad': [Color(0xFFF8FDFF), Color(0xFFDFDFFF)],
      'image': 'assets/images/character_t.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        // 유저가 임의로 스와이프하여 화면을 넘기지 못하도록 제한 (버튼 클릭으로만 이동)
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildLoginScreen(), // Index 0: 온보딩 및 로그인
          _buildPersonaSelectionContainer(), // Index 1: 페르소나 선택
          _buildMainDashboard(), // Index 2: 메인 대시보드 (핵심 기능)
        ],
      ),
    );
  }

  // --- [화면 1] 로그인 화면 빌더 ---
  Widget _buildLoginScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBEA), Color(0xFFEBFCF4)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Color(0xFF007955),
            size: 100,
          ),
          SizedBox(height: 32),
          Text(
            '당신의 지갑을 위한 가장\n똑똑한 잔소리',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 100),
          _btn(
            text: '구글 로그인',
            color: Colors.white,
            textColor: Colors.black,
            isOutlined: true,
            onTap: () => _mainController.animateToPage(
              1,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // --- [화면 2] 페르소나 선택 화면 빌더 ---
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
        // 좌/우 내비게이션 화살표 (유저 가이드용)
        if (_currentPersonaIndex > 0)
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black26,
                size: 30,
              ),
              onPressed: () => _personaController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
            ),
          ),
        if (_currentPersonaIndex < personaData.length - 1)
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black26,
                size: 30,
              ),
              onPressed: () => _personaController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
            ),
          ),
      ],
    );
  }

  /// 개별 페르소나 카드 내용 구성
  Widget _buildPersonaContent(Map<String, dynamic> data, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data['grad'],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 80),
          Text(
            '버디를 골라보세요',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 30),
          // 버디 타입 뱃지
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['type'],
              style: TextStyle(
                color: data['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.face_retouching_natural_rounded,
                size: 200,
                color: data['color'],
              ),
            ),
          ),
          Text(
            data['title'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data['sub'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF495565),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 30),
          // 페이지 인디케이터 (Dot)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => GestureDetector(
                onTap: () => _personaController.animateToPage(
                  i,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: (_currentPersonaIndex == i) ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (_currentPersonaIndex == i)
                        ? data['color']
                        : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: _btn(
              text: '버디 선택 완료',
              color: data['color'],
              textColor: Colors.white,
              onTap: () {
                // 선택 완료 시 메인 대시보드로 이동 (Index 2)
                _mainController.animateToPage(
                  2,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.fastOutSlowIn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- [화면 3] 메인 대시보드 빌더 ---
  /// 머니버디의 실질적인 가계부 및 분석 대시보드입니다.
  /// 레이아웃 전략: Stack을 사용하여 하단 입력창을 항상 최상단에 고정합니다.
  Widget _buildMainDashboard() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // 1. 현재 선택된 페르소나 데이터와 색상 가져오기
    final selectedPersona = personaData[_currentPersonaIndex];
    final Color personaColor = selectedPersona['color'];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 180 + bottomPadding),
                  child: Column(
                    children: [
                      const MainHeader(
                        budgetRemaining: 2847500,
                        totalBudget: 5000000,
                      ),
                      const SizedBox(height: 12),
                      FeedHeader(
                        viewMode: viewMode,
                        onViewModeChange: (mode) =>
                            setState(() => viewMode = mode),
                      ),
                      if (viewMode == 'calendar')
                        const MonthlyCalendar() // 달력은 내부에서 Theme(브랜드컬러) 사용
                      else
                        // 2. 리스트 빌더에 페르소나 컬러 전달
                        _buildTransactionList(personaColor),
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FloatingInput(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [지출 내역 리스트]
  /// 피드 카드와 페르소나 말풍선이 교차로 나타나는 머니버디만의 UI 특징을 보여줍니다.
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
          // 페르소나 말풍선에 캐릭터 컬러 적용
          PersonaSpeechBubble(
            previewMessage: "오늘도 스타벅스네요!",
            fullMessage: "카페 지출이 늘고 있어요. 내일은 집 커피 어떠세요?",
            type: "positive",
            relatedTo: "스타벅스",
            amount: 5500,
            color: personaColor, // 여기서 캐릭터 컬러가 쓰입니다.
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
            fullMessage: "우와, 이번 지출은 조금 컸네요! 준수님이 속상하지 않게 내일은 조금만 아껴볼까요?",
            type: "warning",
            relatedTo: "백화점 쇼핑",
            amount: 287000,
            color: personaColor, // 여기서 캐릭터 컬러가 쓰입니다.
          ),
        ],
      ),
    );
  }

  /// [공용 버튼 위젯]
  /// 디자인 시스템을 준수하며 InkWell을 통해 햅틱 반응(Ripple Effect)을 제공합니다.
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
            border: isOutlined ? Border.all(color: Color(0xFFD6D3D0)) : null,
            boxShadow: [
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
