import 'package:flutter/material.dart';

/// [MainHeader]
/// 사용자의 월간 예산 상태를 요약하여 보여주는 최상단 메인 헤더 위젯입니다.
///
/// 기획 의도:
/// 1. 현재 잔액과 목표 예산을 병기하여 사용자의 소비 현황을 상대적으로 인지시킴.
/// 2. 브랜드 고유 컬러(민트)를 사용하여 재무 서비스의 신뢰감과 청결함을 전달.
/// 3. iPhone 16 Pro 등 최신 기기의 곡률과 노치 영역을 고려한 레이아웃 설계.
class MainHeader extends StatelessWidget {
  final int budgetRemaining; // 남은 예산액
  final int totalBudget; // 전체 목표 예산액

  const MainHeader({
    super.key,
    required this.budgetRemaining,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    // --- [1. 디자인 시스템 정의] ---

    Color brandColor = Theme.of(context).colorScheme.primary;
    Color brandSubColor = Theme.of(
      context,
    ).colorScheme.secondary; // 게이지 배경용 연한 민트

    // --- [2. 수치 연산 로직] ---
    int budgetUsed = totalBudget - budgetRemaining;

    // 게이지 바 및 퍼센트 계산 (0.0 ~ 1.0 범위로 제한하여 레이아웃 깨짐 방지)
    double usedProgress = (budgetUsed / totalBudget).clamp(0.0, 1.0);
    double remainingProgress = (budgetRemaining / totalBudget).clamp(0.0, 1.0);

    // 천 단위 콤마 포맷팅 (정규식 활용)
    String remainingStr = budgetRemaining.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    String totalStr = totalBudget.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return Container(
      // 상단 60px 패딩으로 Dynamic Island 및 노치 간섭 회피
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        // 부드러운 그림자로 카드형 UI의 깊이감(Depth) 형성
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- [3. 헤더 타이틀 & 메뉴] ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 달 남은 예산',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              // 확장성을 고려한 메뉴 버튼 (환경설정 및 예산 편집 진입점)
              IconButton(
                onPressed: () => print("메뉴 열기 클릭"),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF1E293B),
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // --- [4. 메인 예산 수치 표시] ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                remainingStr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '원',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              // 목표 금액 병기를 통해 소비 경각심 유도
              Text(
                '/ $totalStr원',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- [5. 예산 진행바 (Gauge)] ---
          Stack(
            children: [
              // 게이지 배경
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: brandSubColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // 잔여 예산 표시 (남은 금액 비중에 따라 유동적 변화)
              FractionallySizedBox(
                widthFactor: remainingProgress,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [brandColor, brandColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- [6. 하단 상태 지표] ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '소비 ${(usedProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                '잔여 ${(remainingProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
