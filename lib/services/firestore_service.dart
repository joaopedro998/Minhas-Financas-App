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
    DateTime transactionDate, {
    bool isPaid = false,
    DateTime? dueDate,
    String? installmentId,
    int? currentInstallment,
    int? totalInstallments,
  }) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'category': category,
      'date': Timestamp.fromDate(transactionDate),
      'isPaid': isPaid,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'installmentId': installmentId,
      'currentInstallment': currentInstallment,
      'totalInstallments': totalInstallments,
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
    DateTime transactionDate, {
    bool isPaid = false,
    DateTime? dueDate,
  }) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'category': category,
      'date': Timestamp.fromDate(transactionDate),
      'isPaid': isPaid,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
    };
    return _db.collection('transactions').doc(docId).update(transactionData);
  }

  Future<void> deleteTransaction(String docId) {
    return _db.collection('transactions').doc(docId).delete();
  }

  // NOVO MÉTODO: Apagar um grupo inteiro de parcelas
  Future<void> deleteInstallmentGroup(String installmentId) async {
    // 1. Encontra todos os documentos com o mesmo ID de parcela
    final querySnapshot = await _db
        .collection('transactions')
        .where('installmentId', isEqualTo: installmentId)
        .get();

    // 2. Cria uma "operação em lote" para apagar tudo de uma vez
    final WriteBatch batch = _db.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Executa a operação em lote
    await batch.commit();
  }

  Future<void> togglePaidStatus(String docId, bool currentStatus) {
    return _db.collection('transactions').doc(docId).update({
      'isPaid': !currentStatus,
    });
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
