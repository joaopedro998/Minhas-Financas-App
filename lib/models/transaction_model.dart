import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String type;
  final Timestamp date;
  final String person;
  final String category;
  final bool isPaid;
  final Timestamp? dueDate;
  // NOVOS CAMPOS PARA PARCELAMENTO
  final String?
  installmentId; // Um ID único para agrupar todas as parcelas de uma compra
  final int? currentInstallment; // A parcela atual (ex: 1, 2, 3...)
  final int? totalInstallments; // O total de parcelas (ex: 12)

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.person,
    required this.category,
    required this.isPaid,
    this.dueDate,
    this.installmentId,
    this.currentInstallment,
    this.totalInstallments,
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
      category: data['category'] ?? 'Outros',
      isPaid: data['isPaid'] ?? false,
      dueDate: data['dueDate'],
      installmentId: data['installmentId'],
      currentInstallment: data['currentInstallment'],
      totalInstallments: data['totalInstallments'],
    );
  }
}
