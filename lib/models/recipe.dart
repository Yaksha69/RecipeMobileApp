class Recipe {
  final String name;
  final List<String> ingredients;
  final String instructions;
  final String imageUrl;
  final String? category;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // TheMealDB uses strMeal, strInstructions, strMealThumb, strIngredient1...strIngredient20
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
      }
    }
    return Recipe(
      name: json['strMeal'] ?? '',
      ingredients: ingredients,
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'ingredients': ingredients,
    'instructions': instructions,
    'imageUrl': imageUrl,
    'category': category,
  };

  bool canMakeWithIngredients(List<String> availableIngredients) {
    // Return true if at least one ingredient matches
    return ingredients.any((ingredient) => 
      availableIngredients.any((available) => 
        _isIngredientMatch(available, ingredient)));
  }

  bool _isIngredientMatch(String available, String recipeIngredient) {
    // Convert both strings to lowercase for case-insensitive comparison
    final availableLower = available.toLowerCase();
    final recipeLower = recipeIngredient.toLowerCase();

    // Check if the available ingredient contains the recipe ingredient
    // or if the recipe ingredient contains the available ingredient
    return availableLower.contains(recipeLower) || 
           recipeLower.contains(availableLower);
  }
} 