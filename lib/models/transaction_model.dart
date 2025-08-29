import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String type;
  final Timestamp date;
  final String person;
  final String category; // NOVO CAMPO

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.person,
    required this.category, // NOVO CAMPO
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'despesa',
      date: data['date'] ?? Timestamp.now(),
      person: data['person'] ?? 'N/A',
      // Se a transação for antiga e não tiver categoria, definimos como 'Outros'
      category: data['category'] ?? 'Outros', // NOVO CAMPO
    );
  }
}
