import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyB9SZh22-lm4XfQOHACVkICPrc25xEsvGk';
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getRecipeSuggestions(List<String> ingredients) async {
    try {
      final prompt = '''
You are a helpful cooking assistant. Given these ingredients: ${ingredients.join(', ')}

Please suggest 3 simple recipes that can be made with these ingredients. 
For each recipe, provide:
1. Recipe name
2. List of ingredients needed
3. Simple step-by-step instructions
4. Cooking time (if applicable)

If the ingredients are not sufficient for a complete recipe, suggest what additional ingredients might be needed.

Format your response in a clear, easy-to-read manner.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate recipe suggestions.';
    } catch (e) {
      print('AI Service Error: $e');
      if (e.toString().contains('503')) {
        return 'AI service is temporarily unavailable. Please try again later.';
      } else if (e.toString().contains('403')) {
        return 'API key error. Please check configuration.';
      } else if (e.toString().contains('401')) {
        return 'Unauthorized access. Please check API key.';
      }
      return 'Unable to connect to AI service. Error: $e';
    }
  }

  Future<String> getAlternativeIngredients(String ingredient, {String? recipeName}) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
    try {
      String prompt;
      
      if (recipeName != null) {
        // Recipe-specific alternatives
        prompt = '''
You are a professional cooking assistant. For the recipe "$recipeName", the ingredient "$ingredient" is needed.

Please provide recipe-specific alternatives for "$ingredient" that would work well in "$recipeName":

- 3-5 alternative ingredients that can substitute for "$ingredient" in "$recipeName"
- Quantity adjustments: how much to use compared to the original ingredient
- Cooking method changes: any adjustments needed for this specific recipe
- Taste impact: how it will affect the flavor of "$recipeName"
- Best alternatives: rank them by how well they work in this recipe

Important rules:
- Use only '-' or numbered lists for bullets. Never use '*', '•', or other symbols.
- Use clear section headers and consistent indentation.
- Format your response in a professional, clean, and concise way.
- Avoid unnecessary repetition and keep the output easy to scan.
- Do not use Markdown formatting or asterisks.

Format your response in a clear, easy-to-read manner with bullet points and section headers.
''';
      } else {
        // General alternatives
        prompt = '''
You are a professional cooking assistant. For the ingredient "$ingredient", please provide:

- 3-5 alternative ingredients that can be used as substitutes
- When to use each alternative: explain the best situations for each substitute
- Quantity adjustments: how much to use compared to the original ingredient
- Cooking method changes: any adjustments needed in preparation or cooking
- Taste differences: how the flavor might change
- Recipe compatibility: which types of dishes work best with each alternative

Important rules:
- Use only '-' or numbered lists for bullets. Never use '*', '•', or other symbols.
- Use clear section headers and consistent indentation.
- Format your response in a professional, clean, and concise way.
- Avoid unnecessary repetition and keep the output easy to scan.
- Do not use Markdown formatting or asterisks.

Format your response in a clear, easy-to-read manner with bullet points and section headers.
''';
      }

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate alternative ingredients.';
    } catch (e) {
        print('AI Service Error (attempt ${retryCount + 1}): $e');
        
        if (e.toString().contains('503') || e.toString().contains('overloaded')) {
          retryCount++;
          if (retryCount < maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          } else {
            return 'AI service is currently overloaded. Please try again in a few minutes.';
          }
        } else if (e.toString().contains('403')) {
          return 'API key error. Please check configuration.';
        } else if (e.toString().contains('401')) {
          return 'Unauthorized access. Please check API key.';
        }
        return 'Unable to connect to AI service. Error: $e';
      }
    }
    
    return 'Unable to connect to AI service after multiple attempts.';
  }

  Future<String> getRecipeIngredients(String recipeName) async {
    try {
      final prompt = '''
You are a helpful cooking assistant. For the recipe "$recipeName", please provide:

**Complete Ingredient List:**
1. List all ingredients needed for "$recipeName"
2. Include quantities and measurements
3. Specify any special requirements (e.g., room temperature, fresh, etc.)
4. Mention any optional ingredients or variations

**Ingredient Categories:**
- Main ingredients
- Seasonings and spices
- Optional additions
- Substitutions if needed

Format your response in a clear, organized manner with bullet points and sections.
Make sure the ingredients are appropriate for "$recipeName" and follow traditional recipes.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate recipe ingredients.';
    } catch (e) {
      print('AI Service Error: $e');
      if (e.toString().contains('503')) {
        return 'AI service is temporarily unavailable. Please try again later.';
      } else if (e.toString().contains('403')) {
        return 'API key error. Please check configuration.';
      } else if (e.toString().contains('401')) {
        return 'Unauthorized access. Please check API key.';
      }
      return 'Unable to connect to AI service. Error: $e';
    }
  }

  Future<String> getCookingTips(String recipeName) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
    try {
      final prompt = '''
You are a helpful cooking assistant. For the recipe "$recipeName", please provide:

1. 3-5 useful cooking tips
2. Common mistakes to avoid
3. How to make the dish healthier (if applicable)
4. Storage and reheating tips

Format your response in a clear, easy-to-read manner.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate cooking tips.';
    } catch (e) {
        print('AI Service Error (attempt ${retryCount + 1}): $e');
        
        if (e.toString().contains('503') || e.toString().contains('overloaded')) {
          retryCount++;
          if (retryCount < maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          } else {
            return 'AI service is currently overloaded. Please try again in a few minutes.';
          }
        } else if (e.toString().contains('403')) {
          return 'API key error. Please check configuration.';
        } else if (e.toString().contains('401')) {
          return 'Unauthorized access. Please check API key.';
        }
        return 'Unable to connect to AI service. Error: $e';
      }
    }
    
    return 'Unable to connect to AI service after multiple attempts.';
  }

  // Test method to verify API key and service availability
  Future<String> testApiConnection() async {
    try {
      final prompt = 'Hello, please respond with "API is working" if you can see this message.';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received';
    } catch (e) {
      print('API Test Error: $e');
      return 'Error: $e';
    }
  }
} 