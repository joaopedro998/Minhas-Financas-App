import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/theme_notifier.dart'; // Importe o nosso novo arquivo
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder é um widget que se reconstrói automaticamente
    // sempre que o valor do 'themeNotifier' muda.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        // Agora o MaterialApp usa o 'currentMode' que vem do nosso notifier.
        return MaterialApp(
          title: 'Minhas Finanças',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          // A mágica acontece aqui!
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
