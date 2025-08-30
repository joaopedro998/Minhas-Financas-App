# 📊 Minhas Finanças App

![Status](https://img.shields.io/badge/status-concluído-brightgreen)
![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFA000?logo=firebase)
![Licença](https://img.shields.io/badge/licença-MIT-blue)

Um aplicativo completo de **finanças pessoais** desenvolvido em **Flutter** com integração em tempo real ao **Firebase**. Criado para facilitar o controlo de receitas, despesas, metas de poupança e análise de gastos.

---

## ✨ Funcionalidades

- **Gestão Completa (CRUD):** Crie, leia, edite e apague transações.
- **Organização por Mês:** Navegue facilmente entre os meses para ver o histórico financeiro.
- **Painel de Resumo:** Veja o total de receitas, despesas e o saldo do mês selecionado.
- **Categorias de Despesas:** Classifique as suas despesas (Moradia, Alimentação, etc.) com ícones personalizados.
- **Lançamentos por Pessoa:** Associe cada transação a uma pessoa (ex: você, sua namorada).
- **Metas de Poupança:**
    - Defina uma meta de poupança dinâmica.
    - Adicione ou retire dinheiro da meta.
    - Acompanhe o progresso com uma barra visual e percentagem.
    - Reinicie ou defina novas metas a qualquer momento.
- **Relatórios Visuais:**
    - Secção de relatórios com um **gráfico de pizza** interativo.
    - Analise a distribuição das suas despesas por categoria em cada mês.
- **Tema Escuro (Dark Mode):**
    - Adapta-se automaticamente ao tema do sistema.
    - Botão de controlo manual para alternar entre o modo claro e escuro.
- **Identidade Visual:** Nome e ícone do aplicativo totalmente personalizados.
- **Sincronização em Tempo Real:** Todas as informações são salvas e atualizadas instantaneamente com o **Firebase Firestore**.

---

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)**: Framework para desenvolvimento de interfaces de utilizador multiplataforma.
- **[Dart](https://dart.dev/)**: Linguagem de programação.
- **[Firebase Firestore](https://firebase.google.com/products/firestore)**: Banco de dados NoSQL para armazenamento de dados em tempo real.
- **[fl_chart](https://pub.dev/packages/fl_chart)**: Biblioteca para criar gráficos ricos e interativos.
- **[intl](https://pub.dev/packages/intl)**: Pacote para internacionalização e formatação de datas e moedas.
- **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)**: Ferramenta para gerar os ícones do aplicativo.

---

## 🚀 Como Rodar o Projeto

### **Pré-requisitos**

- Ter o **[Flutter SDK](https://flutter.dev/docs/get-started/install)** instalado.
- Um editor de código como o **[VS Code](https://code.visualstudio.com/)**.
- Um emulador Android ou um dispositivo físico.

### **Instalação e Execução**

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/joaopedro998/Minhas-Financas-App](https://github.com/joaopedro998/Minhas-Financas-App)
    cd Minhas-Financas-App
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configure o Firebase:**
    * Crie um projeto no [Console do Firebase](https://console.firebase.google.com/).
    * Use a FlutterFire CLI para conectar a sua aplicação:
        ```bash
        flutterfire configure
        ```
    * No console do Firebase, habilite o **Cloud Firestore** e crie a coleção `metas` com o documento `meta_principal`, conforme o passo a passo que seguimos.

4.  **Rode a aplicação:**
    ```bash
    flutter run
    ```

---

# 📂 Estrutura Final do Projeto

```text
lib/
  ├── main.dart
  ├── theme_notifier.dart
  ├── models/
  │     └── transaction_model.dart
  ├── screens/
  │     ├── add_transaction_screen.dart
  │     ├── home_screen.dart
  │     └── reports_screen.dart
  ├── services/
  │     └── firestore_service.dart
  └── widgets/
        └── main_content.dart


