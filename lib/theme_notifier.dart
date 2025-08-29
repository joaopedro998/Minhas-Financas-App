import 'package:flutter/material.dart';

// Criamos uma variável global simples que vai guardar o modo do tema.
// ValueNotifier é um tipo especial que notifica "ouvintes" quando seu valor muda.
// Começamos com o tema do sistema por padrão.
final themeNotifier = ValueNotifier(ThemeMode.system);
