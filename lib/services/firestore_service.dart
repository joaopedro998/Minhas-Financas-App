import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference _goalDocument = FirebaseFirestore.instance
      .collection('metas')
      .doc('meta_principal');

  // --- Funções para Transações ---
  Future<void> addTransaction(
    String description,
    double amount,
    String type,
    String person,
    String category,
    DateTime transactionDate,
  ) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'category': category,
      'date': Timestamp.fromDate(transactionDate), // Usa a data recebida
    };
    return _db.collection('transactions').add(transactionData);
  }

  Future<void> updateTransaction(
    String docId,
    String description,
    double amount,
    String type,
    String person,
    String category,
    DateTime transactionDate,
  ) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'category': category,
      'date': Timestamp.fromDate(transactionDate), // Usa a data recebida
    };
    return _db.collection('transactions').doc(docId).update(transactionData);
  }

  Future<void> deleteTransaction(String docId) {
    return _db.collection('transactions').doc(docId).delete();
  }

  Stream<QuerySnapshot> getTransactionsStreamByMonth(DateTime selectedMonth) {
    DateTime startOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    DateTime endOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      1,
    );
    return _db
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: endOfMonth)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // --- Funções para a Meta ---
  Stream<DocumentSnapshot> getGoalStream() {
    return _goalDocument.snapshots();
  }

  Future<void> addValueToGoal(double amount) {
    return _goalDocument.update({'valorAtual': FieldValue.increment(amount)});
  }

  Future<void> setNewGoal(double newGoalValue) {
    return _goalDocument.update({'valorMeta': newGoalValue, 'valorAtual': 0});
  }

  Future<void> withdrawValueFromGoal(double amount) {
    return _goalDocument.update({'valorAtual': FieldValue.increment(-amount)});
  }

  Future<void> resetGoalProgress() {
    return _goalDocument.update({'valorAtual': 0});
  }
}
