import 'package:flutter/material.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] FeedCard - 지출 내역 카드 컴포넌트
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 개별 지출 내역을 표시하고 상세 정보를 확장/편집할 수 있는 카드 위젯
/// 기록 탭(메모, 감정)과 분석 탭(예산 현황)을 제공
/// 
/// * [Collaborators Note]
/// - 광진: Firebase Firestore에 지출 데이터 저장/수정 로직 추가 예정
/// - 광진: 실시간 예산 계산을 서버에서 받아오도록 변경 필요
/// - 원준: 메모 입력 시 AI 자동 완성 기능 추가 예정
/// - 준수: 감정 선택 시 햅틱 피드백 추가 예정
/// 
/// * [Future Features]
/// - 영수증 이미지 첨부
/// - 위치 정보 자동 저장
/// - 반복 지출 설정

// --- [A] 열거형 정의 ---

/// 지출 시 느낀 감정을 나타내는 열거형
/// [Usage] 사용자의 소비 패턴 분석 및 피드백 개인화에 활용
enum EmotionType {
  happy,     // 😊 기쁨 - 만족스러운 소비
  satisfied, // 😌 만족 - 필요한 소비
  neutral,   // 😐 보통 - 평범한 소비
  regret,    // 😔 후회 - 불필요한 소비
  sad,       // 😢 슬픔 - 과소비
}

// --- [B] 메인 위젯 정의 ---

/// FeedCard: 지출 내역 표시 및 관리 카드
/// [Features]
/// 1. 지출 요약 표시 (아이콘, 제목, 금액)
/// 2. 확장 가능한 상세 정보 영역
/// 3. 카테고리 변경 (BottomSheet)
/// 4. 기록/분석 탭 전환
class FeedCard extends StatefulWidget {
  /// 초기 카테고리 아이콘 (이모지)
  final String icon;
  
  /// 지출 제목 (예: "스타벅스")
  /// [Null] null일 경우 카테고리명 사용
  final String? title;
  
  /// 지출 금액
  /// [Negative] 지출은 음수, 수입은 양수
  final int amount;
  
  /// 지출 카테고리 (예: "카페", "식비")
  final String category;
  
  /// 해당 카테고리의 남은 예산
  /// * [광진 TODO] Firestore에서 실시간 계산
  final int budgetRemaining;
  
  /// 해당 카테고리의 전체 예산
  /// * [광진 TODO] 사용자 설정에서 가져오기
  final int budgetTotal;

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
  
  // --- [C] 상태 관리 영역 ---
  
  /// 카드 확장 여부
  /// [State] false: 요약만 표시, true: 상세 정보 표시
  bool isExpanded = false;
  
  /// 현재 활성화된 상세 탭
  /// [Values] '기록' 또는 '분석'
  String activeTab = '기록';

  /// 애니메이션 지속 시간 (동적 제어)
  /// [Logic] 카드 열기/닫기: 300ms, 탭 전환: 0ms (깜빡임 방지)
  Duration _animatedSizeDuration = const Duration(milliseconds: 300);

  /// 현재 선택된 아이콘
  /// [Editable] 사용자가 카테고리 변경 시 업데이트
  late String currentIcon;
  
  /// 현재 선택된 카테고리
  /// [Editable] 사용자가 카테고리 변경 시 업데이트
  late String currentCategory;
  
  /// 제목 입력 컨트롤러
  /// [Usage] 기록 탭에서 별명 수정
  late TextEditingController _nameController;
  
  /// 메모 입력 컨트롤러
  /// [Usage] 기록 탭에서 간단 메모 작성
  /// * [원준 TODO] AI 자동 완성 기능 추가
  late TextEditingController _memoController;
  
  /// 선택된 감정 상태
  /// [Nullable] 선택하지 않을 수도 있음
  EmotionType? selectedEmotion;

  /// 브랜드 메인 컬러 (테마에서 가져옴)
  Color get brandColor => Theme.of(context).colorScheme.primary;

  /// 카테고리 변경 시 선택 가능한 옵션 리스트
  /// * [준수 TODO] 사용자 커스텀 카테고리 추가 기능 필요
  /// * [광진 TODO] Firestore에서 동적으로 불러오기
  final List<Map<String, String>> categoryOptions = [
    {'icon': '☕', 'label': '카페'},
    {'icon': '🍔', 'label': '식비'},
    {'icon': '🚗', 'label': '교통'},
    {'icon': '🛍️', 'label': '쇼핑'},
    {'icon': '🍺', 'label': '술/유흥'},
    {'icon': '🎁', 'label': '선물'},
  ];

  // --- [D] 라이프사이클 메서드 ---

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
    // [Important] 메모리 누수 방지
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // --- [E] 유틸리티 메서드 ---

