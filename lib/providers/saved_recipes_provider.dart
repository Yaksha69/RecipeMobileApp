import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class SavedRecipesProvider with ChangeNotifier {
  final Set<Recipe> _savedRecipes = {};

  Set<Recipe> get savedRecipes => _savedRecipes;

  bool isSaved(Recipe recipe) {
    return _savedRecipes.contains(recipe);
  }

  void toggleSave(Recipe recipe) {
    if (_savedRecipes.contains(recipe)) {
      _savedRecipes.remove(recipe);
    } else {
      _savedRecipes.add(recipe);
    }
    notifyListeners();
  }
} 