import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Referência para o documento da meta
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

  // --- Funções para a Meta ---

  // Obter um "fluxo" de dados da meta em tempo real
  Stream<DocumentSnapshot> getGoalStream() {
    return _goalDocument.snapshots();
  }

  // Adicionar um valor ao total da meta
  Future<void> addValueToGoal(double amount) {
    return _goalDocument.update({'valorAtual': FieldValue.increment(amount)});
  }

  // NOVO MÉTODO: Definir uma nova meta e zerar o progresso
  Future<void> setNewGoal(double newGoalValue) {
    return _goalDocument.update({
      'valorMeta': newGoalValue,
      'valorAtual': 0, // Zera o progresso atual ao definir uma nova meta
    });
  }
}
