import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] Persona Model - 캐릭터 데이터 모델 정의
/// [Author] 이준수 (PM & Service Logic)
/// [Description] 
/// 사용자의 지출 패턴에 따른 맞춤형 피드백을 제공하기 위한 캐릭터 모델
/// F(공감), S(균형), T(이성)의 3가지 페르소나를 정의하여
/// 앱 전반의 테마 컬러와 캐릭터 이미지를 결정하는 기준으로 사용
/// 
/// * [Collaborators Note]
/// - 광진: 각 타입별 캐릭터 이미지 에셋을 assets/images/에 배치 필요
/// - 원준: SmartInputBar 파싱 결과에 따라 Persona.color를 UI에 반영
/// - 준수: 유저 피드백 기반으로 title/sub 문구 지속 최적화 중

// --- [A] 데이터 모델 정의 ---

/// Persona 클래스: 버디(캐릭터)의 모든 속성을 담는 데이터 모델
/// [Usage] personaData[index]로 접근하여 앱 전역에서 캐릭터 정보 사용
class Persona {
  /// 캐릭터 타입 식별자
  /// [Values] "F-type" (공감형), "S-type" (균형형), "T-type" (이성형)
  final String type;
  
  /// 캐릭터 선택 화면에서 표시되는 메인 타이틀
  /// [Design] 사용자의 니즈를 직관적으로 전달하는 문구
  final String title;
  
  /// 캐릭터의 성격과 서비스 가치를 설명하는 서브 텍스트
  /// [UX] 2줄로 구성되며, \n으로 줄바꿈 처리
  final String sub;
  
  /// 캐릭터 고유 테마 컬러
  /// [Usage] 버튼, 말풍선, 강조 텍스트 등에 사용
  /// [Design] 각 타입별로 브랜드 아이덴티티를 구분하는 핵심 요소
  final Color color;
  
  /// 배경 그라데이션 색상 리스트
  /// [Usage] 캐릭터 선택 화면의 배경 그라데이션에 사용
  /// [Design] [상단 색상, 하단 색상] 순서로 정의
  final List<Color> grad;
  
  /// 캐릭터 이미지 경로
  /// [광진 TODO] 현재 임시 아이콘 사용 중, PNG 에셋으로 교체 필요
  /// [Path] assets/images/ 폴더 내에 위치해야 함
  final String image;

  /// Persona 생성자
  /// [Required] 모든 필드가 필수값
  Persona({
    required this.type,
    required this.title,
    required this.sub,
    required this.color,
    required this.grad,
    required this.image,
  });
}

// --- [B] 캐릭터 데이터 정의 ---

/// 앱에서 사용 가능한 전체 캐릭터 목록
/// [Important] 이 리스트의 순서가 캐릭터 선택 화면의 스와이프 순서를 결정함
/// [Usage] PersonaSelectionScreen과 DashboardScreen에서 참조
final List<Persona> personaData = [
  
  // --- [타입 1] F-type: 공감형 캐릭터 ---
  // [Concept] 사용자의 감정에 공감하고 부드럽게 권유하는 스타일
  // [Target User] 따뜻한 위로와 격려를 원하는 사용자
  Persona(
    type: 'F-type',
    title: '따뜻한 위로가 필요할 때!',
    sub: '따뜻한 격려와 공감으로 지치지 않고\n즐겁게 아끼는 습관을 만들어 드릴게요.',
    
    // [Color] 가을 딥(Autumn Deep) 웜톤 컬러 (#D4734B)
    // [Design 의도] 따뜻하고 안정적인 느낌
    color: AppColors.personaF,
    
    // [Gradient] 부드러운 크림색 → 핑크 톤
    grad: [
      const Color(0xFFFFFBEA), // 상단: 아이보리
      const Color(0xFFFEF0F1), // 하단: 라이트 핑크
    ],
    
    image: 'assets/images/character_f.png',
  ),

   // --- [타입 2] T-type: 이성형 캐릭터 ---
  // [Concept] 데이터와 팩트를 기반으로 냉철하게 분석하는 스타일
  // [Target User] 확실한 절약 목표 달성을 원하는 사용자
  Persona(
    type: 'T-type',
    title: '뼈 때리는 팩트가 필요할 때!',
    sub: '냉철한 데이터 분석과 팩트로 낭비 없는\n확실한 저축 목표를 달성하게 도와드려요.',
    
    // [Color] 쿨톤 블루 그레이 (#47758B)
    // [Design 의도] 이성적이고 전문적인 느낌
    color: AppColors.personaT,
    
    // [Gradient] 아이스 블루 → 연보라 톤
    grad: [
      const Color(0xFFF8FDFF), // 상단: 아이스 블루
      const Color(0xFFDFDFFF), // 하단: 연보라
    ],
    
    image: 'assets/images/character_t.png',
  ),

  // --- [타입 3] S-type: 균형형 캐릭터 ---
  // [Concept] 상황에 맞춰 유연하고 합리적인 조언을 제공하는 스타일
  // [Target User] 공감과 절약의 밸런스를 원하는 사용자
  Persona(
    type: 'S-type',
    title: '센스있는 밸런스가 필요할 때!',
    sub: '상황에 맞는 유연한 조언으로 공감과 절약,\n두 마리 토끼를 다 잡는 소비를 이끌어낼게요.',
    
    // [Color] 자연스러운 그린 톤 (#6EA12A)
    // [Design 의도] 균형감과 안정감
    color: AppColors.personaS,
    
    // [Gradient] 민트 → 연두 톤
    grad: [
      const Color(0xFFF5FFEA), // 상단: 라이트 민트
      const Color(0xFFCCFFCE), // 하단: 연두
    ],
    
    image: 'assets/images/character_s.png',
  ),

 
];

// --- [C] 헬퍼 함수 (선택적 추가 가능) ---

/// 캐릭터 타입으로 Persona 객체 찾기
/// [Usage] getPersonaByType('F-type')
/// [Returns] 해당 타입의 Persona 객체 또는 null
Persona? getPersonaByType(String type) {
  try {
    return personaData.firstWhere((persona) => persona.type == type);
  } catch (e) {
    return null;
  }
}

/// 현재 총 캐릭터 개수 반환
/// [Usage] getTotalPersonaCount()
int getTotalPersonaCount() => personaData.length;