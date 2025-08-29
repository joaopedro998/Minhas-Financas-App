// lib/screens/reports_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedMonth = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthFormatter = DateFormat('MMMM y', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Financeiros'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  monthFormatter.format(_selectedMonth).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getTransactionsStreamByMonth(
                _selectedMonth,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Não há dados para este mês.'),
                  );
                }

                final transactions = snapshot.data!.docs;
                final Map<String, double> categoryExpenses = {};

                for (var doc in transactions) {
                  final transaction = TransactionModel.fromFirestore(doc);
                  if (transaction.type == 'despesa') {
                    categoryExpenses.update(
                      transaction.category,
                      (value) => value + transaction.amount,
                      ifAbsent: () => transaction.amount,
                    );
                  }
                }

                if (categoryExpenses.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma despesa registada neste mês.'),
                  );
                }

                final List<Color> chartColors = Colors.primaries.reversed
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Despesas por Categoria (Mês)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: List.generate(categoryExpenses.length, (
                              index,
                            ) {
                              // AQUI ESTÁ A CORREÇÃO!
                              // A variável 'categoryName' foi removida porque não era usada aqui.
                              final categoryValue = categoryExpenses.values
                                  .elementAt(index);
                              final color =
                                  chartColors[index % chartColors.length];
                              final totalExpenses = categoryExpenses.values
                                  .reduce((a, b) => a + b);

                              return PieChartSectionData(
                                color: color,
                                value: categoryValue,
                                title:
                                    '${(categoryValue / totalExpenses * 100).toStringAsFixed(0)}%',
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
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(categoryExpenses.length, (
                          index,
                        ) {
                          final color = chartColors[index % chartColors.length];
                          // Aqui a variável 'categoryName' é necessária e continua a ser usada
                          final categoryName = categoryExpenses.keys.elementAt(
                            index,
                          );
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: color,
                              radius: 8,
                            ),
                            label: Text(categoryName),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
