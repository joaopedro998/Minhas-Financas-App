// lib/screens/reports_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Usamos um AppBar separado para esta tela
      appBar: AppBar(
        title: const Text('Relatórios Financeiros'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove a seta de "voltar"
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Não há dados suficientes para gerar relatórios.'),
            );
          }

          // --- Lógica para Processar os Dados ---
          final transactions = snapshot.data!.docs;
          final Map<String, double> categoryExpenses = {};

          for (var doc in transactions) {
            final transaction = TransactionModel.fromFirestore(doc);
            // Consideramos apenas as despesas
            if (transaction.type == 'despesa') {
              // Somamos os valores para cada categoria
              categoryExpenses.update(
                transaction.category,
                (value) => value + transaction.amount,
                ifAbsent: () => transaction.amount,
              );
            }
          }

          if (categoryExpenses.isEmpty) {
            return const Center(
              child: Text('Nenhuma despesa registada para gerar o gráfico.'),
            );
          }

          // Geramos uma lista de cores para o gráfico
          final List<Color> chartColors = Colors.primaries
              .take(categoryExpenses.length)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Despesas por Categoria',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: List.generate(categoryExpenses.length, (index) {
                        final categoryName = categoryExpenses.keys.elementAt(
                          index,
                        );
                        final categoryValue = categoryExpenses.values.elementAt(
                          index,
                        );
                        final color = chartColors[index % chartColors.length];

                        return PieChartSectionData(
                          color: color,
                          value: categoryValue,
                          title:
                              '${(categoryValue / categoryExpenses.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // --- Legenda do Gráfico ---
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: List.generate(categoryExpenses.length, (index) {
                    final color = chartColors[index % chartColors.length];
                    final categoryName = categoryExpenses.keys.elementAt(index);
                    return Chip(
                      avatar: CircleAvatar(backgroundColor: color, radius: 8),
                      label: Text(categoryName),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
