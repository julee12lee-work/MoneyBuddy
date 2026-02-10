import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] PersonaSelectionScreen - 페르소나 선택 화면
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description]
/// 로그인 후 F/S/T 페르소나를 선택하는 화면
/// AuthProvider로 Firestore에 페르소나 저장 후 go_router로 대시보드 이동
///
/// * [Collaborators Note]
/// - 광진: AuthProvider.updatePersonaType()이 Firestore users/{uid} 문서 업데이트
/// - 원준: personaType 값으로 AI 피드백 톤/스타일 분기
/// - 준수: PageView + 인디케이터 + 화살표 네비게이션 UI

class PersonaSelectionScreen extends StatefulWidget {
  const PersonaSelectionScreen({super.key});

  @override
  State<PersonaSelectionScreen> createState() => _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState extends State<PersonaSelectionScreen> {
  final PageController _personaController = PageController();
  int _currentPersonaIndex = 0;

  @override
  void dispose() {
    _personaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _personaController,
                itemCount: personaData.length,
                onPageChanged: (index) {
                  setState(() => _currentPersonaIndex = index);
                },
                itemBuilder: (context, index) =>
                    _buildPersonaContent(personaData[index], index),
              ),
              _buildNavigationArrows(),
            ],
          ),
        ),
      ),
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const SizedBox(
              width: double.infinity,
              child: Text(
                AppStrings.personaSelectTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
            ),
            const Spacer(flex: 2),
            _buildTypeTag(data),
            const SizedBox(height: AppDimensions.cardSpacing),
            Image.asset(
              data.image,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.face_retouching_natural_rounded,
                size: 180,
                color: data.color,
              ),
            ),
            const SizedBox(height: AppDimensions.cardSpacing),
            _buildPageIndicator(),
            const Spacer(flex: 2),
            Text(data.title, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXLarge),
              child: Text(
                data.sub,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _buildSelectButton(data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTag(Persona data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Text(
        data.type,
        style: AppTextStyles.captionBold.copyWith(color: data.color),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(personaData.length, (index) {
        bool isActive = _currentPersonaIndex == index;
        return GestureDetector(
          onTap: () {
            _personaController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? personaData[index].color : AppColors.divider,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectButton(Persona data) {
    return InkWell(
      onTap: () async {
        // [광진] Provider를 통해 Firestore에 페르소나 저장
        final authProvider = context.read<AuthProvider>();
        await authProvider.updatePersonaType(data.type);

        // go_router로 대시보드 이동
        if (mounted) context.go('/dashboard');
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: data.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Center(
          child: Text(
            AppStrings.personaSelectButton,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentPersonaIndex > 0
                ? _arrowButton(Icons.arrow_back_ios_new_rounded, () {
                    _personaController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  })
                : const SizedBox(width: 48),
            _currentPersonaIndex < personaData.length - 1
                ? _arrowButton(Icons.arrow_forward_ios_rounded, () {
                    _personaController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  })
                : const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon,
          color: Colors.black12.withValues(alpha: 0.1), size: 36),
      onPressed: onTap,
    );
  }
}
