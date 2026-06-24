import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/recipe_template.dart';

class RecipiesScreen extends StatefulWidget {
  const RecipiesScreen({super.key});

  @override
  State<RecipiesScreen> createState() =>
      _RecipiesScreenState();
}

class _RecipiesScreenState
    extends State<RecipiesScreen> {
  List<RecipeTemplate> templates = [];

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  // Calls DB Helper to load all Recipe Templates from the database and updates the state with the retrieved templates
  Future<void> loadTemplates() async {
    final result =
        await DatabaseHelper.instance
            .getRecipeTemplates();

    setState(() {
      templates = result;
    });
  }

  // Displays a dialog to add/update a Recipe Template
  Future<void> _showTemplateDialog(
    RecipeTemplate? existing,
  ) async {
    final nameController = TextEditingController(text: existing?.name ?? '',);
    final noteController = TextEditingController(text: existing?.note ?? '',);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null
                ? 'Add Template'
                : 'Edit Template',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),

              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                ),
                maxLines: 3,
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
                final name = nameController.text.trim();
                final note = noteController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                if (existing == null) {
                  //Create NEW Recipe Template
                  final template = RecipeTemplate(
                    name: name,
                    note: note,
                  );

                  await DatabaseHelper.instance
                      .insertRecipeTemplate(template);
                }else {
                  //Update EXISTING Recipe Template
                  final updated = RecipeTemplate(
                    id: existing.id,
                    name: name,
                    note: note,
                  );

                  await DatabaseHelper.instance
                      .updateRecipeTemplate(updated);
                }
                await loadTemplates();
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
      appBar: AppBar( title: const Text('Recipies'), ),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {

          final template = templates[index];

          return Dismissible(
            key: Key(template.id.toString()),
            direction: DismissDirection.endToStart, 
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding:
                  const EdgeInsets.only(right: 20),

              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) async {
              if (template.id != null) {
                await DatabaseHelper.instance.deleteTemplateWithIngredients(
                  template.id!,
                );
                await loadTemplates();
              }
            },
            child: ListTile(
              title: Text(template.name),

              subtitle: template.note.isNotEmpty
                  ? Text(template.note)
                  : null,

              onTap: () {
                _showTemplateDialog(template);
              },
            ),
          );
        },
      ),
      // Add Template button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTemplateDialog(null);
        },
        child: const Icon(Icons.add),
      ),
    ); 
  }
}

