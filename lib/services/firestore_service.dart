import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference _goalDocument = FirebaseFirestore.instance
      .collection('metas')
      .doc('meta_principal');

  // --- Funções para Transações (não mudam) ---
  Future<void> addTransaction(
    String description,
    double amount,
    String type,
    String person,
  ) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'date': Timestamp.now(),
    };
    return _db.collection('transactions').add(transactionData);
  }

  Future<void> updateTransaction(
    String docId,
    String description,
    double amount,
    String type,
    String person,
  ) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'person': person,
      'date': Timestamp.now(),
    };
    return _db.collection('transactions').doc(docId).update(transactionData);
  }

  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // --- Funções para a Meta (Atualizadas) ---
  Stream<DocumentSnapshot> getGoalStream() {
    return _goalDocument.snapshots();
  }

  Future<void> addValueToGoal(double amount) {
    return _goalDocument.update({'valorAtual': FieldValue.increment(amount)});
  }

  Future<void> setNewGoal(double newGoalValue) {
    return _goalDocument.update({'valorMeta': newGoalValue, 'valorAtual': 0});
  }

  // NOVO MÉTODO 1: Retirar um valor do total da meta
  Future<void> withdrawValueFromGoal(double amount) {
    // Usamos FieldValue.increment com um número negativo para subtrair
    return _goalDocument.update({'valorAtual': FieldValue.increment(-amount)});
  }

  // NOVO MÉTODO 2: Reiniciar o progresso da meta atual
  Future<void> resetGoalProgress() {
    return _goalDocument.update({'valorAtual': 0});
  }
}
