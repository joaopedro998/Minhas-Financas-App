// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
// AQUI ESTÁ A CORREÇÃO! Adicionamos o import que estava faltando.
import 'package:flutter_application_1/screens/add_transaction_screen.dart';
import 'package:flutter_application_1/screens/reports_screen.dart';
import 'package:flutter_application_1/widgets/main_content.dart';

// Convertemos a HomeScreen para um StatefulWidget para controlar os separadores
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variável que controla qual separador está selecionado (0 = Início, 1 = Relatórios)
  int _selectedIndex = 0;

  // Lista das telas que a nossa barra de navegação irá controlar
  static const List<Widget> _widgetOptions = <Widget>[
    MainContent(), // A nossa antiga tela principal
    ReportsScreen(), // A nossa nova tela de relatórios
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo da tela agora mostra o widget selecionado da lista
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // Adicionamos a barra de navegação inferior
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
        unselectedItemColor:
            Colors.grey, // Uma cor para os itens não selecionados
        onTap: _onItemTapped,
      ),
      // O botão flutuante só aparece na tela inicial (índice 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              ),
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Centraliza o botão
    );
  }
}
