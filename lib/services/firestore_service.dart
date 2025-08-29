import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Funções para Transações ---

  // Adicionar uma nova transação
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

  // NOVO MÉTODO: Atualizar uma transação existente
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
      'date':
          Timestamp.now(), // Atualizamos a data para a da última modificação
    };
    // Em vez de .add(), usamos .doc(docId).update() para modificar um documento específico
    return _db.collection('transactions').doc(docId).update(transactionData);
  }

  // Obter um "fluxo" de transações em tempo real
  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
