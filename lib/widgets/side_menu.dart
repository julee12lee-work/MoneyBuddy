import 'package:flutter/material.dart';

/// [Project] Buddy - AI 가계부
/// [Module] SideMenu (내비게이션 드로어 콘텐츠)
/// [Author] 이준수
/// [Description] 앱의 주요 메뉴(페르소나, 통계, 설정 등)로의 이동을 담당하는 사이드 바입니다.
/// 부모 위젯의 화면 전환 로직(onMenuSelected)을 콜백으로 호출합니다.

class SideMenu extends StatelessWidget {
  /// 현재 메뉴가 열려 있는지 여부 (애니메이션 및 상태 제어용)
  final bool isOpen;

  /// 메뉴 닫기 버튼 또는 배경 클릭 시 호출될 콜백
  final VoidCallback onClose;

  /// [Navigation Logic] 선택된 메뉴의 인덱스에 따라 화면 전환을 수행하는 콜백
  /// - 1: 페르소나 관리
  /// - 2: 지출 통계
  /// - 3: 설정
  final Function(int) onMenuSelected;

  const SideMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    // StatelessWidget은 단일 렌더링을 담당하며, 내부 UI 구성을 함수로 분리하여 가독성을 높임
    return _buildSideMenuContent();
  }

  /// [UI] 사이드 메뉴의 전체 레이아웃 구성
  Widget _buildSideMenuContent() {
    final Color brandColor = const Color(0xFF007955); // Buddy 메인 브랜드 컬러

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. [Header] 사용자 프로필 및 개인화 메시지 영역
        Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          color: brandColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF007955),
                  size: 35,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "이준수 님", // [기획] 유저 데이터 연동 포인트
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "오늘도 똑똑한 소비 중인가요?",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        // 2. [Body] 내비게이션 메뉴 리스트
        // Expanded를 통해 메뉴 리스트가 가용한 남은 공간을 차지하도록 설정
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildMenuItem(
                icon: Icons.face_rounded,
                title: "페르소나 관리",
                subtitle: "F, S, T 캐릭터 전환 및 설정",
                onTap: () {
                  // [핵심 로직] 화면 전환 후 메뉴를 자동으로 닫아 UX 완성도 향상
                  onMenuSelected(1);
                  onClose();
                },
              ),
              _buildMenuItem(
                icon: Icons.analytics_rounded,
                title: "지출 통계",
                subtitle: "주간/월간 소비 리포트",
                onTap: () {
                  onMenuSelected(2);
                  onClose();
                },
              ),
              _buildMenuItem(
                icon: Icons.settings_rounded,
                title: "설정",
                subtitle: "알림 및 계정 관리",
                onTap: () {
                  onMenuSelected(3);
                  onClose();
                },
              ),
            ],
          ),
        ),

        // 3. [Footer] 앱 버전 정보
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "MoneyBuddy v1.0.0",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// [Component] 메뉴 리스트의 가독성을 위한 공용 아이템 빌더
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap, // Ripple 효과와 함께 콜백 실행
    );
  }
}
