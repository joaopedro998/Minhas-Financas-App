// lib/screens/add_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final DateTime? selectedMonthForNewTransaction;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.selectedMonthForNewTransaction,
  });
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _installmentsController = TextEditingController();

  String _transactionType = 'despesa';
  String? _selectedCategory;
  bool _isPaid = false;
  DateTime? _dueDate;
  final FirestoreService _firestoreService = FirestoreService();
  bool get _isEditing => widget.transaction != null;
  final List<String> _categories = [
    'Moradia',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Educação',
    'Vestuário',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      // Ao editar, limpamos a descrição da parcela para mostrar o nome original
      _descriptionController.text = t.description.replaceAll(
        RegExp(r'\s\(\d+/\d+\)$'),
        '',
      );
      _amountController.text = t.amount.toString();
      _personController.text = t.person;
      _transactionType = t.type;
      _isPaid = t.isPaid;
      _dueDate = t.dueDate?.toDate();
      if (t.type == 'despesa') {
        _selectedCategory = t.category;
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = _transactionType == 'despesa';
    final bool showPersonField = ![
      'guardar',
      'usar_meta',
    ].contains(_transactionType);
    Color appBarColor;
    if (_transactionType == 'receita')
      appBarColor = Colors.green;
    else if (_transactionType == 'despesa')
      appBarColor = Colors.red;
    else if (_transactionType == 'guardar')
      appBarColor = Colors.blue;
    else
      appBarColor = Colors.orange;

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

                if (isExpense) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Selecione uma Categoria'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedCategory = newValue),
                    validator: (value) =>
                        value == null ? 'Selecione uma categoria' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(
                      text: _dueDate == null
                          ? ''
                          : DateFormat('dd/MM/yyyy').format(_dueDate!),
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data de Vencimento (Opcional)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDueDate(context),
                      ),
                    ),
                    onTap: () => _selectDueDate(context),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Esta dívida já foi paga?'),
                    value: _isPaid,
                    onChanged: (bool value) => setState(() => _isPaid = value),
                    secondary: Icon(
                      _isPaid ? Icons.check_circle : Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // O campo de parcelas não aparece no modo de edição para evitar complexidade
                  if (!_isEditing) ...[
                    TextFormField(
                      controller: _installmentsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nº de Parcelas (deixe em branco se for 1)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                if (showPersonField) ...[
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
                ],

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
      final category = type == 'despesa' ? _selectedCategory! : 'N/A';
      final int installments = int.tryParse(_installmentsController.text) ?? 1;

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
            'Outros',
            DateTime.now(),
          );
        } else if (_isEditing) {
          final docId = widget.transaction!.id;
          await _firestoreService.updateTransaction(
            docId,
            description,
            amount,
            type,
            person,
            category,
            widget.transaction!.date.toDate(),
            isPaid: _isPaid,
            dueDate: _dueDate,
          );
        } else {
          final installmentId = installments > 1 ? const Uuid().v4() : null;

          for (int i = 0; i < installments; i++) {
            final now = DateTime.now();
            final selectedMonthBase =
                widget.selectedMonthForNewTransaction ?? now;

            final transactionDate = DateTime(
              selectedMonthBase.year,
              selectedMonthBase.month + i,
              now.day > 28 ? 28 : now.day,
            );
            final dueDateForInstallment = _dueDate != null
                ? DateTime(_dueDate!.year, _dueDate!.month + i, _dueDate!.day)
                : null;

            final installmentDescription = installments > 1
                ? '$description (${i + 1}/$installments)'
                : description;

            await _firestoreService.addTransaction(
              installmentDescription,
              amount,
              type,
              person,
              category,
              transactionDate,
              isPaid: _isPaid,
              dueDate: dueDateForInstallment,
              installmentId: installmentId,
              currentInstallment: i + 1,
              totalInstallments: installments,
            );

            if (type == 'despesa' &&
                !_isPaid &&
                dueDateForInstallment != null) {
              final notificationDate = DateTime(
                dueDateForInstallment.year,
                dueDateForInstallment.month,
                dueDateForInstallment.day,
                9,
              );
              if (notificationDate.isAfter(DateTime.now())) {
                await notificationService.scheduleNotification(
                  id:
                      transactionDate.millisecondsSinceEpoch.remainder(100000) +
                      i,
                  title: 'Conta a Vencer!',
                  body:
                      'Não se esqueça de pagar "$installmentDescription" hoje!',
                  scheduledDate: notificationDate,
                );
              }
            }
          }
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
    _installmentsController.dispose();
    super.dispose();
  }
}
