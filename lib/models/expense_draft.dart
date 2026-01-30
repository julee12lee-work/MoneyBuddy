class ExpenseDraft {
  final String rawText;
  final int amountAbs; // 양수
  final String? title;

  const ExpenseDraft({
    required this.rawText,
    required this.amountAbs,
    this.title,
  });
}
