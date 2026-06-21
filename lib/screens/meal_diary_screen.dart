import 'package:flutter/material.dart';

class MealDiaryScreen extends StatelessWidget {
  const MealDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
      ),
      body: const Center(
        child: Text(
          'Meals',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}