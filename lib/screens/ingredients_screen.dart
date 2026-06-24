import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

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

  // Dialog logic used for both add and edit Ingredient
  Future<void> _showIngredientDialog(Ingredient? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '',);
    final brandController = TextEditingController(text: existing?.brand ?? '',);
    final caloriesController = TextEditingController(text: existing?.caloriesPer100.toString() ?? '',);
    final noteController = TextEditingController(text: existing?.note ?? '',);
    String selectedUnit = existing?.unit ?? 'g';

    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Ingredient' : 'Edit Ingredient',),
              content: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        onChanged: (_) {
                          if (errorMessage != null) {
                            setDialogState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Pasta',
                        ),
                      ),

                      TextField(
                        controller: brandController,
                        onChanged: (_) {
                          if (errorMessage != null) {
                            setDialogState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Brand(optional)',
                          hintText: 'e.g. Barilla',
                        ),
                      ),

                      TextField(
                        controller: caloriesController,
                        onChanged: (_) {
                          if (errorMessage != null) {
                            setDialogState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories(kcal) per 100',
                          hintText: 'e.g. 463',
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Text(
                            'Unit:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 12),

                          DropdownButton<String>(
                            value: selectedUnit,
                            items: const [
                              DropdownMenuItem(
                                value: 'g',
                                child: Text('g'),
                              ),
                              DropdownMenuItem(
                                value: 'ml',
                                child: Text('ml'),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedUnit = value!;
                              });
                            },
                          ),
                        ],
                      ),

                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note(optional)',
                          hintText: 'e.g. 1 slice=35g',
                        ),
                      ),

                      if (errorMessage != null) Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
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
                    final brand = brandController.text.trim();
                    final calories =
                        double.tryParse(caloriesController.text);
                    final note = noteController.text.trim();

                    if (name.isEmpty) {
                      setDialogState(() {
                        errorMessage =
                            'Please enter a valid name.';
                      });
                      return;
                    }

                    if (calories == null) {
                      setDialogState(() {
                        errorMessage =
                            'Please enter a valid calories number.';
                      });
                      return;
                    }

                    try{
                      if (existing == null) {
                        // CREATE NEW
                        final ingredient = Ingredient(
                          name: name,
                          brand: brand,
                          caloriesPer100: calories,
                          unit: selectedUnit,
                          note: note,
                        );

                        await DatabaseHelper.instance.insertIngredient(ingredient);
                      } else {
                        // UPDATE
                        final updated = Ingredient(
                          id: existing.id,
                          name: name,
                          brand: brand,
                          caloriesPer100: calories,
                          unit: selectedUnit,
                          note: note,
                        );

                        await DatabaseHelper.instance.updateIngredient(updated);
                      }

                      await loadIngredients();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      String message = 'Failed to save ingredient.';

                      if (e is DatabaseException) {
                        if (e.isUniqueConstraintError()) {
                          message =
                              'An ingredient with this combination of name and brand already exists.';
                        }
                      }

                      setDialogState(() {
                        errorMessage = message;
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
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
              title: Text(ingredient.name + (ingredient.brand.isNotEmpty ? ' (${ingredient.brand})' : ''),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ingredient.caloriesPer100} kcal / 100${ingredient.unit}',
                  ),

                  if (ingredient.note.isNotEmpty)
                    Text(
                      'Note: ${ingredient.note}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
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