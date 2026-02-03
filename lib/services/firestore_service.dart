import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _db.collection('users').doc(uid);

  static CollectionReference<Map<String, dynamic>> expensesCol(String uid) =>
      userDoc(uid).collection('expenses');

  static Future<void> ensureUserDocument(User user) async {
    final ref = userDoc(user.uid);

    await ref.set(
      {
        'uid': user.uid,
        'displayName': user.displayName ?? (user.isAnonymous ? '게스트' : null),
        'email': user.email,
        'photoURL': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final snap = await ref.get();
    if (!snap.data()!.containsKey('createdAt')) {
      await ref.set(
        {'createdAt': FieldValue.serverTimestamp(), 'personaIndex': 0},
        SetOptions(merge: true),
      );
    }
  }

  static Future<void> setPersonaIndex(String uid, int personaIndex) async {
    await userDoc(uid).set(
      {
        'personaIndex': personaIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static String iconForCategory(String category) {
    switch (category) {
      case '카페':
        return '☕';
      case '식비':
        return '🍽️';
      case '교통':
        return '🚗';
      case '쇼핑':
        return '🛍️';
      case '편의점':
        return '🏪';
      case '의료':
        return '💊';
      case '여가':
        return '🎮';
      default:
        return '🧾';
    }
  }

  static Stream<List<Expense>> watchThisMonthExpenses(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final q = expensesCol(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true);

    return q.snapshots().map((snap) {
      return snap.docs.map((d) => Expense.fromDoc(d)).toList();
    });
  }

  static Future<void> addExpense({
    required String uid,
    required String title,
    required String category,
    required int amountAbs, // 양수로 받기
  }) async {
    final doc = expensesCol(uid).doc();
    final now = Timestamp.now();

    await doc.set({
      'title': title,
      'category': category,
      'icon': iconForCategory(category),
      'amount': -amountAbs, // ✅ 지출은 음수 저장 (FeedCard와 동일 규칙)
      'createdAt': now, // 즉시 정렬/필터용
      'serverCreatedAt': FieldValue.serverTimestamp(),
      'updatedAt': now,
      'serverUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteExpense({
    required String uid,
    required String expenseId,
  }) async {
    await expensesCol(uid).doc(expenseId).delete();
  }
}
