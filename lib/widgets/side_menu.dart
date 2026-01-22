import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [Gwang-jin] Firebase Auth 연동
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] SideMenu - 내비게이션 드로어
/// [Author] 이준수 (PM & Design & Frontend)
/// [Description] 
/// 앱의 주요 메뉴로 이동할 수 있는 사이드 메뉴. Firebase 실시간 사용자 정보를 반영합니다.
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
  
  User? _currentUser;
  bool _isLoading = true;
  String _userName = "사용자";
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- [B] 비즈니스 로직 ---

  /// [Gwang-jin 연동 포인트] Firebase Auth에서 실시간 유저 정보를 가져옵니다.
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        setState(() {
          _currentUser = user;
          _userName = user.displayName ?? "사용자";
          _userPhotoUrl = user.photoURL;
        });
      }
      
      // 실제 네트워크 속도감을 위해 아주 짧은 딜레이 후 로딩 해제
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;
    
    try {
      await FirebaseAuth.instance.signOut();
      widget.onClose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
        title: const Text('로그아웃', style: AppTextStyles.h4),
        content: const Text('정말 로그아웃하시겠어요?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('로그아웃', style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // --- [C] UI 렌더링 영역 ---

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileHeader(),
        _buildMenuList(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: AppColors.primary,
      child: _isLoading ? _buildLoadingSkeleton() : _buildUserProfile(),
    );
  }

  Widget _buildLoadingSkeleton() {
    final skeletonColor = Colors.white.withValues(alpha: 0.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: skeletonColor, shape: BoxShape.circle)),
        const SizedBox(height: AppDimensions.paddingMedium),
        Container(width: 100, height: 20, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8),
        Container(width: 150, height: 14, decoration: BoxDecoration(color: skeletonColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: _userPhotoUrl != null ? NetworkImage(_userPhotoUrl!) : null,
          child: _userPhotoUrl == null
              ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 35)
              : null,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text("$_userName 님", style: AppTextStyles.h4.copyWith(color: Colors.white)),
        Text(_getGreetingMessage(), style: AppTextStyles.caption.copyWith(color: Colors.white70)),
      ],
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "좋은 아침이에요! 오늘도 현명한 소비 하세요 ☀️";
    if (hour < 18) return "오늘도 똑똑한 소비 중인가요? 😊";
    return "오늘 하루 수고하셨어요! 🌙";
  }

  Widget _buildMenuList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildMenuItem(
            icon: Icons.face_rounded,
            title: "페르소나 관리",
            subtitle: "F, S, T 캐릭터 전환 및 설정",
            onTap: () { widget.onMenuSelected(1); widget.onClose(); },
          ),
          _buildMenuItem(
            icon: Icons.analytics_rounded,
            title: "지출 통계",
            subtitle: "주간/월간 소비 리포트",
            onTap: () { widget.onMenuSelected(2); widget.onClose(); },
          ),
          _buildMenuItem(
            icon: Icons.settings_rounded,
            title: "설정",
            subtitle: "알림 및 계정 관리",
            onTap: () { widget.onMenuSelected(3); widget.onClose(); },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 32, color: AppColors.divider),
          ),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: "로그아웃",
            subtitle: "계정에서 로그아웃",
            onTap: _handleLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      child: Text(
        "MoneyBuddy v1.0.0",
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color iconColor = isDestructive ? AppColors.error : AppColors.textSecondary;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: AppTextStyles.bodyBold.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      onTap: onTap,
    );
  }
}