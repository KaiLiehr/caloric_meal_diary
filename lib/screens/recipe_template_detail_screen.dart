import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/recipe_template.dart';
import '../models/recipe_template_ingredient.dart';
import '../models/ingredient.dart';

class RecipeTemplateDetailScreen extends StatefulWidget {
  final RecipeTemplate template;

  const RecipeTemplateDetailScreen({
    super.key,
    required this.template,
  });

  @override
  State<RecipeTemplateDetailScreen> createState() => _RecipeTemplateDetailScreenState();
}

class _RecipeTemplateDetailScreenState extends State<RecipeTemplateDetailScreen> {
  List<RecipeTemplateIngredient> templateIngredients = [];
  List<Ingredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  Future<void> loadData() async {
    await loadIngredients();
    await loadTemplateIngredients();
  }

  // Get Ingredients For given Recipe Template
  Future<void> loadTemplateIngredients() async {
    final result =
        await DatabaseHelper.instance
            .getTemplateIngredients(
              widget.template.id!,
            );

    setState(() {
      templateIngredients = result;
    });
  }

  // Gets all ingredients to offer as options for given Recipe Template Ingredients
  Future<void> loadIngredients() async {
    ingredients =
        await DatabaseHelper.instance
            .getIngredients();
  }

  Future<void> _showAddIngredientDialog() async {
    Ingredient? selectedIngredient;
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Ingredient'),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<Ingredient>(
                    isExpanded: true,
                    hint: const Text('Select Ingredient'),
                    value: selectedIngredient,

                    items: ingredients.map((ingredient) {
                      return DropdownMenuItem(
                        value: ingredient,
                        child: Text(ingredient.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setDialogState(() {
                        selectedIngredient = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text);

                    if (selectedIngredient == null ||
                        amount == null) {
                      return;
                    }

                    final item =
                        RecipeTemplateIngredient(
                      templateId: widget.template.id!,
                      ingredientId:
                          selectedIngredient!.id!,
                      amount: amount,
                    );

                    await DatabaseHelper.instance
                        .insertRecipeTemplateIngredient(item);

                    await loadTemplateIngredients();

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
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
      ),

      body: ListView.builder(
        itemCount: templateIngredients.length,
        itemBuilder: (context, index) {
          final item = templateIngredients[index];

          return ListTile(
            title: Text(
              'Ingredient ID ${item.ingredientId}',
            ),
            subtitle: Text(
              '${item.amount} ${item.amount == 1 ? "" : ""}',
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIngredientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}