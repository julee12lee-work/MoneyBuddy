import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // 광진님이 추가

/// [Project] Buddy - AI 가계부 서비스
/// [File] SideMenu - 내비게이션 드로어
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 앱의 주요 메뉴로 이동할 수 있는 사이드 메뉴
/// Firebase에서 실시간 사용자 정보를 가져와 표시
/// 
/// * [Collaborators Note]
/// - 광진: Firebase Auth 연동 완료 후 _loadUserData() 메서드 구현
/// - 광진: 프로필 사진 업로드 기능 추가 예정
/// - 준수: 로그아웃 시 확인 다이얼로그 디자인

class SideMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Function(int) onMenuSelected;

  const SideMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onMenuSelected,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // --- [A] 상태 관리 영역 ---
  
  /// 현재 로그인한 사용자 정보
  /// [광진 TODO] FirebaseAuth.instance.currentUser로 초기화
  // User? _currentUser;
  
  /// 사용자 데이터 로딩 상태
  /// [Usage] 로딩 중일 때 스켈레톤 UI 표시
  bool _isLoading = true;
  
  /// 사용자 이름 (임시)
  /// [광진 TODO] _currentUser?.displayName으로 대체
  String _userName = "이준수";
  
  /// 프로필 이미지 URL (임시)
  /// [광진 TODO] _currentUser?.photoURL로 대체
  String? _userPhotoUrl;

  // --- [B] 라이프사이클 메서드 ---

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Firebase에서 사용자 정보 로드
  /// [광진 연동 포인트] 여기서 Firebase Auth 호출
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // * [광진 TODO] Firebase Auth에서 사용자 정보 가져오기
      // final user = FirebaseAuth.instance.currentUser;
      // 
      // if (user != null) {
      //   setState(() {
      //     _currentUser = user;
      //     _userName = user.displayName ?? "사용자";
      //     _userPhotoUrl = user.photoURL;
      //     _isLoading = false;
      //   });
      // }
      
      // [임시] 1초 딜레이로 로딩 테스트
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 로그아웃 처리
  /// [광진 연동 포인트] Firebase 로그아웃 로직
  Future<void> _handleLogout() async {
    // [UX] 확인 다이얼로그 표시
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;
    
    try {
      // * [광진 TODO] Firebase 로그아웃
      // await FirebaseAuth.instance.signOut();
      // 
      // // SharedPreferences 초기화
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      
      // [Callback] 로그인 화면으로 이동은 부모가 처리
      widget.onClose();
      
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
        );
      }
    }
  }

  /// 로그아웃 확인 다이얼로그
  /// [Returns] true: 로그아웃 진행, false: 취소
  Future<bool> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // --- [C] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    final Color brandColor = const Color(0xFF007955);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // [Section 1] Header: 사용자 프로필
        _buildProfileHeader(brandColor),

        // [Section 2] Body: 메뉴 리스트
        _buildMenuList(),

        // [Section 3] Footer: 버전 정보
        _buildFooter(),
      ],
    );
  }

  /// 사용자 프로필 헤더
  Widget _buildProfileHeader(Color brandColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: brandColor,
      child: _isLoading
          ? _buildLoadingSkeleton() // 로딩 중
          : _buildUserProfile(),     // 사용자 정보 표시
    );
  }

  /// 로딩 스켈레톤 UI
  /// [Design] 사용자 정보 로딩 중일 때 표시
  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 이미지 스켈레톤
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 16),
        // 이름 스켈레톤
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // 인사말 스켈레톤
        Container(
          width: 150,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  /// 사용자 프로필 정보
  Widget _buildUserProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 아바타
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: _userPhotoUrl != null
              ? NetworkImage(_userPhotoUrl!)
              : null,
          child: _userPhotoUrl == null
              ? const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF007955),
                  size: 35,
                )
              : null,
        ),
        const SizedBox(height: 16),

        // 사용자 이름
        Text(
          "$_userName 님",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 인사 메시지
        Text(
          _getGreetingMessage(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// 시간대별 인사 메시지
  /// [Feature] 오전/오후/저녁에 따라 다른 메시지
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return "좋은 아침이에요! 오늘도 현명한 소비 하세요 ☀️";
    } else if (hour < 18) {
      return "오늘도 똑똑한 소비 중인가요? 😊";
    } else {
      return "오늘 하루 수고하셨어요! 🌙";
    }
  }

  /// 메뉴 리스트
  Widget _buildMenuList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildMenuItem(
            icon: Icons.face_rounded,
            title: "페르소나 관리",
            subtitle: "F, S, T 캐릭터 전환 및 설정",
            onTap: () {
              widget.onMenuSelected(1);
              widget.onClose();
            },
          ),
          _buildMenuItem(
            icon: Icons.analytics_rounded,
            title: "지출 통계",
            subtitle: "주간/월간 소비 리포트",
            onTap: () {
              widget.onMenuSelected(2);
              widget.onClose();
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_rounded,
            title: "설정",
            subtitle: "알림 및 계정 관리",
            onTap: () {
              widget.onMenuSelected(3);
              widget.onClose();
            },
          ),
          
          const Divider(height: 32), // 구분선
          
          // [New] 로그아웃 메뉴
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: "로그아웃",
            subtitle: "계정에서 로그아웃",
            onTap: _handleLogout,
            isDestructive: true, // 빨간색 표시
          ),
        ],
      ),
    );
  }

  /// 앱 버전 정보 푸터
  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "MoneyBuddy v1.0.0",
        style: TextStyle(color: Colors.grey, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 메뉴 아이템
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false, // 로그아웃 같은 위험한 액션 표시
  }) {
    final color = isDestructive 
        ? Colors.red.shade400 
        : const Color(0xFF64748B);
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDestructive ? Colors.red.shade400 : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}