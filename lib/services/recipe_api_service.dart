import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // Cache for storing fetched recipes
  static final Map<String, Recipe> _recipeCache = {};
  static final Map<String, List<String>> _categoriesCache = {};

  static Future<List<Recipe>> fetchPopularRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      return meals.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  static Future<List<Recipe>> fetchFilipinoRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=Filipino'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      List<Recipe> recipes = [];
      for (final meal in meals) {
        final id = meal['idMeal'];
        if (id != null) {
          final detail = await fetchRecipeById(id);
          if (detail != null) recipes.add(detail);
        }
      }
      return recipes;
    } else {
      throw Exception('Failed to load Filipino recipes');
    }
  }

  static Future<Recipe?> fetchRecipeById(String id) async {
    // Check cache first
    if (_recipeCache.containsKey(id)) {
      return _recipeCache[id];
    }
    
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      if (meals.isNotEmpty) {
        final recipe = Recipe.fromJson(meals[0]);
        // Cache the recipe
        _recipeCache[id] = recipe;
        return recipe;
      }
    }
    return null;
  }

  static Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['categories'] ?? [];
      return categories.map<String>((cat) => cat['strCategory'] as String).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<String>> fetchCategoriesForArea(String area) async {
    // Check cache first
    if (_categoriesCache.containsKey(area)) {
      return _categoriesCache[area]!;
    }
    
    final recipes = await fetchByArea(area);
    final Set<String> categories = {};
    for (final recipe in recipes) {
      if (recipe.category != null && recipe.category!.isNotEmpty) {
        categories.add(recipe.category!);
      }
    }
    final result = categories.toList()..sort();
    // Cache the result
    _categoriesCache[area] = result;
    return result;
  }

  static Future<List<String>> fetchCategoriesForAllAreas() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['categories'] ?? [];
      return categories.map<String>((cat) => cat['strCategory'] as String).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Recipe>> searchByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$name'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      return meals.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search recipes by name');
    }
  }

  static Future<List<Recipe>> searchByIngredient(String ingredient) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      
      // Make parallel API calls instead of sequential
      final List<Future<Recipe?>> futures = meals.map((meal) {
        final id = meal['idMeal'];
        if (id != null) {
          return fetchRecipeById(id);
        }
        return Future.value(null);
      }).toList();
      
      final results = await Future.wait(futures);
      return results.where((recipe) => recipe != null).cast<Recipe>().toList();
    } else {
      throw Exception('Failed to search recipes by ingredient');
    }
  }

  static Future<List<Recipe>> fetchByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      
      // Make parallel API calls instead of sequential
      final List<Future<Recipe?>> futures = meals.map((meal) {
        final id = meal['idMeal'];
        if (id != null) {
          return fetchRecipeById(id);
        }
        return Future.value(null);
      }).toList();
      
      final results = await Future.wait(futures);
      return results.where((recipe) => recipe != null).cast<Recipe>().toList();
    } else {
      throw Exception('Failed to fetch recipes by category');
    }
  }

  static Future<List<Recipe>> fetchFilipinoByCategory(String category) async {
    // Get all Filipino meals
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=Filipino'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      List<Recipe> recipes = [];
      for (final meal in meals) {
        final id = meal['idMeal'];
        if (id != null) {
          final detail = await fetchRecipeById(id);
          if (detail != null && detail.toJson()['category'] == category) recipes.add(detail);
        }
      }
      return recipes;
    } else {
      throw Exception('Failed to load Filipino recipes by category');
    }
  }

  static Future<List<String>> fetchAreas() async {
    final response = await http.get(Uri.parse('$baseUrl/list.php?a=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List areas = data['meals'] ?? [];
      return areas.map<String>((area) => area['strArea'] as String).toList();
    } else {
      throw Exception('Failed to load areas');
    }
  }

  static Future<List<Recipe>> fetchByArea(String area) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=$area'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'] ?? [];
      
      // Make parallel API calls instead of sequential
      final List<Future<Recipe?>> futures = meals.map((meal) {
        final id = meal['idMeal'];
        if (id != null) {
          return fetchRecipeById(id);
        }
        return Future.value(null);
      }).toList();
      
      final results = await Future.wait(futures);
      return results.where((recipe) => recipe != null).cast<Recipe>().toList();
    } else {
      throw Exception('Failed to load recipes by area');
    }
  }

  static Future<List<Recipe>> fetchByAreaAndCategory(String area, String category) async {
    final allAreaRecipes = await fetchByArea(area);
    return allAreaRecipes.where((recipe) => recipe.category == category).toList();
  }

  static Future<List<Recipe>> searchByNameInArea(String name, String area) async {
    final allAreaRecipes = await fetchByArea(area);
    return allAreaRecipes.where((recipe) => 
      recipe.name.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }

  static Future<List<Recipe>> searchByIngredientInArea(String ingredient, String area) async {
    final allAreaRecipes = await fetchByArea(area);
    return allAreaRecipes.where((recipe) => 
      recipe.ingredients.any((ing) => 
        ing.toLowerCase().contains(ingredient.toLowerCase())
      )
    ).toList();
  }
} 