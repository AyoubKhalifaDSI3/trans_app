import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord")),
      body: const Center(child: Text("Statistiques et résumé des courses ici")),
    );
  }
}
