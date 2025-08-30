// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1/screens/add_transaction_screen.dart';
import 'package:flutter_application_1/screens/reports_screen.dart';
import 'package:flutter_application_1/widgets/main_content.dart';
import 'package:flutter_application_1/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthFormatter = DateFormat('MMMM y', 'pt_BR');

    // AQUI ESTÁ A CORREÇÃO!
    // Agora passamos as informações necessárias para os nossos widgets.
    final List<Widget> widgetOptions = <Widget>[
      MainContent(
        selectedMonth: _selectedMonth,
        onPreviousMonth:
            _previousMonth, // Passamos a função de ir para o mês anterior
        onNextMonth: _nextMonth, // Passamos a função de ir para o próximo mês
      ),
      ReportsScreen(selectedMonth: _selectedMonth),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Resumo Mensal' : 'Relatório de Despesas',
        ),
        backgroundColor: _selectedIndex == 0 ? Colors.indigo : Colors.teal,
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
                  onPressed: _previousMonth,
                ),
                Text(
                  monthFormatter.format(_selectedMonth).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(child: widgetOptions.elementAt(_selectedIndex)),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Relatórios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(
                    selectedMonthForNewTransaction: _selectedMonth,
                  ),
                ),
              ),
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
