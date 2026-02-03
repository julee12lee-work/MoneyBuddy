import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final String icon;
  final int amount; // 지출은 음수
  final Timestamp? createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.amount,
    this.createdAt,
  });

  factory Expense.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Expense(
      id: doc.id,
      title: (d['title'] as String?)?.trim().isNotEmpty == true
          ? d['title'] as String
          : (d['category'] as String? ?? '지출'),
      category: d['category'] as String? ?? '기타',
      icon: d['icon'] as String? ?? '🧾',
      amount: (d['amount'] as num?)?.toInt() ?? 0,
      createdAt: d['createdAt'] as Timestamp?,
    );
  }
}
