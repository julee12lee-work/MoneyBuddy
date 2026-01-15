import 'package:flutter/material.dart';
import 'dart:ui';

/// [MyCustomScrollBehavior]
/// 웹이나 데스크톱 환경에서도 마우스 드래그로 칩을 넘길 수 있도록 설정하는 클래스입니다.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

/// [FloatingInput]
/// 화면 하단에 고정되어 지출 입력을 담당하는 위젯입니다.
///
/// 기능:
/// 1. AI 추천 지출 칩 (무지개 테두리 애니메이션 적용)
/// 2. 지출 내용 입력창 (iPhone 하단 Safe Area 대응)
/// 3. 추천 칩 클릭 시 입력창에 텍스트 자동 삽입
class FloatingInput extends StatefulWidget {
  const FloatingInput({super.key});

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;

  /// AI 추천 지출 데이터셋
  final List<Map<String, dynamic>> suggestions = [
    {"label": "☕️ 커피", "amount": 5500},
    {"label": "🍽️ 식사", "amount": 12800},
    {"label": "🚗 택시", "amount": 18700},
    {"label": "🛍️ 쇼핑", "amount": 287000},
    {"label": "🥤 음료", "size": 1500},
    {"label": "🎁 선물", "amount": 45000},
  ];

  @override
  void initState() {
    super.initState();

    /// 무지개 테두리 회전을 위한 애니메이션 컨트롤러 (4초 주기로 무한 반복)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// [금액 포맷팅] 숫자를 '1,000원' 형식의 문자열로 변환합니다.
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 하단 고정을 위해 최소 크기로 설정
      children: [
        // 1. AI 추천 칩 영역 (Horizontal List)
        Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(), // iOS 특유의 탄성 효과
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildChip(index),
            ),
          ),
        ),

        // 2. 입력창 본체 영역
        _buildInputField(context),
      ],
    );
  }

  /// [Chip 위젯 생성]
  /// 무지개 테두리 애니메이션과 블러(Blur) 효과가 적용된 추천 버튼입니다.
  Widget _buildChip(int index) {
    final String label = suggestions[index]['label'];
    final int amount = suggestions[index]['amount'] ?? 0;
    final String formattedText = "$label ${_formatCurrency(amount)}원";

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.text = formattedText; // 클릭 시 입력창으로 텍스트 전달
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          // 배경을 투명하게 비추는 유리 질감 효과 (Glassmorphism)
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomPaint(
            painter: RainbowBorderPainter(_animController), // 무지개 테두리 페인터
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                formattedText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569), // Slate-700
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// [입력창 위젯 생성]
  /// iPhone 16 Pro 등 하단 곡률 영역(Safe Area)을 자동으로 계산하여 패딩을 적용합니다.
  Widget _buildInputField(BuildContext context) {
    return Container(
      // MediaQuery를 사용하여 하단 물리적 여백(바)만큼 패딩 추가
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // 배경 리스트가 살짝 비치는 효과
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5), // 위쪽으로 퍼지는 그림자
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Slate-50 배경
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "지출을 추가하려면 가격을 입력하세요.",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            // [브랜드 컬러] 민트색 전송 버튼
            IconButton(
              onPressed: () => print("전송: ${_controller.text}"),
              icon: const Icon(Icons.send_rounded, color: Color(0xFF00BFA5)),
            ),
          ],
        ),
      ),
    );
  }
}

/// [RainbowBorderPainter]
/// 칩의 테두리를 무지개색 그라데이션으로 그리고 회전시키는 로직입니다.
class RainbowBorderPainter extends CustomPainter {
  final Animation<double> animation;

  RainbowBorderPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 무지개 색상 배열 (부드러운 루프를 위해 시작색과 끝색을 맞춤)
    final paint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF667EEA), // Blue
          Color(0xFF764BA2), // Purple
          Color(0xFFF093FB), // Pink
          Color(0xFF4FACFE), // Sky
          Color(0xFF667EEA), // Blue
        ],
        // 애니메이션 값(0.0 ~ 1.0)에 2*PI를 곱해 360도 회전 효과 구현
        transform: GradientRotation(animation.value * 6.283185),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // 둥근 캡슐 모양의 테두리 그리기
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(100)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RainbowBorderPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