  /// 숫자를 천 단위 콤마 포맷으로 변환
  /// [Example] 5500 → "5,500" / 287000 → "287,000"
  String _formatCurrency(int amount) {
    return amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // --- [F] 비즈니스 로직 메서드 ---

  /// 카테고리 선택 BottomSheet 표시
  /// [UX] 그리드 형태로 카테고리 옵션 제공
  /// * [광진 TODO] 선택 후 Firestore에 업데이트
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
              
              // [Grid] 카테고리 옵션 그리드
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
                      
                      // * [광진 TODO] Firestore 업데이트
                      // await FirebaseFirestore.instance
                      //   .collection('expenses')
                      //   .doc(expenseId)
                      //   .update({
                      //     'icon': currentIcon,
                      //     'category': currentCategory,
                      //   });
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

  /// 지출 데이터 저장
  /// * [광진 TODO] Firebase에 메모, 감정, 별명 저장
  Future<void> _saveExpenseData() async {
    // * [광진 연동 포인트]
    // try {
    //   await FirebaseFirestore.instance
    //     .collection('expenses')
    //     .doc(expenseId)
    //     .update({
    //       'name': _nameController.text,
    //       'memo': _memoController.text,
    //       'emotion': selectedEmotion?.toString(),
    //       'updatedAt': FieldValue.serverTimestamp(),
    //     });
    //   
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('저장되었습니다')),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('저장 실패: $e')),
    //   );
    // }
    
    // [임시] 카드 닫기
    setState(() => isExpanded = false);
  }

  // --- [G] UI 렌더링 영역 ---

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
          // [Section 1] 카드 헤더 (요약 정보)
          _buildCardHeader(isNegative),

          // [Section 2] 상세 정보 확장 영역 (애니메이션)
          AnimatedSize(
            duration: _animatedSizeDuration,
            curve: Curves.easeInOut,
            child: SizedBox(
              width: double.infinity,
              child: !isExpanded
                  ? const SizedBox.shrink() // 닫혔을 때
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          
                          // [Component] 기록/분석 탭 전환 바
                          _buildSegmentedTab(),
                          
                          const SizedBox(height: 16),
                          
                          // [Component] 선택된 탭 내용 표시
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

  // --- [H] 컴포넌트 빌더 메서드 ---

  /// 카드 헤더 (아이콘, 제목, 금액)
  Widget _buildCardHeader(bool isNegative) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // [Component 1] 카테고리 아이콘 (탭 시 변경 가능)
          GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              alignment: Alignment.center,
              child: Text(
                currentIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // [Component 2] 제목 및 카테고리 (탭 시 확장)
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  // [Animation] 카드 열기/닫기는 300ms 애니메이션
                  _animatedSizeDuration = const Duration(milliseconds: 300);
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
          
          // [Component 3] 금액 표시
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
    );
  }

  /// 기록/분석 전환용 세그먼트 탭 바
  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _buildTabButton('기록'),
          _buildTabButton('분석'),
        ],
      ),
    );
  }

  /// 개별 탭 버튼
  Widget _buildTabButton(String label) {
    bool isActive = activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // [Animation] 탭 전환 시에는 즉시(0ms) 변경 (깜빡임 방지)
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

  /// 기록 탭: 별명, 메모, 감정 입력
  Widget _buildRecordTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [Field 1] 별명 입력
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
        
        // [Field 2] 메모 입력
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
        
        // [Field 3] 감정 선택
        _buildEmotionSelector(),
        
        const SizedBox(height: 20),
        
        // [Button] 저장 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveExpenseData,
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

  /// 분석 탭: 예산 사용 현황
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
          // [Row 1] 카테고리명 및 남은 예산
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
          
          // [Progress Bar] 예산 사용량 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: percentage > 0.9
                  ? Colors.red // [Warning] 90% 이상 사용 시 경고색
                  : brandColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // [Row 2] 사용 금액 / 전체 예산
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

  /// 감정 아이콘 선택기 (5가지 감정)
  /// * [준수 TODO] 선택 시 햅틱 피드백 추가
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
        bool isSelected = selectedEmotion == e['type'];
        return GestureDetector(
          onTap: () {
            setState(() => selectedEmotion = e['type']);
            
            // * [준수 TODO] 햅틱 피드백
            // HapticFeedback.lightImpact();
          },
          child: Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? brandColor.withValues(alpha: 0.1)
                  : const Color(0xFFF8FAFC),
              border: Border.all(
                color: isSelected ? brandColor : Colors.grey.shade200,
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
                    color: isSelected ? brandColor : const Color(0xFF64748B),
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
