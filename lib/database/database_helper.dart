import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ingredient.dart';

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

  // init db
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'calorie_tracker.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  // -------------------------------------------------------------- Database TABLE SCHEMA --------------------------------------------------------------
  // TODO: Add meal_category to meal entries, Add brand to ingredient, restrict unit for ingredient
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
      calories_per_100 REAL NOT NULL,
      unit TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE recipe_templates(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
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

      adjusted_calories REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE meal_ingredients_snapshot(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      meal_id INTEGER NOT NULL,

      ingredient_name TEXT NOT NULL,

      amount REAL NOT NULL,

      calories_per_100 REAL NOT NULL,

      calories REAL NOT NULL
    )
    ''');
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
}