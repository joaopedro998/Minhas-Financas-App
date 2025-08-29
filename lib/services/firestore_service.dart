import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Pega a instância do Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Funções para Transações ---

  // Adicionar uma nova transação
  Future<void> addTransaction(String description, double amount, String type) {
    // Cria um mapa com os dados
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'date': Timestamp.now(), // Pega a data e hora atual
    };

    // Adiciona o mapa à coleção 'transactions'
    // Se a coleção não existir, o Firestore cria automaticamente
    return _db.collection('transactions').add(transactionData);
  }

  // TODO: Futuramente, adicionaremos aqui as funções para LER e DELETAR transações.
}
