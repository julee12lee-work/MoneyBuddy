import 'package:flutter/material.dart';

/// [FeedHeader] 소비 내역 리스트의 상단 타이틀 및 뷰 모드 전환을 담당하는 위젯입니다.
///
/// 기능:
/// 1. '소비 내역' 섹션 타이틀 표시
/// 2. 드롭다운(PopupMenuButton)을 통한 목록/달력 보기 모드 전환
///
class FeedHeader extends StatelessWidget {
  final String viewMode; // 현재 뷰 상태 ('list' 또는 'calendar')
  final Function(String) onViewModeChange; // 모드 변경 시 부모 위젯으로 알리는 콜백 함수

  const FeedHeader({
    super.key,
    required this.viewMode,
    required this.onViewModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 20, top: 20, bottom: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // 타이틀은 왼쪽, 버튼은 오른쪽 끝 배치
        children: [
          // 섹션 타이틀
          const Text(
            '소비 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // var(--color-slate-dark) 대용
            ),
          ),

          // 뷰 전환용 드롭다운 메뉴 (리액트의 Popup 기능을 플러터 방식으로 구현)
          _buildDropdown(context),
        ],
      ),
    );
  }

  /// [Dropdown] 목록/달력 선택 버튼을 생성합니다.
  Widget _buildDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onViewModeChange, // 선택 시 외부에서 전달받은 로직 실행
      offset: const Offset(0, 45), // 버튼 아래로 메뉴가 나타나도록 위치 조정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 메뉴 박스의 둥근 모서리 적용
      ),
      // 화면에 항상 보이는 트리거 버튼 디자인
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100), // 캡슐 모양 디자인
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
          children: [
            // 현재 상태에 따른 텍스트 표시
            Text(
              viewMode == 'list' ? '목록' : '달력',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down, // 드롭다운 화살표 아이콘
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      // 클릭 시 나타날 실제 메뉴 항목들
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'list',
          child: Text('목록', style: TextStyle(fontSize: 14)),
        ),
        const PopupMenuItem(
          value: 'calendar',
          child: Text('달력', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
