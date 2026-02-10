import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] SettingsScreen - 설정 화면
/// [Author] 이준수 (PM & Design)
///
/// [Description]
/// 사용자 계정, 소비 환경, AI 버디 설정 등을 관리하는 설정 화면입니다.
///
/// [주요 기능]
/// 1. 프로필 카드 - 사용자 정보 표시 및 프로필 편집
/// 2. 계정 정보 - 로그인 정보 확인, 비밀번호 변경
/// 3. 소비 환경 설정 - 한 달 시작일, 목표 예산, 내보내기
/// 4. AI 버디 & 알림 - 잔소리 모드, 에티켓 시간, 푸시 알림
/// 5. 고객 지원 - 공지사항, FAQ, 약관
/// 6. 로그아웃
///
/// [화면 구조]
/// ┌─────────────────────────────────┐
/// │  ←          설정                │  ← 헤더
/// ├─────────────────────────────────┤
/// │  👤 이준수 님                   │  ← 프로필 카드
/// │     julee12@email.com      >   │
/// ├─────────────────────────────────┤
/// │  계정 정보                      │  ← 섹션 타이틀
/// │  ┌─────────────────────────┐   │
/// │  │ 로그인 정보              │   │  ← 설정 그룹
/// │  │ Google 계정으로 로그인됨 │   │
/// │  ├─────────────────────────┤   │
/// │  │ 비밀번호 변경         > │   │
/// │  └─────────────────────────┘   │
/// ├─────────────────────────────────┤
/// │  소비 환경 설정                 │
/// │  ┌─────────────────────────┐   │
/// │  │ 한 달 시작일             │   │
/// │  │ 매월 1일                 │   │
/// │  ├─────────────────────────┤   │
/// │  │ 목표 예산 관리           │   │
/// │  │ 1,200,000원             │   │
/// │  ├─────────────────────────┤   │
/// │  │ 지출 내역 내보내기    > │   │
/// │  └─────────────────────────┘   │
/// ├─────────────────────────────────┤
/// │  AI 버디 & 알림                 │
/// │  ┌─────────────────────────┐   │
/// │  │ 버디의 잔소리 모드  🔘  │   │  ← 토글 스위치
/// │  ├─────────────────────────┤   │
/// │  │ 에티켓 시간 설정         │   │
/// │  │ 밤 11시 ~ 오전 7시      │   │
/// │  ├─────────────────────────┤   │
/// │  │ 푸시 알림 설정        > │   │
/// │  └─────────────────────────┘   │
/// ├─────────────────────────────────┤
/// │  고객 지원 및 정보              │
/// │  ┌─────────────────────────┐   │
/// │  │ 공지사항              > │   │
/// │  │ 자주 묻는 질문        > │   │
/// │  │ 이용약관              > │   │
/// │  │ 개인정보처리방침      > │   │
/// │  └─────────────────────────┘   │
/// ├─────────────────────────────────┤
/// │  [ 로그아웃 ]                   │  ← 로그아웃 버튼
/// │       MoneyBuddy v1.0.0        │  ← 버전 정보
/// └─────────────────────────────────┘
///
/// [Collaborators Note]
/// - 원준: 설정 값 로컬 저장소(SharedPreferences) 연동 담당 예정
/// - 광진: 프로필 이미지 업로드 및 Firebase Storage 연동 담당 예정
/// - 추후 서버 동기화 기능 추가 시 설정 백업/복원 기능 구현 예정

class SettingsScreen extends StatefulWidget {
  /// 뒤로가기 버튼 클릭 시 호출되는 콜백
  /// [Usage] main.dart에서 DashboardScreen으로 복귀할 때 사용
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // [A] 상태 관리 영역
  // ============================================================

  /// Firebase 사용자 정보
  /// [Note] 추후 프로필 편집, 계정 삭제 등에서 사용 예정
  // ignore: unused_field
  User? _currentUser;

  /// 사용자 이름 (Firebase에서 로드)
  String _userName = '사용자';

  /// 사용자 이메일
  String _userEmail = '';

  /// 사용자 프로필 이미지 URL
  String? _userPhotoUrl;

  /// 버디 잔소리 모드 활성화 여부
  /// [TODO] 원준 - SharedPreferences에서 로드/저장 로직 추가 필요
  bool _isNaggingModeEnabled = true;

  /// 한 달 시작일 (1~28)
  int _monthStartDay = 1;

  /// 목표 예산
  int _targetBudget = 1200000;

  /// 에티켓 시간 시작 (시간)
  int _quietTimeStart = 23;

  /// 에티켓 시간 종료 (시간)
  int _quietTimeEnd = 7;

  // ============================================================
  // [B] 라이프사이클 메서드
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  // ============================================================
  // [C] 비즈니스 로직 메서드
  // ============================================================

