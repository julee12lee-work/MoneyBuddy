import 'package:flutter/material.dart';

  /// [버디 데이터셋] PM 기획안에 따른 F/S/T 타입별 정의
  /// - F(Feeling): 공감형, 가을 딥(#D4734B) 컬러 활용
  /// - S(Sensible): 밸런스형, 초록색 계열
  /// - T(Thinking): 데이터형, 남색 계열
   
  class Persona {
  final String type;
  final String title;
  final String sub;
  final Color color;
  final List<Color> grad;
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

  final List<Persona> personaData = [
  Persona(
    type: 'F-type',
    title: '따뜻한 위로가 필요할 때!',
    sub: '따뜻한 격려와 공감으로 지치지 않고\n즐겁게 아끼는 습관을 만들어 드릴게요.',
    color: const Color(0xFFD4734B),
    grad: [const Color(0xFFFFFBEA), const Color(0xFFFEF0F1)],
    image: 'assets/images/character_f.png',
  ),
  Persona(
    type: 'S-type',
    title: '센스있는 밸런스가 필요할 때!',
    sub: '상황에 맞는 유연한 조언으로 공감과 절약,\n두 마리 토끼를 다 잡는 소비를 이끌어낼게요.',
    color: const Color(0xFF6EA12A),
    grad: [const Color(0xFFF5FFEA), const Color(0xFFCCFFCE)],
    image: 'assets/images/character_s.png',
  ),
  Persona(
    type: 'T-type',
    title: '뼈 때리는 팩트가 필요할 때!',
    sub: '냉철한 데이터 분석과 팩트로 낭비 없는\n확실한 저축 목표를 달성하게 도와드려요.',
    color: const Color(0xFF47758B),
    grad: [const Color(0xFFF8FDFF), const Color(0xFFDFDFFF)],
    image: 'assets/images/character_t.png',
  ),
  ];
