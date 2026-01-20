import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] PersonaSelectionScreen
/// [Description] 
/// 제목의 중앙 정렬을 보장하고, 탐색 화살표를 캐릭터 아이콘 높이에 배치했습니다.
class PersonaSelectionScreen extends StatefulWidget {
  final Function(int) onPersonaSelected;
  final Function(int) onPersonaChanged;

  const PersonaSelectionScreen({
    super.key,
    required this.onPersonaSelected,
    required this.onPersonaChanged,
  });

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
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Stack(
            children: [
              // [Layer 1] 페르소나 슬라이더
              PageView.builder(
                controller: _personaController,
                itemCount: personaData.length,
                onPageChanged: (index) {
                  setState(() => _currentPersonaIndex = index);
                  widget.onPersonaChanged(index);
                },
                itemBuilder: (context, index) => _buildPersonaContent(personaData[index], index),
              ),
              
              // [Layer 2] 탐색 화살표: 아이콘 높이(상단 40%)에 배치
              // [PM Note] 아이콘 크기(240)와 여백을 고려하여 위치를 고정했습니다.
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
          // [Fix] 모든 자식 위젯을 가로축 중앙에 배치하도록 강제
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60), 
            
            // [Fix] 제목 중앙 정렬 보장
            const SizedBox(
              width: double.infinity,
              child: Text(
                AppStrings.personaSelectTitle, 
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
            ),
            
            const Spacer(flex: 2), 

            // 캐릭터 아이콘 그룹 (태그 + 이미지 + 인디케이터)
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

            // 설명 섹션
            Text(data.title, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXLarge),
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
      onTap: () => widget.onPersonaSelected(_currentPersonaIndex),
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
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// [Fix] 화살표 위치를 캐릭터 아이콘 높이로 고정
  Widget _buildNavigationArrows() {
    return Positioned(
      // [광진 TODO] 기기별 높이 대응을 위해 MediaQuery를 활용한 비율 배치입니다.
      top: MediaQuery.of(context).size.height * 0.4, 
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentPersonaIndex > 0
                ? _arrowButton(Icons.arrow_back_ios_new_rounded, () => _personaController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease))
                : const SizedBox(width: 48),
            _currentPersonaIndex < personaData.length - 1
                ? _arrowButton(Icons.arrow_forward_ios_rounded, () => _personaController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease))
                : const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.black12.withValues(alpha: 0.1), size: 36),
      onPressed: onTap,
    );
  }
}