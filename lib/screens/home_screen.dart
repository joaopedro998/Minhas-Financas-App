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
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação adicionada ainda.\nClique no botão + para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

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
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  // AQUI ESTÁ A MUDANÇA: tornamos o item clicável
                  onTap: () {
                    // Navega para a tela de edição, passando a transação que foi clicada.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTransactionScreen(transaction: transaction),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: CircleAvatar(
                    backgroundColor: isRevenue
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isRevenue ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isRevenue
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${transaction.person} • ${formatadorData.format(transaction.date.toDate())}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    formatadorMoeda.format(transaction.amount),
                    style: TextStyle(
                      color: isRevenue
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quando clicamos no +, não passamos nenhuma transação, então ele entra no modo "criar".
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
