import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  // 부모에게 어떤 화면으로 바꿀지 알려주는 콜백 (0:대시보드, 1:페르소나, 2:통계 등)
  final Function(int) onMenuSelected; 

  const SideMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    // StatelessWidget은 반드시 build 메서드를 가져야 합니다.
    return _buildSideMenuContent();
  }

  Widget _buildSideMenuContent() {
    final Color brandColor = const Color(0xFF007955);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 메뉴 헤더
        Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          color: brandColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_rounded, color: Color(0xFF007955), size: 35),
              ),
              const SizedBox(height: 16),
              const Text(
                "이준수 님",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "오늘도 똑똑한 소비 중인가요?",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        // 2. 메뉴 리스트
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildMenuItem(
                icon: Icons.face_rounded,
                title: "페르소나 관리",
                subtitle: "F, S, T 캐릭터 전환 및 설정",
                onTap: () {
                  // [핵심] 부모에게 1번 화면(페르소나)으로 가라고 알리고 메뉴를 닫습니다.
                  onMenuSelected(1); 
                  onClose();
                },
              ),
              _buildMenuItem(
                icon: Icons.analytics_rounded,
                title: "지출 통계",
                subtitle: "주간/월간 소비 리포트",
                onTap: () {
                  // [핵심] 부모에게 2번 화면(통계)으로 가라고 알리고 메뉴를 닫습니다.
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

        // 3. 하단 버전 정보
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}