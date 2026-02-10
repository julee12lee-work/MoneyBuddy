import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] BudgetSettingDialog - 예산 설정 팝업
/// [Author] 이준수 (PM & Design)
/// [Date] 2026-02-03
/// [Description]
/// 월 예산과 기준일(월급일)을 설정하는 팝업 다이얼로그입니다.
/// 사이드 메뉴 또는 메인 헤더의 예산 금액을 탭하면 표시됩니다.

class BudgetSettingDialog extends StatefulWidget {
  final int currentBudget;
  final int currentStartDay;
  final Function(int budget, int startDay) onSave;

  const BudgetSettingDialog({
    super.key,
    required this.currentBudget,
    required this.currentStartDay,
    required this.onSave,
  });

  /// 다이얼로그를 표시하는 헬퍼 메서드
  static Future<void> show({
    required BuildContext context,
    required int currentBudget,
    required int currentStartDay,
    required Function(int budget, int startDay) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BudgetSettingDialog(
        currentBudget: currentBudget,
        currentStartDay: currentStartDay,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BudgetSettingDialog> createState() => _BudgetSettingDialogState();
}

class _BudgetSettingDialogState extends State<BudgetSettingDialog> {
  late TextEditingController _budgetController;
  late int _selectedStartDay;
  final _formKey = GlobalKey<FormState>();
  final _formatter = NumberFormat('###,###,###');

  // 기준일 옵션 (1일 ~ 28일)
  static const List<int> _dayOptions = [1, 5, 10, 15, 20, 25, 28];

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: _formatter.format(widget.currentBudget),
    );
    _selectedStartDay = widget.currentStartDay;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  int _parseBudget(String text) {
    // 콤마 제거 후 숫자로 변환
    final cleaned = text.replaceAll(',', '').replaceAll(' ', '');
    return int.tryParse(cleaned) ?? 0;
  }

  void _formatBudgetInput(String value) {
    final number = _parseBudget(value);
    if (number > 0) {
      final formatted = _formatter.format(number);
      _budgetController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final budget = _parseBudget(_budgetController.text);
      widget.onSave(budget, _selectedStartDay);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('예산 설정', style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: 24),

              // 월 예산 입력
              const Text(
                '월 예산',
                style: AppTextStyles.bodyBold,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: _formatBudgetInput,
                decoration: InputDecoration(
                  hintText: '예: 1,000,000',
                  suffixText: '원',
                  suffixStyle: AppTextStyles.body,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: AppTextStyles.h4,
                validator: (value) {
                  final budget = _parseBudget(value ?? '');
                  if (budget <= 0) {
                    return '예산을 입력해주세요';
                  }
                  if (budget < 10000) {
                    return '최소 10,000원 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 기준일 선택
              const Text(
                '기준일 (월급일)',
                style: AppTextStyles.bodyBold,
              ),
              const SizedBox(height: 4),
              Text(
                '예산이 리셋되는 날짜를 선택하세요',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dayOptions.map((day) {
                  final isSelected = _selectedStartDay == day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStartDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '$day일',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
