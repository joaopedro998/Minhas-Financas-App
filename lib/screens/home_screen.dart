import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(child: Text('Aqui ficará nossa lista de transações!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            // Comando para navegar
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
