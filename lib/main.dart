import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'screens/persona_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [Author] 이준수 (PM & Service Logic)
/// [Description] 앱의 메인 엔트리 포인트 및 전체 내비게이션 상태를 관리합니다.
/// * [Collaborators Note]
/// - 원준: NLP 파싱 로직 및 SmartInputBar 고도화 담당
/// - 광진: 캐릭터(Persona) 애니메이션 및 그래픽 자산 연동 담당

// 화면 전환을 위한 상태 정의
enum AppScreen { dashboard, persona, statistics, settings }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase 초기화 (flutterfire configure로 생성된 옵션 사용)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
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
}

class BuddyMainApp extends StatefulWidget {
  // lint 해결: 명명된 'key' 매개변수를 생성자에 추가
  const BuddyMainApp({super.key});

  @override
  State<BuddyMainApp> createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  // --- [A] 전역 상태 관리 영역 ---

  // 지출 입력 시 카테고리를 선택해야 하는 모드인지 여부
  bool isCategoryMode = false;

  // SmartInputBar에서 파싱되어 넘어온 임시 금액 데이터
  int? tempAmount;

  // 사이드 메뉴(Drawer)의 열림 상태
  bool isMenuOpen = false;

  // 화면 전환을 위한 컨트롤러 (로그인 -> 페르소나 선택 -> 대시보드)
  final PageController _mainController = PageController();

  //캐릭터 선택 화면에서 선택된 인덱스
  // [Usage] 메인 대시보드에서 선택된 캐릭터의 색상, 메시지 스타일 등에 사용
  int _currentPersonaIndex = 0;
  String viewMode = 'calendar'; // 'list' or 'calendar'

  @override
  void initState() {
    super.initState();

    // ✅ 이미 로그인되어 있으면 로그인 화면 스킵
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _mainController.jumpToPage(1);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        physics: const NeverScrollableScrollPhysics(), // 버튼을 통한 제어만 허용 (기획 의도)
        children: [
          // [화면 0] 로그인/온보딩
          LoginScreen(
            onLoginSuccess: () {
              _mainController.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          ),

          // [화면 1] 캐릭터 선택
          // * [리팩토링] 기존 _buildPersonaSelectionContainer() 메서드를 별도 파일로 분리
          // * [파일 위치] lib/screens/persona_selection_screen.dart
          PersonaSelectionScreen(
            // 1. 선택 완료 시 호출되는 콜백
            // [Fix] 에러 해결: (index) 매개변수를 추가하여 타입을 맞춤
            onPersonaSelected: (index) {
              // [Logic] 선택된 인덱스를 최종 저장하고 대시보드로 이동
              setState(() => _currentPersonaIndex = index);

              _mainController.animateToPage(
                2,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
              );
            },

            // 2. 스와이프 중에 캐릭터가 바뀔 때 호출되는 콜백
            onPersonaChanged: (index) {
              // [Collaborators Note]
              // - 광진: 스와이프할 때마다 배경 그라데이션이 실시간으로 변하도록 처리됨.
              // - 원준: 여기서 선택된 index를 미리 파악해 두면 대시보드 로딩 속도를 높일 수 있습니다.
              setState(() => _currentPersonaIndex = index);
            },
          ),

          // [화면 2] 메인 대시보드
          // * [리팩토링] 기존 _buildMainDashboard() 메서드를 별도 파일로 분리
          // * [파일 위치] lib/screens/dashboard_screen.dart
          DashboardScreen(
            selectedPersonaIndex: _currentPersonaIndex,
          ),
        ],
      ),
    );
  }
}
