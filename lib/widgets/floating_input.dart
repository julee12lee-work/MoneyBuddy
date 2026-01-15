import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ✅ PointerDeviceKind
import 'dart:ui';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class FloatingInput extends StatefulWidget {
  final void Function(int amount) onAmountParsed;

  const FloatingInput({
    super.key,
    required this.onAmountParsed,
  });

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}


class _FloatingInputState extends State<FloatingInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;

  final List<Map<String, dynamic>> suggestions = [
    {"label": "☕️ 커피", "amount": 5500},
    {"label": "🍽️ 식사", "amount": 12800},
    {"label": "🚗 택시", "amount": 18700},
    {"label": "🛍️ 쇼핑", "amount": 287000},
    {"label": "🥤 음료", "amount": 1500}, // ✅ size -> amount
    {"label": "🎁 선물", "amount": 45000},
  ];

  @override
  void initState() {
    super.initState();
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  int? _extractAmount(String text) {
    // "3,000원", "커피 3000", "3000" 모두 지원
    final digits = RegExp(r'\d+')
        .allMatches(text.replaceAll(',', ''))
        .map((m) => m.group(0)!)
        .join();
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  void _handleSend() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final amount = _extractAmount(raw);
    if (amount == null) return;

    // ✅ 부모로 알림 (여기서 카테고리 모드 켜짐)
    widget.onAmountParsed?.call(amount);

    // 입력 정리
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildChip(index),
            ),
          ),
        ),
        _buildInputField(context),
      ],
    );
  }

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

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                onSubmitted: (_) => _handleSend(), // ✅ 엔터도 동작
                decoration: const InputDecoration(
                  hintText: "지출을 추가하려면 가격을 입력하세요.",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
           IconButton(
  onPressed: () {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    // 숫자만 뽑기: "3,000원", "커피 3000" 모두 처리
    final digits = RegExp(r'\d+')
        .allMatches(raw.replaceAll(',', ''))
        .map((m) => m.group(0)!)
        .join();

    final amount = int.tryParse(digits);
    if (amount == null) return;

    widget.onAmountParsed(amount); // ✅ 메인으로 전달
    _controller.clear();
    FocusScope.of(context).unfocus();
  },
  icon: const Icon(Icons.send_rounded, color: Color(0xFF00BFA5)),
),

          ],
        ),
      ),
    );
  }
}

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
        transform: GradientRotation(animation.value * 6.283185),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

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
