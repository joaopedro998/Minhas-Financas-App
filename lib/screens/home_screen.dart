import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/screens/add_transaction_screen.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // --- WIDGET DA META ---
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getGoalStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                // ...código para quando não há meta...
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
                              if (value == 'nova') {
                                _showSetGoalDialog(context, firestoreService);
                              } else if (value == 'reiniciar') {
                                firestoreService.resetGoalProgress();
                              }
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
                            // AQUI ESTÁ A CORREÇÃO!
                            // Adicionamos um ícone para ser a parte clicável do botão.
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
          // --- LISTA DE TRANSAÇÕES ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getTransactionsStream(),
              builder: (context, snapshot) {
                // O código da lista não muda
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(
                    child: Text('Nenhuma transação adicionada.'),
                  );
                final transactions = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = TransactionModel.fromFirestore(
                      transactions[index],
                    );
                    final isRevenue = transaction.type == 'receita';
                    final formatadorMoeda = NumberFormat.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    );
                    final formatadorData = DateFormat('dd/MM/yyyy');
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddTransactionScreen(transaction: transaction),
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${transaction.person} • ${formatadorData.format(transaction.date.toDate())}',
                        ),
                        trailing: Text(
                          formatadorMoeda.format(transaction.amount),
                          style: TextStyle(
                            color: isRevenue ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSetGoalDialog(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    // A função do Dialog não muda
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
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Por favor, insira um valor';
                if (double.tryParse(value.replaceAll(',', '.')) == null)
                  return 'Por favor, insira um número válido';
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
