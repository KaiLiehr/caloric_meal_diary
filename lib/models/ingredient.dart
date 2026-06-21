class Ingredient { // TODO: Add brand var and restrict unit vals
  final int? id;
  final String name;
  final double caloriesPer100;
  final String unit;

  Ingredient({
    this.id,
    required this.name,
    required this.caloriesPer100,
    required this.unit,
  });

  // Casts Ingredient to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories_per_100': caloriesPer100,
      'unit': unit,
    };
  }

  // Casts Map to Ingredient
  factory Ingredient.fromMap(
    Map<String, dynamic> map,
  ) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      caloriesPer100: map['calories_per_100'],
      unit: map['unit'],
    );
  }
}

