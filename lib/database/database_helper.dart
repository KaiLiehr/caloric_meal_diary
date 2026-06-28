import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ingredient.dart';
import '../models/recipe_template.dart';
import '../models/recipe_template_ingredient.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  // one instance sufficient cause offline sqlite app
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  Database? _database;

  // tries to resolve db if not found initialize it
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // Toggle to delete current db and create new one
  static const bool recreateDb = false;
  // init db
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'calorie_tracker.db',
    );

    if (recreateDb) {
      await deleteDatabase(path);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }
  // -------------------------------------------------------------- Database TABLE SCHEMA --------------------------------------------------------------
  // TODO: Add meal_category to meal entries
  Future<void> _createDatabase(Database db, int version,) async {

    await db.execute('''
    CREATE TABLE weight_entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      weight REAL NOT NULL,

      timestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE ingredients(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      brand Text NOT NULL DEFAULT '',
      calories_per_100 REAL NOT NULL,
      unit TEXT NOT NULL,
      note Text NOT NULL DEFAULT '',

      UNIQUE(name, brand)
    )
    ''');

    await db.execute('''
    CREATE TABLE recipe_templates(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      note Text NOT NULL DEFAULT ''
    )
    ''');

    await db.execute('''
    CREATE TABLE recipe_template_ingredients(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      template_id INTEGER NOT NULL,
      ingredient_id INTEGER NOT NULL,
      amount REAL NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE meal_entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      name TEXT NOT NULL,

      timestamp TEXT NOT NULL,

      meal_type TEXT NOT NULL,

      calculated_calories REAL NOT NULL,

      adjusted_calories REAL,

      note Text NOT NULL DEFAULT ''
    )
    ''');

    await db.execute('''
    CREATE TABLE meal_ingredients_snapshot(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      meal_id INTEGER NOT NULL,

      ingredient_name TEXT NOT NULL,

      amount REAL NOT NULL,

      calories_per_100 REAL NOT NULL,

      unit TEXT NOT NULL,

      calories REAL NOT NULL
    )
    ''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {

  }

  // -------------------------------------------------------------- Database CRUD Methods --------------------------------------------------------------
  // Create Ingredient
  Future<int> insertIngredient(
    Ingredient ingredient,
  ) async {
    final db = await database;

    return await db.insert(
      'ingredients',
      ingredient.toMap(),
    );
  }

  // Get all Ingredients
  Future<List<Ingredient>> getIngredients() async {
    final db = await database;

    final result = await db.query(
      'ingredients',
      orderBy: 'name ASC',
    );

    return result
        .map((row) => Ingredient.fromMap(row))
        .toList();
  }

  // Update Ingredient
  Future<int> updateIngredient(
    Ingredient ingredient,
  ) async {
    final db = await database;

    return await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  // Delete Ingredient
  Future<int> deleteIngredient(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Create Recipe Template
  Future<int> insertRecipeTemplate(
    RecipeTemplate recipeTemplate,
  ) async {
    final db = await database;

    return await db.insert(
      'recipe_templates',
      recipeTemplate.toMap(),
    );
  }

  // Get all Recipe Templates
  Future<List<RecipeTemplate>> getRecipeTemplates() async {
    final db = await database;

    final result = await db.query(
      'recipe_templates',
      orderBy: 'name ASC',
    );

    return result
        .map((row) => RecipeTemplate.fromMap(row))
        .toList();
  }

  // Update Recipe Template
  Future<int> updateRecipeTemplate(
    RecipeTemplate recipeTemplate,
  ) async {
    final db = await database;

    return await db.update(
      'recipe_templates',
      recipeTemplate.toMap(),
      where: 'id = ?',
      whereArgs: [recipeTemplate.id],
    );
  }

  // Delete Recipe Template
  Future<int> deleteRecipeTemplate(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'recipe_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Create Recipe Template Ingredient/Add Ingredient to Recipe Template
  Future<int> insertRecipeTemplateIngredient(
    RecipeTemplateIngredient recipeTemplateIngredient,
  ) async {
    final db = await database;

    return await db.insert(
      'recipe_template_ingredients',
      recipeTemplateIngredient.toMap(),
    );
  }

  // Get Ingredients For given Recipe Template
  Future<List<RecipeTemplateIngredient>> getTemplateIngredients(int templateId,) async {
    final db = await database;

    final result = await db.query(
      'recipe_template_ingredients',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );

    return result.map((row) => RecipeTemplateIngredient.fromMap(row)).toList();
  }

  // Update Recipe Template Ingredient
  Future<int> updateRecipeTemplateIngredient(
    RecipeTemplateIngredient recipeTemplateIngredient,
  ) async {
    final db = await database;

    return await db.update(
      'recipe_template_ingredients',
      recipeTemplateIngredient.toMap(),
      where: 'id = ?',
      whereArgs: [recipeTemplateIngredient.id],
    );
  }

  // Delete Recipe Template Ingredient
  Future<int> deleteRecipeTemplateIngredient(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'recipe_template_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletes the given Recipe Template and all its associated Recipe Template Ingredients
  Future<void> deleteTemplateWithIngredients(
    int templateId,
  ) async {
    final db = await database;

    await db.delete(
      'recipe_template_ingredients',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );

    await db.delete(
      'recipe_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );
  }
}