import 'package:flutter/material.dart';
import 'dart:ui';


/// * [Project] Buddy - AI 가계부
/// * [Module] FloatingInput (스마트 지출 입력 컴포넌트)
/// * [Author] 이준수
/// * [Description] 사용자의 자연어 입력에서 금액을 추출하거나, 
/// * AI 추천 칩을 통해 빠른 입력을 지원하는 하단 고정 위젯입니다.

/// [MyCustomScrollBehavior]
/// 웹/데스크톱 환경에서도 마우스 드래그를 통해 추천 칩 리스트를 스크롤할 수 있도록 설정합니다.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class FloatingInput extends StatefulWidget {
  /// 금액 파싱 완료 후 부모 위젯(Dashboard)에 데이터 전송을 위한 콜백
  final void Function(int amount) onAmountParsed;

  const FloatingInput({super.key, required this.onAmountParsed});

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;

  /// AI 추천 지출 데이터셋 (Mock Data)
  /// 기획 의도: 최근 소비 패턴을 분석하여 빈도가 높은 지출을 우선 순위로 노출
  final List<Map<String, dynamic>> suggestions = [
    {"label": "☕️ 커피", "amount": 5500},
    {"label": "🍽️ 식사", "amount": 12800},
    {"label": "🚗 택시", "amount": 18700},
    {"label": "🛍️ 쇼핑", "amount": 287000},
    {"label": "🥤 음료", "amount": 1500},
    {"label": "🎁 선물", "amount": 45000},
  ];

  @override
  void initState() {
    super.initState();
    // 무지개 테두리 회전 애니메이션 (4초 주기)
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

  /// [Utility] 숫자를 천 단위 콤마(,)가 포함된 통화 형식으로 변환
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// [Core Logic] 사용자의 입력 텍스트에서 숫자만 추출하는 정규표현식 로직
  /// "커피 3000원", "3,000" 등 다양한 입력 형태에서 int 값만 정제함
  int? _extractAmount(String text) {
    final digits = RegExp(
      r'\d+',
    ).allMatches(text.replaceAll(',', '')).map((m) => m.group(0)!).join();
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// 지출 데이터 확정 및 전송 로직
  void _handleSend() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final amount = _extractAmount(raw);
    if (amount == null) return;

    // 부모 위젯(BuddyMainApp)에 금액 전달 -> 카테고리 선택 모드 트리거
    widget.onAmountParsed.call(amount);

    // 입력 필드 초기화 및 키보드 해제
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상단: AI 추천 지출 칩 리스트
        Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildChip(index),
            ),
          ),
        ),
        // 하단: 텍스트 입력창
        _buildInputField(context),
      ],
    );
  }

  /// [UI] 개별 추천 칩 위젯
  /// 디자인 포인트: Glassmorphism(블러) + Rainbow Animation Border
  Widget _buildChip(int index) {
    final String label = suggestions[index]['label'];
    final int amount = suggestions[index]['amount'] ?? 0;
    final String formattedText = "$label ${_formatCurrency(amount)}원";

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.text = formattedText;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomPaint(
            painter: RainbowBorderPainter(_animController),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                formattedText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// [UI] 텍스트 입력 필드
  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom, // iPhone Safe Area 대응
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                onSubmitted: (_) => _handleSend(), // 키보드 '완료/전송' 버튼 대응
                decoration: const InputDecoration(
                  hintText: "지출을 추가하려면 가격을 입력하세요.",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(Icons.send_rounded, color: Color(0xFF00BFA5)),
            ),
          ],
        ),
      ),
    );
  }
}

/// [Painter] 무지개 테두리 애니메이션 효과를 그리는 커스텀 페인터
class RainbowBorderPainter extends CustomPainter {
  final Animation<double> animation;
  RainbowBorderPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF667EEA),
          Color(0xFF764BA2),
          Color(0xFFF093FB),
          Color(0xFF4FACFE),
          Color(0xFF667EEA),
        ],
        transform: GradientRotation(animation.value * 6.283185), // 2*PI 회전
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(100)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RainbowBorderPainter oldDelegate) => true;
}
