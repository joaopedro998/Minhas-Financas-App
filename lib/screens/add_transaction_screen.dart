import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // AQUI ESTÁ A CORREÇÃO!
  // As declarações das chaves e controladores precisam estar aqui,
  // como propriedades da classe State.
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();

  String _transactionType = 'despesa';
  final FirestoreService _firestoreService = FirestoreService();
  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final transaction = widget.transaction!;
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toString();
      _personController.text = transaction.person;
      _transactionType = transaction.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGoalOperation =
        _transactionType == 'guardar' || _transactionType == 'usar_meta';

    Color appBarColor;
    if (_transactionType == 'receita') {
      appBarColor = Colors.green;
    } else if (_transactionType == 'despesa') {
      appBarColor = Colors.red;
    } else if (_transactionType == 'guardar') {
      appBarColor = Colors.blue;
    } else {
      // usar_meta
      appBarColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Transação' : 'Adicionar Transação'),
        backgroundColor: appBarColor,
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
                    ),
                    ButtonSegment<String>(
                      value: 'receita',
                      label: Text('Receita'),
                    ),
                    ButtonSegment<String>(
                      value: 'guardar',
                      label: Text('Guardar'),
                    ),
                    ButtonSegment<String>(
                      value: 'usar_meta',
                      label: Text('Usar da Meta'),
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
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Insira uma descrição' : null,
                ),
                const SizedBox(height: 16),
                if (!isGoalOperation)
                  TextFormField(
                    controller: _personController,
                    decoration: const InputDecoration(
                      labelText: 'Pessoa',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Insira uma pessoa' : null,
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Insira um valor';
                    if (double.tryParse(v.replaceAll(',', '.')) == null)
                      return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: appBarColor,
                  ),
                  child: Text(
                    _transactionType == 'guardar'
                        ? 'Guardar na Meta'
                        : (_transactionType == 'usar_meta'
                              ? 'Usar da Meta'
                              : 'Salvar Transação'),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final type = _transactionType;
      final person = _personController.text.isEmpty
          ? 'N/A'
          : _personController.text;

      try {
        if (type == 'guardar') {
          await _firestoreService.addValueToGoal(amount);
        } else if (type == 'usar_meta') {
          await _firestoreService.withdrawValueFromGoal(amount);
          await _firestoreService.addTransaction(
            '$description (Meta)',
            amount,
            'despesa',
            'Meta',
          );
        } else if (_isEditing) {
          final docId = widget.transaction!.id;
          await _firestoreService.updateTransaction(
            docId,
            description,
            amount,
            type,
            person,
          );
        } else {
          await _firestoreService.addTransaction(
            description,
            amount,
            type,
            person,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operação realizada com sucesso!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: $e')));
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