  /// Firebase에서 사용자 정보를 로드합니다.
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _userName = user.displayName ?? '사용자';
        _userEmail = user.email ?? '';
        _userPhotoUrl = user.photoURL;
      });
    }
  }

  /// 저장된 설정을 로드합니다.
  /// [TODO] 원준 - SharedPreferences 연동 필요
  void _loadSettings() {
    // TODO: SharedPreferences에서 설정 로드
    // 예시:
    // final prefs = await SharedPreferences.getInstance();
    // _isNaggingModeEnabled = prefs.getBool('nagging_mode') ?? true;
    // _monthStartDay = prefs.getInt('month_start_day') ?? 1;
  }

  /// 로그아웃을 처리합니다.
  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;

    try {
      await FirebaseAuth.instance.signOut();
      widget.onBack?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
        );
      }
    }
  }

  /// 로그아웃 확인 다이얼로그를 표시합니다.
  Future<bool> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: const Text('로그아웃', style: AppTextStyles.h4),
        content: const Text('정말 로그아웃하시겠어요?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ============================================================
  // [D] UI 렌더링 영역
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [섹션 1] 프로필 카드
                        _buildProfileCard(),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // [섹션 2] 계정 정보
                        _buildSectionTitle('계정 정보'),
                        _buildSettingsGroup([
                          _buildSettingItem(
                            title: '로그인 정보',
                            subtitle: 'Google 계정으로 로그인됨',
                          ),
                          _buildSettingItem(
                            title: '비밀번호 변경',
                            showArrow: true,
                            onTap: () {
                              // TODO: 비밀번호 변경 화면으로 이동
                            },
                          ),
                        ]),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // [섹션 3] 소비 환경 설정
                        _buildSectionTitle('소비 환경 설정'),
                        _buildSettingsGroup([
                          _buildSettingItem(
                            title: '한 달 시작일',
                            subtitle: '매월 $_monthStartDay일',
                            onTap: () {
                              // TODO: 시작일 선택 다이얼로그
                            },
                          ),
                          _buildSettingItem(
                            title: '목표 예산 관리',
                            subtitle: '${_formatCurrency(_targetBudget)}원',
                            onTap: () {
                              // TODO: 예산 설정 다이얼로그
                            },
                          ),
                          _buildSettingItem(
                            title: '지출 내역 내보내기 (CSV)',
                            showArrow: true,
                            onTap: () {
                              // TODO: CSV 내보내기 기능
                            },
                          ),
                        ]),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // [섹션 4] AI 버디 & 알림
                        _buildSectionTitle('AI 버디 & 알림'),
                        _buildSettingsGroup([
                          _buildSettingItemWithToggle(
                            title: '버디의 잔소리 모드',
                            value: _isNaggingModeEnabled,
                            onChanged: (value) {
                              setState(() => _isNaggingModeEnabled = value);
                              // TODO: SharedPreferences에 저장
                            },
                          ),
                          _buildSettingItem(
                            title: '에티켓 시간 설정',
                            subtitle: '밤 $_quietTimeStart시 ~ 오전 $_quietTimeEnd시',
                            onTap: () {
                              // TODO: 시간 설정 다이얼로그
                            },
                          ),
                          _buildSettingItem(
                            title: '푸시 알림 설정',
                            showArrow: true,
                            onTap: () {
                              // TODO: 알림 설정 화면으로 이동
                            },
                          ),
                        ]),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // [섹션 5] 고객 지원 및 정보
                        _buildSectionTitle('고객 지원 및 정보'),
                        _buildSettingsGroup([
                          _buildSettingItem(
                            title: '공지사항',
                            showArrow: true,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            title: '자주 묻는 질문',
                            showArrow: true,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            title: '이용약관',
                            showArrow: true,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            title: '개인정보처리방침',
                            showArrow: true,
                            onTap: () {},
                          ),
                        ]),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // [섹션 6] 로그아웃 버튼
                        _buildLogoutButton(),
                        const SizedBox(height: AppDimensions.paddingMedium),

                        // [섹션 7] 버전 정보
                        _buildVersionInfo(),
                        const SizedBox(height: AppDimensions.paddingLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // [E] 컴포넌트 빌더 메서드
  // ============================================================

  /// 상단 헤더를 빌드합니다.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('설정', style: AppTextStyles.h4),
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  /// 프로필 카드를 빌드합니다.
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.secondary,
            backgroundImage:
                _userPhotoUrl != null ? NetworkImage(_userPhotoUrl!) : null,
            child: _userPhotoUrl == null
                ? Text(
                    _userName.isNotEmpty ? _userName.substring(0, 2) : '사용',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.cardSpacing),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_userName 님', style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  _userEmail,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 화살표
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 섹션 타이틀을 빌드합니다.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingXSmall,
        bottom: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// 설정 그룹 컨테이너를 빌드합니다.
  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            // 구분선
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              height: 1,
              color: AppColors.divider,
            );
          }
          return items[index ~/ 2];
        }),
      ),
    );
  }

  /// 일반 설정 아이템을 빌드합니다.
  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium - 4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 토글이 있는 설정 아이템을 빌드합니다.
  Widget _buildSettingItemWithToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.body),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.divider,
          ),
        ],
      ),
    );
  }

  /// 로그아웃 버튼을 빌드합니다.
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        child: const Text('로그아웃', style: AppTextStyles.bodyBold),
      ),
    );
  }

  /// 버전 정보를 빌드합니다.
  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'MoneyBuddy v1.0.0',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  // ============================================================
  // [F] 유틸리티 메서드
  // ============================================================

  /// 숫자를 통화 형식으로 포맷합니다.
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
