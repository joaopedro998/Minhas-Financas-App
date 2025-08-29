import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ATENÇÃO: Verifique se os caminhos dos imports estão corretos!
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
      // StreamBuilder é o widget que vai escutar as mudanças no Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          // Se estiver esperando dados, mostra uma animação de "carregando"
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se não houver nenhuma transação no banco de dados
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação adicionada ainda.\nClique no botão + para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Se houver dados, pegamos a lista de documentos
          final transactions = snapshot.data!.docs;

          // ListView.builder constrói a lista na tela
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              // Converte o dado "cru" do Firestore para o nosso modelo organizado
              final transaction = TransactionModel.fromFirestore(
                transactions[index],
              );

              final isRevenue = transaction.type == 'receita';
              // Formatadores para dinheiro e data
              final formatadorMoeda = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              );
              final formatadorData = DateFormat('dd/MM/yyyy');

              // Card é o "cartãozinho" que vai mostrar cada item
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
                    formatadorData.format(transaction.date.toDate()),
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
