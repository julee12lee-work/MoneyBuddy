import 'package:flutter/material.dart';
import 'dart:ui';

/// [Project] Buddy - AI 가계부 서비스
/// [File] FloatingInput - 스마트 지출 입력 컴포넌트
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 사용자의 자연어 입력에서 금액을 자동으로 추출하고,
/// AI 기반 추천 칩을 통해 빠른 지출 기록을 지원하는 하단 고정 입력바
/// 
/// * [Collaborators Note]
/// - 원준: 사용자 입력 텍스트의 NLP 파싱 로직 고도화 담당
/// - 원준: AI 추천 칩 데이터를 실시간으로 서버에서 받아오는 로직 추가 예정
/// - 광진: Firebase에서 사용자별 최근 지출 패턴 데이터 연동 예정
/// - 광진: suggestions 데이터를 Firestore에서 동적으로 로드하도록 변경 필요
/// 

// --- [A] 커스텀 스크롤 동작 정의 ---

/// MyCustomScrollBehavior
/// [Purpose] 웹/데스크톱 환경에서도 마우스 드래그로 추천 칩 스크롤 가능하도록 설정
/// [Usage] ScrollConfiguration의 behavior 파라미터에 전달
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // 모바일 터치
    PointerDeviceKind.mouse, // 데스크톱 마우스
  };
}

// --- [B] 메인 위젯 정의 ---

class FloatingInput extends StatefulWidget {
  /// 금액 파싱 완료 후 부모 위젯(DashboardScreen)에 전달하는 콜백
  /// [Flow] 사용자 입력 → 금액 추출 → 이 콜백 실행 → 카테고리 선택 모드 활성화
  /// [param] amount: 추출된 금액 (int)
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
  
  // --- [C] 상태 관리 영역 ---
  
  /// 텍스트 입력 필드 컨트롤러
  /// [Usage] 사용자가 입력한 텍스트 관리 및 프로그래밍 방식 입력
  final TextEditingController _controller = TextEditingController();
  
  /// 무지개 테두리 애니메이션 컨트롤러
  /// [Animation] 4초 주기로 360도 회전하는 그라데이션 효과
  late AnimationController _animController;

  /// AI 추천 지출 데이터셋 (Mock Data)
  /// * [원준 TODO] 서버 API로 실시간 추천 데이터 받아오기
  /// * [광진 TODO] Firestore에서 사용자별 최근 지출 패턴 기반으로 동적 생성
  /// 
  /// [기획 의도] 
  /// - 최근 소비 패턴을 분석하여 빈도가 높은 지출을 우선순위로 노출
  /// - 시간대별 추천 (아침: 커피, 점심: 식사 등)
  /// - 위치 기반 추천 (카페 근처: 커피 추천)
  final List<Map<String, dynamic>> suggestions = [
    {"label": "☕️ 커피", "amount": 5500},
    {"label": "🍽️ 식사", "amount": 12800},
    {"label": "🚗 택시", "amount": 18700},
    {"label": "🛍️ 쇼핑", "amount": 287000},
    {"label": "🥤 음료", "amount": 1500},
    {"label": "🎁 선물", "amount": 45000},
  ];

  // --- [D] 라이프사이클 메서드 ---

  @override
  void initState() {
    super.initState();
    
    // [Animation] 무지개 테두리 회전 애니메이션 초기화 (4초 주기)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // 무한 반복
  }

