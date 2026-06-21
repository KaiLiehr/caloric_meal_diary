import 'package:flutter/material.dart';

class RecipiesScreen extends StatelessWidget {
  const RecipiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipies'),
      ),
      body: const Center(
        child: Text(
          'Recipies',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}