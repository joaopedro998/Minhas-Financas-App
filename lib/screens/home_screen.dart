import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// CORRETO
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
          // --- WIDGET DA META (COM BOTÃO DE EDITAR) ---
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getGoalStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MUDANÇA: Adicionamos um botão ao lado do título
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
                          // BOTÃO PARA ABRIR A JANELA DE DIÁLOGO
                          TextButton.icon(
                            onPressed: () =>
                                _showSetGoalDialog(context, firestoreService),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Nova Meta'),
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
                // ... O código da lista continua exatamente o mesmo de antes ...
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

  // --- NOVA FUNÇÃO: Janela de Diálogo para Definir a Meta ---
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Por favor, insira um número válido';
                }
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
                // Valida o formulário antes de salvar
                if (goalFormKey.currentState!.validate()) {
                  final newGoal = double.parse(
                    goalController.text.replaceAll(',', '.'),
                  );
                  try {
                    // Chama a nova função do nosso serviço
                    await firestoreService.setNewGoal(newGoal);
                    if (context.mounted)
                      Navigator.pop(context); // Fecha a janela
                  } catch (e) {
                    // Mostra um erro se algo der errado
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
