class RecipeTemplateIngredient {
  final int? id;
  final int templateId;
  final int ingredientId;
  final double amount;

  RecipeTemplateIngredient({
    this.id,
    required this.templateId,
    required this.ingredientId,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'ingredient_id': ingredientId,
      'amount': amount,
    };
  }

  factory RecipeTemplateIngredient.fromMap(
    Map<String, dynamic> map,
  ) {
    return RecipeTemplateIngredient(
      id: map['id'],
      templateId: map['template_id'],
      ingredientId: map['ingredient_id'],
      amount: map['amount'],
    );
  }
}