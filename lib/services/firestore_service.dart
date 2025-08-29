import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Pega a instância do Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Funções para Transações ---

  // Adicionar uma nova transação
  Future<void> addTransaction(String description, double amount, String type) {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'date': Timestamp.now(), // Pega a data e hora atual
    };
    return _db.collection('transactions').add(transactionData);
  }

  // NOVO MÉTODO: Obter um "fluxo" de transações em tempo real
  Stream<QuerySnapshot> getTransactionsStream() {
    // Retorna um "instantâneo" da coleção 'transactions'
    // Ordenando os documentos pela data, com os mais recentes primeiro.
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
