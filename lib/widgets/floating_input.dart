import 'package:flutter/material.dart';
import 'dart:ui';

import '../constants/app_strings.dart';
import '../models/expense_draft.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class FloatingInput extends StatefulWidget {
  final void Function(int amount) onAmountParsed;

  /// (추가) 원문/제목까지 필요할 때 사용
  final void Function(ExpenseDraft draft)? onDraftParsed;

  const FloatingInput({
    super.key,
    required this.onAmountParsed,
    this.onDraftParsed,
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
    {"label": "🥤 음료", "amount": 1500},
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
    final digits = RegExp(r'\d+')
        .allMatches(text.replaceAll(',', ''))
        .map((m) => m.group(0)!)
        .join();

    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  String? _extractTitle(String input) {
    // 숫자 제거 + "원" 제거 + 구분자 제거 후 trim
    String t = input.replaceAll(RegExp(r'(\d[\d,]*)'), ' ');
    t = t.replaceAll(RegExp(r'(원|won)', caseSensitive: false), ' ');
    t = t.replaceAll(RegExp(r'[-–—:|]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (t.isEmpty) return null;
    return t;
  }

  void _handleSend() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final amount = _extractAmount(raw);
    if (amount == null) return;

    final title = _extractTitle(raw);

    // ✅ 기존 방식 유지
    widget.onAmountParsed.call(amount);

    // ✅ (선택) draft도 전달
    widget.onDraftParsed?.call(
      ExpenseDraft(
        rawText: raw,
        amountAbs: amount,
        title: title,
      ),
    );

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSuggestionChips(),
        _buildInputField(context),
      ],
    );
  }

  Widget _buildSuggestionChips() {
    return Container(
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
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
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
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: AppStrings.dashboardInputPlaceholder,
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(
                Icons.send_rounded,
                color: Color(0xFF00BFA5),
              ),
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
  bool shouldRepaint(covariant RainbowBorderPainter oldDelegate) => true;
}
