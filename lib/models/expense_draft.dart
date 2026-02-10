class ExpenseDraft {
  final String rawText;
  final int amountAbs; // 양수
  final String? title;
  final String? category; // 자동 감지된 카테고리 (null이면 수동 선택)

  const ExpenseDraft({
    required this.rawText,
    required this.amountAbs,
    this.title,
    this.category,
  });
}
