// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Funções para Transações ---

  // VERSÃO CORRIGIDA: Agora aceita o quarto argumento 'person'
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
      'person': person, // E salva o nome da pessoa no banco de dados
      'date': Timestamp.now(),
    };
    return _db.collection('transactions').add(transactionData);
  }

  // Esta função já está correta, não precisa mexer
  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
