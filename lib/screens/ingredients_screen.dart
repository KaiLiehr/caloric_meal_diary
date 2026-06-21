import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../database/database_helper.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() =>
      _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  List<Ingredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    loadIngredients();
  }

  // Load Ingredients from DB
  Future<void> loadIngredients() async {
    final result =
        await DatabaseHelper.instance.getIngredients();

    setState(() {
      ingredients = result;
    });
  }

  // Dialogue logic used for both add and edit Ingredient
  Future<void> _showIngredientDialog(Ingredient? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '',);
    final caloriesController = TextEditingController(text: existing?.caloriesPer100.toString() ?? '',);
    String selectedUnit = existing?.unit ?? 'g';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Ingredient' : 'Edit Ingredient',),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),

                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories per 100',
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButton<String>(
                    value: selectedUnit,
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final calories =
                    double.tryParse(caloriesController.text);

                if (name.isEmpty || calories == null) return;

                if (existing == null) {
                  // CREATE
                  final ingredient = Ingredient(
                    name: name,
                    caloriesPer100: calories,
                    unit: selectedUnit,
                  );

                  await DatabaseHelper.instance.insertIngredient(ingredient);
                } else {
                  // UPDATE
                  final updated = Ingredient(
                    id: existing.id,
                    name: name,
                    caloriesPer100: calories,
                    unit: selectedUnit,
                  );

                  await DatabaseHelper.instance.updateIngredient(updated);
                }

                await loadIngredients();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
      ),

      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];

          return Dismissible(
            key: Key(ingredient.id.toString()),
            direction: DismissDirection.endToStart,

            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),

            onDismissed: (direction) async {
              final id = ingredient.id;

              if (id != null) {
                await DatabaseHelper.instance.deleteIngredient(id);
                await loadIngredients();
              }
            },

            child: ListTile(
              title: Text(ingredient.name),
              subtitle: Text(
                '${ingredient.caloriesPer100} kcal / 100${ingredient.unit}',
              ),
              onTap: () {
                _showIngredientDialog(ingredient);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIngredientDialog(null),
        child: const Icon(Icons.add),
      ),
    ) ;
  }
}