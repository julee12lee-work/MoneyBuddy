import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'router.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] main.dart - 앱 진입점
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description]
/// Firebase 초기화 → MultiProvider 등록 → go_router 기반 MaterialApp
///
/// * [Collaborators Note]
/// - 광진: Firebase.initializeApp이 모든 Firebase 서비스의 전제 조건
/// - 원준: AI 서비스 Provider 추가 시 이 파일의 providers 배열에 등록
/// - 준수: ThemeData/fontFamily 등 디자인 시스템 설정

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MoneyBuddyApp());
}

class MoneyBuddyApp extends StatelessWidget {
  const MoneyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // [광진] AuthProvider 상태 변경 시 라우터가 자동 리다이렉트
          final router = AppRouter.router(authProvider);

          return MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(
              fontFamily: 'Noto Sans KR',
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00BFA5),
                primary: const Color(0xFF00BFA5),
                secondary: const Color(0xFFE0F2F1),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
