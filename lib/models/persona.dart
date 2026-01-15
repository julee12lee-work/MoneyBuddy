import 'package:flutter/material.dart';


 /// * [PM Note: 서비스 기획 의도]
 /// * 사용자의 지출 패턴에 따른 맞춤형 피드백을 제공하기 위해 
 /// * F(공감), S(균형), T(이성)의 3가지 페르소나를 정의함.
 /// * 이 데이터 모델은 앱 전반의 테마 컬러와 캐릭터 이미지를 결정하는 기준이 됨.


/// [Persona] 버디(캐릭터)의 속성을 정의하는 데이터 모델 클래스
class Persona {
  /// 캐릭터 타입 (F-type, S-type, T-type)
  final String type;
  
  /// 선택 화면에서의 강조 타이틀
  final String title;
  
  /// 캐릭터의 성격 및 서비스 가치를 설명하는 서브 텍스트
  final String sub;
  
  /// 캐릭터 고유 테마 컬러 (브랜딩 및 UI 강조색으로 활용)
  final Color color;
  
  /// 배경 및 카드 위젯에 사용될 그라데이션 색상 리스트
  final List<Color> grad;
  
  /// [광진] 캐릭터 PNG 이미지 경로 (assets/images/ 내부에 위치해야 함)
  final String image;

  Persona({
    required this.type,
    required this.title,
    required this.sub,
    required this.color,
    required this.grad,
    required this.image,
  });
}


/// * [Collaborator Guide]
/// * - 준수(PM): 유저 경험 시나리오에 맞춰 title과 sub 문구 최적화 완료.
/// * - 광진(Design): 각 타입별 퍼스널 컬러와 캐릭터 이미지 매칭 확인 필요.
/// * - 원준(Dev): SmartInputBar의 텍스트 파싱 결과에 따라 Persona.color를 참조하여 UI 렌더링.

final List<Persona> personaData = [
  // 1. F-type: 사용자의 감정에 공감하고 부드럽게 권유하는 타입
  Persona(
    type: 'F-type',
    title: '따뜻한 위로가 필요할 때!',
    sub: '따뜻한 격려와 공감으로 지치지 않고\n즐겁게 아끼는 습관을 만들어 드릴게요.',
    // [준수] 가을 딥(Autumn Deep) 웜톤 컬러 반영 (#D4734B)
    color: const Color(0xFFD4734B),
    grad: [const Color(0xFFFFFBEA), const Color(0xFFFEF0F1)],
    image: 'assets/images/character_f.png',
  ),

  // 2. S-type: 상황에 맞춰 유연하고 합리적인 조언을 주는 타입
  Persona(
    type: 'S-type',
    title: '센스있는 밸런스가 필요할 때!',
    sub: '상황에 맞는 유연한 조언으로 공감과 절약,\n두 마리 토끼를 다 잡는 소비를 이끌어낼게요.',
    color: const Color(0xFF6EA12A),
    grad: [const Color(0xFFF5FFEA), const Color(0xFFCCFFCE)],
    image: 'assets/images/character_s.png',
  ),

  // 3. T-type: 데이터와 팩트를 기반으로 냉철하게 분석하는 타입
  Persona(
    type: 'T-type',
    title: '뼈 때리는 팩트가 필요할 때!',
    sub: '냉철한 데이터 분석과 팩트로 낭비 없는\n확실한 저축 목표를 달성하게 도와드려요.',
    color: const Color(0xFF47758B),
    grad: [const Color(0xFFF8FDFF), const Color(0xFFDFDFFF)],
    image: 'assets/images/character_t.png',
  ),
];