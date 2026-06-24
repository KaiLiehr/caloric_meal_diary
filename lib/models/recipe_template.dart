class RecipeTemplate {
  final int? id;
  final String name;
  final String note;

  RecipeTemplate({
    this.id,
    required this.name,
    String? note,
  }) : note = note ?? '';


  // Casts RecipeTemplate to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'note': note,
    };
  }

  // Casts Map to RecipeTemplate
  factory RecipeTemplate.fromMap(
    Map<String, dynamic> map,
  ) {
    return RecipeTemplate(
      id: map['id'],
      name: map['name'],
      note: map['note'] ?? '',
    );
  }
}

