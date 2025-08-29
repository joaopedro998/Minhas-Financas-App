// lib/widgets/main_content.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/screens/add_transaction_screen.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/theme_notifier.dart';

class MainContent extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MainContent({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    final FirestoreService firestoreService = FirestoreService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthFormatter = DateFormat('MMMM y', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDarkMode
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getGoalStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Nenhuma meta definida ainda.'),
                        TextButton(
                          onPressed: () =>
                              _showSetGoalDialog(context, firestoreService),
                          child: const Text('DEFINIR UMA META'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final goalData = snapshot.data!.data() as Map<String, dynamic>;
              final valorAtual = (goalData['valorAtual'] ?? 0).toDouble();
              final valorMeta = (goalData['valorMeta'] ?? 1).toDouble();
              final progresso = (valorAtual / valorMeta).clamp(0, 1).toDouble();
              final porcentagem = (progresso * 100).toStringAsFixed(1);
              final formatadorMoeda = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              );
              return Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'META DE POUPANÇA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'nova')
                                _showSetGoalDialog(context, firestoreService);
                              else if (value == 'reiniciar')
                                firestoreService.resetGoalProgress();
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'nova',
                                    child: Text('Definir Nova Meta'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'reiniciar',
                                    child: Text('Reiniciar Progresso'),
                                  ),
                                ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatadorMoeda.format(valorAtual),
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            formatadorMoeda.format(valorMeta),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progresso,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$porcentagem% atingido',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
                  onPressed: onPreviousMonth,
                ),
                Text(
                  monthFormatter.format(selectedMonth).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getTransactionsStreamByMonth(
                selectedMonth,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(
                    child: Text(
                      'Nenhuma transação neste mês.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                final transactionsDocs = snapshot.data!.docs;
                double totalRevenue = 0.0;
                double totalExpenses = 0.0;
                for (var doc in transactionsDocs) {
                  final transaction = TransactionModel.fromFirestore(doc);
                  if (transaction.type == 'receita')
                    totalRevenue += transaction.amount;
                  else if (transaction.type == 'despesa')
                    totalExpenses += transaction.amount;
                }
                final balance = totalRevenue - totalExpenses;
                final formatadorMoeda = NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                );
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              Icons.arrow_upward,
                              "Receitas",
                              formatadorMoeda.format(totalRevenue),
                              Colors.green,
                            ),
                            _buildSummaryItem(
                              Icons.arrow_downward,
                              "Despesas",
                              formatadorMoeda.format(totalExpenses),
                              Colors.red,
                            ),
                            _buildSummaryItem(
                              Icons.account_balance_wallet,
                              "Saldo",
                              formatadorMoeda.format(balance),
                              Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        top: 10.0,
                        bottom: 5.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Histórico do Mês",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactionsDocs.length,
                        itemBuilder: (context, index) {
                          final transaction = TransactionModel.fromFirestore(
                            transactionsDocs[index],
                          );
                          final isRevenue = transaction.type == 'receita';
                          IconData categoryIcon = _getIconForCategory(
                            transaction.category,
                          );
                          return Dismissible(
                            key: Key(transaction.id),
                            onDismissed: (direction) {
                              firestoreService.deleteTransaction(
                                transaction.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${transaction.description} deletado(a).",
                                  ),
                                ),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionScreen(
                                      transaction: transaction,
                                    ),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      (isRevenue ? Colors.green : Colors.red)
                                          .withOpacity(0.1),
                                  child: Icon(
                                    isRevenue
                                        ? Icons.arrow_upward
                                        : categoryIcon,
                                    color: isRevenue
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${transaction.person} • ${transaction.category}',
                                ),
                                trailing: Text(
                                  formatadorMoeda.format(transaction.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isRevenue
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Moradia':
        return Icons.home;
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_car;
      case 'Saúde':
        return Icons.healing;
      case 'Lazer':
        return Icons.sports_esports;
      case 'Educação':
        return Icons.school;
      case 'Vestuário':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  Widget _buildSummaryItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSetGoalDialog(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    final goalFormKey = GlobalKey<FormState>();
    final goalController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Definir Nova Meta"),
          content: Form(
            key: goalFormKey,
            child: TextFormField(
              controller: goalController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Valor da meta (R\$)",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Insira um valor';
                if (double.tryParse(v.replaceAll(',', '.')) == null)
                  return 'Número inválido';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (goalFormKey.currentState!.validate()) {
                  final newGoal = double.parse(
                    goalController.text.replaceAll(',', '.'),
                  );
                  try {
                    await firestoreService.setNewGoal(newGoal);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao salvar meta: $e")),
                    );
                  }
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}
