import 'package:flutter/material.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] FeedHeader - 소비 내역 섹션 헤더
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 소비 내역 리스트 상단의 타이틀 및 뷰 모드 전환 컨트롤을 제공하는 위젯
/// 목록 뷰와 달력 뷰 간 전환 기능 포함
/// 
/// * [Collaborators Note]
/// - 준수: 필터 기능 추가 예정 (카테고리별, 기간별)
/// - 원준: AI 추천 필터 기능 추가 예정 ("이번 주 과소비 항목만 보기")
/// 
/// * [Future Features]
/// - 정렬 옵션 (날짜순, 금액순, 카테고리순)
/// - 검색 기능
/// - 다중 선택 모드 (일괄 삭제/수정)

class FeedHeader extends StatelessWidget {
  /// 현재 뷰 모드
  /// [Values] 'list' (목록 뷰) 또는 'calendar' (달력 뷰)
  final String viewMode;
  
  /// 뷰 모드 변경 시 실행되는 콜백
  /// [Parameter] 선택된 뷰 모드 ('list' 또는 'calendar')
  /// [Action] 부모 위젯(DashboardScreen)에서 상태 업데이트
  final Function(String) onViewModeChange;

  const FeedHeader({
    super.key,
    required this.viewMode,
    required this.onViewModeChange,
  });

  // --- [A] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 20,
        top: 20,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // [Component 1] 섹션 타이틀
          _buildSectionTitle(),

          // [Component 2] 뷰 모드 전환 드롭다운
          _buildViewModeDropdown(context),
        ],
      ),
    );
  }

  // --- [B] 컴포넌트 빌더 메서드 ---

  /// 섹션 타이틀 텍스트
  /// [Design] 볼드체로 강조
  Widget _buildSectionTitle() {
    return const Text(
      '소비 내역',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B), // [Color] Slate Dark
      ),
    );
  }

  /// 뷰 모드 전환 드롭다운 메뉴
  /// [Features]
  /// - 현재 모드 표시 (목록/달력)
  /// - 클릭 시 선택 메뉴 표시
  /// - 선택 시 부모에게 콜백 전달
  Widget _buildViewModeDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onViewModeChange, // [Callback] 선택 시 부모에게 전달
      offset: const Offset(0, 45), // [Position] 버튼 아래로 메뉴 표시
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // [Design] 둥근 모서리
      ),
      
      // [Trigger Button] 항상 화면에 표시되는 버튼
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100), // [Design] 캡슐 모양
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [Text] 현재 선택된 모드 표시
            Text(
              viewMode == 'list' ? '목록' : '달력',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 4),
            
            // [Icon] 드롭다운 화살표
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      
      // [Popup Menu] 클릭 시 나타나는 메뉴 항목들
      itemBuilder: (context) => [
        _buildMenuItem('list', '목록'),
        _buildMenuItem('calendar', '달력'),
        
        // * [준수 TODO] 추가 예정 메뉴 항목들
        // const PopupMenuDivider(), // 구분선
        // _buildMenuItem('filter', '필터'),
        // _buildMenuItem('sort', '정렬'),
      ],
    );
  }

  /// 개별 메뉴 아이템
  /// [Parameters]
  /// - value: 선택 시 전달될 값
  /// - label: 화면에 표시될 텍스트
  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}