  @override
  void dispose() {
    // [Important] 메모리 누수 방지를 위한 컨트롤러 해제
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // --- [E] 유틸리티 메서드 ---

  /// 숫자를 천 단위 콤마(,)가 포함된 통화 형식으로 변환
  /// [Example] 5500 → "5,500" / 287000 → "287,000"
  /// [Usage] UI에 표시할 때 가독성 향상
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 사용자 입력 텍스트에서 숫자만 추출하는 핵심 로직
  /// [원준 연동 포인트] NLP 고도화 시 이 메서드 개선
  /// 
  /// [Current Logic] 정규표현식으로 숫자만 추출
  /// [Examples]
  /// - "커피 3000원" → 3000
  /// - "택시 18,750" → 18750
  /// - "3만원" → 3 (개선 필요!)
  /// 
  /// * [원준 TODO] 개선 사항:
  /// - "3만원" → 30000 으로 변환
  /// - "오천원" → 5000 (한글 숫자 인식)
  /// - "커피 한 잔" → 기본 커피 금액으로 자동 설정
  /// - AI 모델 연동으로 "스타벅스 아메리카노" → 4500원 자동 추론
  int? _extractAmount(String text) {
    final digits = RegExp(r'\d+')
      .allMatches(text.replaceAll(',', ''))
      .map((m) => m.group(0)!)
      .join();
    
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// 지출 데이터 확정 및 전송 로직
  /// [Flow]
  /// 1. 입력 텍스트에서 금액 추출
  /// 2. 부모 위젯(DashboardScreen)에 금액 전달
  /// 3. 카테고리 선택 모드 활성화
  /// 4. 입력 필드 초기화 및 키보드 닫기
  void _handleSend() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return; // [Validation] 빈 입력 방지

    final amount = _extractAmount(raw);
    if (amount == null) {
      // [UX] 금액을 추출할 수 없을 때 사용자에게 피드백
      // * [준수 TODO] 에러 메시지 표시 (SnackBar 또는 흔들림 애니메이션)
      return;
    }

    // [Callback] 부모 위젯에 금액 전달 → 카테고리 선택 모드 트리거
    widget.onAmountParsed.call(amount);

    // [Cleanup] 입력 필드 초기화 및 키보드 해제
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  // --- [F] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // [Section 1] 상단: AI 추천 지출 칩 리스트
        _buildSuggestionChips(),
        
        // [Section 2] 하단: 텍스트 입력창
        _buildInputField(context),
      ],
    );
  }

  /// AI 추천 칩 가로 스크롤 리스트
  /// [Design] Glassmorphism + Rainbow Border Animation
  /// [UX] 좌우 스크롤 가능, 탭하면 입력창에 자동 입력
  Widget _buildSuggestionChips() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(), // 마우스 드래그 지원
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(), // iOS 스타일 바운스 효과
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _buildChip(index),
        ),
      ),
    );
  }

  /// 개별 추천 칩 위젯
  /// [Design] Glassmorphism(블러 효과) + Rainbow Animation Border
  /// [Animation] RainbowBorderPainter를 통해 무지개 테두리가 회전
  /// [Interaction] 탭하면 입력창에 해당 텍스트 자동 입력
  Widget _buildChip(int index) {
    final String label = suggestions[index]['label'];
    final int amount = suggestions[index]['amount'] ?? 0;
    final String formattedText = "$label ${_formatCurrency(amount)}원";

    return GestureDetector(
      onTap: () {
        // [Action] 칩 탭 시 입력창에 텍스트 자동 입력
        setState(() {
          _controller.text = formattedText;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // [Effect] 블러 효과
          child: CustomPaint(
            painter: RainbowBorderPainter(_animController), // [Animation] 무지개 테두리
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

  /// 텍스트 입력 필드
  /// [Design] 하단 고정, Safe Area 대응 (iPhone 노치 등)
  /// [Features] 
  /// - 엔터키로 전송 가능
  /// - 전송 버튼 제공
  /// - 플레이스홀더 텍스트로 사용 가이드
  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom, // [Important] iPhone Safe Area 대응
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95), // [Design] 반투명 배경
        border: Border(
          top: BorderSide(color: Colors.grey.shade100), // 상단 구분선
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -5), // 위쪽으로 그림자
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // [Design] 연한 회색 배경
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // [Component 1] 텍스트 입력 필드
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                onSubmitted: (_) => _handleSend(), // [UX] 키보드 '완료/전송' 버튼 대응
                decoration: const InputDecoration(
                  hintText: "지출을 추가하려면 가격을 입력하세요.",
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  border: InputBorder.none, // 기본 테두리 제거 (커스텀 디자인 사용)
                ),
              ),
            ),
            
            // [Component 2] 전송 버튼
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(
                Icons.send_rounded,
                color: Color(0xFF00BFA5), // [Color] 메인 브랜드 컬러
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- [G] 커스텀 페인터 ---

/// RainbowBorderPainter
/// [Purpose] 무지개 그라데이션 테두리 애니메이션을 그리는 커스텀 페인터
/// [Animation] AnimationController의 값에 따라 SweepGradient가 회전
/// [Usage] CustomPaint 위젯의 painter 파라미터에 전달
/// 
/// [Design Note]
/// - 5가지 색상의 그라데이션 사용
/// - 4초에 한 바퀴 회전 (360도)
/// - 테두리 두께: 3.5px
class RainbowBorderPainter extends CustomPainter {
  /// 애니메이션 컨트롤러
  /// [Range] 0.0 ~ 1.0 (한 바퀴 회전)
  final Animation<double> animation;
  
  RainbowBorderPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF667EEA), // 보라
          Color(0xFF764BA2), // 진보라
          Color(0xFFF093FB), // 핑크
          Color(0xFF4FACFE), // 파랑
          Color(0xFF667EEA), // 다시 보라 (부드러운 연결)
        ],
        // [Animation] 0.0 ~ 1.0 값을 0 ~ 2π (360도)로 변환
        transform: GradientRotation(animation.value * 6.283185), // 2 * π
      ).createShader(rect)
      ..style = PaintingStyle.stroke // 테두리만 그리기
      ..strokeWidth = 3.5; // 테두리 두께

    // [Draw] 둥근 사각형 테두리 그리기
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(100)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RainbowBorderPainter oldDelegate) => true;
}