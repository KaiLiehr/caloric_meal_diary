class Ingredient {
  final int? id;
  final String name;
  final String brand;
  final double caloriesPer100;
  final String unit;

  Ingredient({
    this.id,
    required this.name,
    String? brand,
    required this.caloriesPer100,
    required this.unit,
  }) : brand = brand ?? '';


  // Casts Ingredient to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
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
      brand: map['brand'] ?? '',
      caloriesPer100: map['calories_per_100'],
      unit: map['unit'],
    );
  }
}

