import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String type; // 'receita' ou 'despesa'
  final Timestamp date;
  final String person; // NOVO CAMPO

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.person, // NOVO CAMPO
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'despesa',
      date: data['date'] ?? Timestamp.now(),
      // Se o campo 'person' não existir no banco (em dados antigos), usa 'N/A'
      person: data['person'] ?? 'N/A', // NOVO CAMPO
    );
  }
}
