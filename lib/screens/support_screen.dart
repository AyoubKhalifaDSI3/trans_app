import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assistance & Support")),
      body: const Center(child: Text("FAQ et contact du support ici")),
    );
  }
}
