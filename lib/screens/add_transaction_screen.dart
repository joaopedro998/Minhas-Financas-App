// lib/screens/add_transaction_screen.dart

import 'package:flutter/material.dart';
// Import corrigido com o nome do seu projeto
import 'package:flutter_application_1/services/firestore_service.dart';

// --- PARTE 1: A "Carcaça" do Widget ---
// Esta é a parte fixa.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  // Este é o método que estava faltando.
  // Ele diz ao Flutter como criar a parte dinâmica (o State) deste widget.
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

// --- PARTE 2: O "Motor" do Widget ---
// Esta é a parte dinâmica, que guarda as informações e constrói a tela.
class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Chave para identificar e validar nosso formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para pegar os valores dos campos de texto
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController =
      TextEditingController(); // Controlador para o campo "Pessoa"

  // Variável para guardar o tipo da transação (receita ou despesa)
  String _transactionType = 'despesa'; // Começa como despesa por padrão

  // Instância do nosso serviço do Firestore
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Transação'),
        // A cor da barra muda dependendo do tipo da transação
        backgroundColor: _transactionType == 'receita'
            ? Colors.green
            : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associando a chave ao formulário
          // Usamos um SingleChildScrollView para a tela não quebrar quando o teclado aparecer
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Seletor de Tipo (Receita/Despesa) ---
                SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'despesa',
                      label: Text('Despesa'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment<String>(
                      value: 'receita',
                      label: Text('Receita'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    // Atualiza a tela quando o usuário troca a seleção
                    setState(() {
                      _transactionType = newSelection.first;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // --- Campo de Descrição ---
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- NOVO CAMPO: Pessoa ---
                TextFormField(
                  controller: _personController,
                  decoration: const InputDecoration(
                    labelText: 'Pessoa (Ex: João, Maria)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome da pessoa';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- Campo de Valor ---
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
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

                const SizedBox(height: 24),

                // --- Botão de Salvar ---
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _transactionType == 'receita'
                        ? Colors.green
                        : Colors.red,
                  ),
                  child: const Text(
                    'Salvar Transação',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função chamada quando o botão "Salvar" é pressionado
  void _saveTransaction() async {
    // 1. Validar o formulário para ver se não há erros
    if (_formKey.currentState!.validate()) {
      // 2. Pegar os valores dos campos
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final type = _transactionType;
      final person = _personController.text; // Pegando o valor do novo campo

      // 3. Chamar o serviço do Firestore para salvar os dados
      try {
        // Agora passamos o nome da pessoa para a função de salvar
        await _firestoreService.addTransaction(
          description,
          amount,
          type,
          person,
        );

        // 4. Mostrar mensagem de sucesso e fechar a tela
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transação salva com sucesso!')),
          );
          Navigator.pop(context); // Volta para a tela anterior
        }
      } catch (e) {
        // 5. Se der erro, mostrar uma mensagem de erro
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
        }
      }
    }
  }

  // Limpa os controladores quando o widget é descartado para evitar vazamento de memória
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _personController.dispose(); // Limpando o novo controlador
    super.dispose();
  }
}
