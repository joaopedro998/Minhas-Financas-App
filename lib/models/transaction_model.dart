import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String type; // 'receita' ou 'despesa'
  final Timestamp date;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  // Uma função "fábrica" para criar uma transação a partir de um documento do Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'despesa',
      date: data['date'] ?? Timestamp.now(),
    );
  }
}
