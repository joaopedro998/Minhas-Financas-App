import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

// A "Carcaça" do Widget agora pode receber uma transação para editar.
class AddTransactionScreen extends StatefulWidget {
  // A transação é opcional. Se for nula, estamos criando. Se não, estamos editando.
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();

  String _transactionType = 'despesa';
  final FirestoreService _firestoreService = FirestoreService();

  // Variável para saber se estamos no modo de edição.
  bool get _isEditing => widget.transaction != null;

  // O método initState() é chamado UMA VEZ quando a tela é criada.
  // É o lugar perfeito para preencher o formulário se estivermos editando.
  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // Se estamos editando, preenchemos os campos com os dados da transação existente.
      final transaction = widget.transaction!;
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toString();
      _personController.text = transaction.person;
      _transactionType = transaction.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O título da tela agora é dinâmico.
        title: Text(_isEditing ? 'Editar Transação' : 'Adicionar Transação'),
        backgroundColor: _transactionType == 'receita'
            ? Colors.green
            : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    setState(() {
                      _transactionType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 20),
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

  // A lógica de salvar agora é mais inteligente.
  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final type = _transactionType;
      final person = _personController.text;

      try {
        if (_isEditing) {
          // Se estamos editando, chamamos o método de ATUALIZAR.
          final docId = widget.transaction!.id;
          await _firestoreService.updateTransaction(
            docId,
            description,
            amount,
            type,
            person,
          );
        } else {
          // Se não, chamamos o método de ADICIONAR, como antes.
          await _firestoreService.addTransaction(
            description,
            amount,
            type,
            person,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transação salva com sucesso!')),
          );
          Navigator.pop(context); // Volta para a tela anterior
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _personController.dispose();
    super.dispose();
  }
}
