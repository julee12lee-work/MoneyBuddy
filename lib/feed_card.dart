import 'package:flutter/material.dart';

/// 지출 내역의 감정 상태를 정의하는 열거형
enum EmotionType { happy, satisfied, neutral, regret, sad }

/// [FeedCard] 지출 내역을 표시하는 개별 카드 컴포넌트입니다.
///
/// 기능:
/// 1. 지출 내역 요약 표시 (아이콘, 제목, 금액)
/// 2. 카드 클릭 시 상세 영역 확장 (기록/분석 탭)
/// 3. 아이콘 클릭 시 카테고리 및 아이콘 변경 (Bottom Sheet)
/// 4. 탭 전환 시 높이 애니메이션 최적화 제어
class FeedCard extends StatefulWidget {
  final String icon; // 초기 아이콘 (이모지)
  final String? title; // 지출 제목 (예: 스타벅스)
  final int amount; // 지출 금액
  final String category; // 지출 카테고리 (예: 카페)
  final int budgetRemaining; // 해당 카테고리 남은 예산
  final int budgetTotal; // 해당 카테고리 전체 예산

  const FeedCard({
    super.key,
    required this.icon,
    this.title,
    required this.amount,
    required this.category,
    this.budgetRemaining = 15000,
    this.budgetTotal = 100000,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard>
    with SingleTickerProviderStateMixin {
  // --- 상태 관리 변수 ---
  bool isExpanded = false; // 카드 확장 여부
  String activeTab = '기록'; // 현재 활성화된 상세 탭 ('기록' 또는 '분석')

  /// 애니메이션 지속 시간 (Dynamic Duration)
  /// 카드를 열고 닫을 때는 300ms를 사용하고, 탭 전환 시에는 0ms로 변경하여
  /// 테두리가 덜컹거리는 애니메이션을 방지합니다.
  Duration _animatedSizeDuration = const Duration(milliseconds: 300);

  late String currentIcon; // 현재 선택된 아이콘
  late String currentCategory; // 현재 선택된 카테고리
  late TextEditingController _nameController; // 제목 수정용 컨트롤러
  late TextEditingController _memoController; // 메모 입력용 컨트롤러
  EmotionType? selectedEmotion; // 선택된 감정 상태

  /// 브랜드 메인 컬러 (민트 테마)
  Color get brandColor => Theme.of(context).colorScheme.primary;

  /// 카테고리 변경 시 사용할 옵션 리스트
  final List<Map<String, String>> categoryOptions = [
    {'icon': '☕', 'label': '카페'},
    {'icon': '🍔', 'label': '식비'},
    {'icon': '🚗', 'label': '교통'},
    {'icon': '🛍️', 'label': '쇼핑'},
    {'icon': '🍺', 'label': '술/유흥'},
    {'icon': '🎁', 'label': '선물'},
  ];

  @override
  void initState() {
    super.initState();
    currentIcon = widget.icon;
    currentCategory = widget.category;
    _nameController = TextEditingController(
      text: widget.title ?? widget.category,
    );
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 숫자를 3자리 단위로 콤마가 포함된 금액 문자열로 변환합니다.
  String _formatCurrency(int amount) {
    return amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 아이콘 클릭 시 카테고리를 변경할 수 있는 BottomSheet를 표시합니다.
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "카테고리 선택",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: categoryOptions.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        currentIcon = categoryOptions[index]['icon']!;
                        currentCategory = categoryOptions[index]['label']!;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(categoryOptions[index]['icon']!),
                          const SizedBox(width: 6),
                          Text(
                            categoryOptions[index]['label']!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNegative = widget.amount < 0;
    int budgetUsed = widget.budgetTotal - widget.budgetRemaining;
    double budgetPercentage = (budgetUsed / widget.budgetTotal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- 1. 카드 상단 (헤더) 영역 ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // 아이콘 (카테고리 변경 트리거)
                GestureDetector(
                  onTap: _showCategoryPicker,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1F5F9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 제목 및 카테고리 텍스트 (확장 트리거)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // 카드를 열고 닫을 때는 부드러운 애니메이션(300ms) 적용
                        _animatedSizeDuration = const Duration(
                          milliseconds: 300,
                        );
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 금액 표시
                Text(
                  "${isNegative ? '-' : '+'}${_formatCurrency(widget.amount)}원",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? Colors.red : brandColor,
                  ),
                ),
              ],
            ),
          ),

          // --- 2. 상세 정보 확장 영역 (애니메이션 적용) ---
          AnimatedSize(
            duration: _animatedSizeDuration,
            curve: Curves.easeInOut,
            child: SizedBox(
              width: double.infinity,
              child: !isExpanded
                  ? const SizedBox.shrink() // 닫혔을 때는 공간 차지 없음
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _buildSegmentedTab(), // 기록/분석 탭 선택바
                          const SizedBox(height: 16),
                          // 탭 선택에 따른 조건부 렌더링
                          activeTab == '기록'
                              ? _buildRecordTab()
                              : _buildAnalysisTab(budgetUsed, budgetPercentage),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// [기록/분석] 전환용 세그먼트 탭 바 위젯을 생성합니다.
  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [_buildTabButton('기록'), _buildTabButton('분석')]),
    );
  }

  /// 탭 바 내부의 개별 버튼 위젯을 생성합니다.
  Widget _buildTabButton(String label) {
    bool isActive = activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // 탭 전환 시에는 배경 크기가 부드럽게 변하지 않고
            // 즉시(0ms) 바뀌도록 설정하여 어색함을 제거합니다.
            _animatedSizeDuration = Duration.zero;
            activeTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? brandColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // --- 상세 화면 구성 위젯 (서브 위젯) ---

  /// [기록 탭] 별명, 메모, 감정 상태를 입력받는 영역입니다.
  Widget _buildRecordTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "별명",
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: brandColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "간단 메모",
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 16),
        _buildEmotionSelector(), // 감정 아이콘 선택 영역
        const SizedBox(height: 20),
        // 저장 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => isExpanded = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "저장",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// [분석 탭] 현재 카테고리의 예산 사용 현황을 프로그레스 바로 표시합니다.
  Widget _buildAnalysisTab(int budgetUsed, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentCategory 예산",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                "${_formatCurrency(widget.budgetRemaining)}원 남음",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 예산 사용량 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: percentage > 0.9
                  ? Colors.red
                  : brandColor, // 90% 이상 사용 시 경고색(빨간색)
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_formatCurrency(budgetUsed)}원 사용",
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
              Text(
                "${_formatCurrency(widget.budgetTotal)}원 중",
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 5가지 감정 아이콘 선택기를 생성합니다.
  Widget _buildEmotionSelector() {
    final List<Map<String, dynamic>> emotions = [
      {'type': EmotionType.happy, 'emoji': '😊', 'label': '기쁨'},
      {'type': EmotionType.satisfied, 'emoji': '😌', 'label': '만족'},
      {'type': EmotionType.neutral, 'emoji': '😐', 'label': '보통'},
      {'type': EmotionType.regret, 'emoji': '😔', 'label': '후회'},
      {'type': EmotionType.sad, 'emoji': '😢', 'label': '슬픔'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: emotions.map((e) {
        bool isSel = selectedEmotion == e['type'];
        return GestureDetector(
          onTap: () => setState(() => selectedEmotion = e['type']),
          child: Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSel
                  ? brandColor.withValues(alpha: 0.1)
                  : const Color(0xFFF8FAFC),
              border: Border.all(
                color: isSel ? brandColor : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(e['emoji'], style: const TextStyle(fontSize: 20)),
                Text(
                  e['label'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSel ? brandColor : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
