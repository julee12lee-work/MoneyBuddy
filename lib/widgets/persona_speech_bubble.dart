import 'package:flutter/material.dart';

/// [PersonaSpeechBubble] 페르소나(AI) 분석 피드백 위젯
class PersonaSpeechBubble extends StatefulWidget {
  final String previewMessage;
  final String fullMessage;
  final String type; // 'warning' | 'positive'
  final String relatedTo;
  final int amount;
  final Color color; // 부모 위젯에서 전달받은 페르소나 고유 컬러

  const PersonaSpeechBubble({
    super.key,
    required this.previewMessage,
    required this.fullMessage,
    required this.type,
    required this.relatedTo,
    required this.amount,
    required this.color,
  });

  @override
  State<PersonaSpeechBubble> createState() => _PersonaSpeechBubbleState();
}

class _PersonaSpeechBubbleState extends State<PersonaSpeechBubble> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String emoji = widget.type == 'warning' ? '😔' : '😊';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 상단 카드 연결선 (시스템 회색 유지)
          Positioned(
            top: -12,
            left: 41,
            child: Container(
              width: 2,
              height: 12,
              color: const Color(0xFFCBD5E1),
            ),
          ),

          // 2. 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(emoji),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildBubbleTail(),

                        // 하향 확장 애니메이션
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _buildBubbleContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 페르소나 컬러가 적용된 아바타 생성
  Widget _buildAvatar(String emoji) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            widget.color.withValues(alpha: 0.1),
            widget.color.withValues(alpha: 0.2),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }

  /// 페르소나 컬러 기반 말풍선 콘텐츠
  Widget _buildBubbleContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 배경과 테두리에 페르소나 컬러 반영
        color: widget.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Icon(
                  isExpanded ? Icons.auto_awesome : Icons.chat_bubble_outline,
                  size: 16,
                  color: widget.color, // 아이콘 색상 변경
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isExpanded ? widget.fullMessage : widget.previewMessage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    // 확장 전에는 페르소나 컬러로 강조, 확장 후에는 가독성을 위해 어두운 색상
                    color: isExpanded ? const Color(0xFF1E293B) : widget.color,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          if (!isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 24),
              child: Row(
                children: [
                  Text(
                    "자세히 보기",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 14, color: widget.color),
                ],
              ),
            ),

          // 확장 영역 (상세 분석)
          if (isExpanded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: widget.color.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn("연관 거래", widget.relatedTo),
                  _buildInfoColumn(
                    "금액",
                    "${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "닫기",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 말풍선 꼬리 (페르소나 컬러 Painter 적용)
  Widget _buildBubbleTail() {
    return Positioned(
      left: -8,
      top: 16,
      child: CustomPaint(
        painter: TrianglePainter(widget.color.withValues(alpha: 0.1)),
      ),
    );
  }

  /// 상세 정보 컬럼 (라벨에 페르소나 컬러 연하게 적용)
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: widget.color.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

/// 삼각형 말풍선 꼬리를 그리는 Painter
class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(0, 8);
    path.lineTo(8, 0);
    path.lineTo(8, 16);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
