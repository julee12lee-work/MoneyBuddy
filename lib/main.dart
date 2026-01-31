import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/persona_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

enum AppScreen { dashboard, persona, statistics, settings }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BuddyApp());
}

class BuddyApp extends StatelessWidget {
  const BuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Noto Sans KR',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA5),
          primary: const Color(0xFF00BFA5),
          secondary: const Color(0xFFE0F2F1),
        ),
      ),
      home: const BuddyMainApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BuddyMainApp extends StatefulWidget {
  const BuddyMainApp({super.key});

  @override
  State<BuddyMainApp> createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  final PageController _mainController = PageController();

  int _currentPersonaIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LoginScreen(
            onLoginSuccess: () {
              _mainController.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          ),
          PersonaSelectionScreen(
            onPersonaSelected: (index) {
              setState(() => _currentPersonaIndex = index);
              _mainController.animateToPage(
                2,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
              );
            },
            onPersonaChanged: (index) {
              setState(() => _currentPersonaIndex = index);
            },
          ),
          DashboardScreen(
            selectedPersonaIndex: _currentPersonaIndex,
          ),
        ],
      ),
    );
  }
}
