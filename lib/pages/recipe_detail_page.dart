import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/saved_recipes_provider.dart';
import '../services/ai_service.dart';
import 'loading_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final int matchingCount;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.matchingCount,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final AIService _aiService = AIService();
  String _cookingTips = '';
  bool _isLoadingTips = false;
  final Map<String, String> _alternativeIngredients = {};
  final Map<String, bool> _loadingAlternatives = {};
  String? _openDropdownIngredient; // Track which ingredient's dropdown is open
  String _apiTestResult = '';

  // Color palette constants for the whole class
  static const backgroundColor = Color(0xFF181A20);
  static const cardColor = Color(0xFF23242B);
  static const badgeColor = Color.fromARGB(255, 58, 136, 237);
  static const mainTextColor = Colors.white;
  static const secondaryTextColor = Color(0xFFB0B0B0);

  Future<void> _getCookingTips() async {
    setState(() {
      _isLoadingTips = true;
    });

    try {
      final tips = await _aiService.getCookingTips(widget.recipe.name);
      setState(() {
        _cookingTips = tips;
      });
    } catch (e) {
      setState(() {
        _cookingTips = 'Error generating cooking tips: $e';
      });
    }

    setState(() {
      _isLoadingTips = false;
    });
  }

  Future<void> _getAlternativeIngredients(String ingredient) async {
    debugPrint('Getting alternatives for: $ingredient'); // Debug log
    
    if (_alternativeIngredients.containsKey(ingredient)) {
      debugPrint('Alternatives already loaded for: $ingredient'); // Debug log
      return; // Already loaded
    }

    setState(() {
      _loadingAlternatives[ingredient] = true;
    });

    try {
      debugPrint('Calling AI service for: $ingredient in recipe: ${widget.recipe.name}'); // Debug log
      final alternatives = await _aiService.getAlternativeIngredients(
        ingredient, 
        recipeName: widget.recipe.name
      );
      debugPrint('AI response for $ingredient: ${alternatives.substring(0, 100)}...'); // Debug log
      
      setState(() {
        _alternativeIngredients[ingredient] = alternatives;
        _loadingAlternatives[ingredient] = false;
      });
    } catch (e) {
      debugPrint('Error getting alternatives for $ingredient: $e'); // Debug log
      setState(() {
        _alternativeIngredients[ingredient] = 'Error loading alternatives: $e';
        _loadingAlternatives[ingredient] = false;
      });
    }
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _apiTestResult = 'Testing API connection...';
    });

    try {
      final result = await _aiService.testApiConnection();
      setState(() {
        _apiTestResult = result;
      });
    } catch (e) {
      setState(() {
        _apiTestResult = 'Test failed: $e';
      });
    }
  }

  Future<void> _getCompleteRecipeIngredients() async {
    setState(() {
      _isLoadingTips = true;
    });

    try {
      final ingredients = await _aiService.getRecipeIngredients(widget.recipe.name);
      setState(() {
        _cookingTips = ingredients;
      });
    } catch (e) {
      setState(() {
        _cookingTips = 'Error generating recipe ingredients: $e';
      });
    }

    setState(() {
      _isLoadingTips = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name, style: const TextStyle(color: mainTextColor)),
        backgroundColor: backgroundColor,
        foregroundColor: mainTextColor,
        actions: [
          Consumer<SavedRecipesProvider>(
            builder: (context, savedRecipesProvider, child) {
              final isSaved = savedRecipesProvider.isSaved(widget.recipe);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? badgeColor : mainTextColor,
                ),
                onPressed: () => savedRecipesProvider.toggleSave(widget.recipe),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (widget.recipe.imageUrl.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.recipe.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Matching Ingredients Info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(38), // ~15% opacity
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Matching ingredients: ${widget.matchingCount}/${widget.recipe.ingredients.length}',
                style: const TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Ingredients Section with Alternatives
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: mainTextColor,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.recipe.ingredients.map((ingredient) => _buildIngredientWithAlternatives(ingredient)),
            const SizedBox(height: 32),
            // Instructions Section
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.recipe.instructions, style: const TextStyle(color: mainTextColor)),
            const SizedBox(height: 24),
            // AI Cooking Tips Section
            Row(
              children: [
                const Text(
                  'AI Cooking Tips',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: badgeColor),
                  onPressed: _cookingTips.isEmpty ? _getCookingTips : null,
                  tooltip: 'Get AI Cooking Tips',
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: TextButton.icon(
                    onPressed: _cookingTips.isEmpty ? _getCompleteRecipeIngredients : null,
                    icon: const Icon(Icons.list_alt, size: 15, color: badgeColor),
                    label: const Text(
                      'Complete Ingredients', 
                      style: TextStyle(color: badgeColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            // API Test Section
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _testApiConnection,
                  icon: const Icon(Icons.bug_report, size: 15, color: badgeColor),
                  label: const Text('Test API', style: TextStyle(color: badgeColor)),
                ),
                const Spacer(),
                if (_apiTestResult.isNotEmpty)
                  Expanded(
                    child: Text(
                      _apiTestResult,
                      style: const TextStyle(color: secondaryTextColor, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            if (_isLoadingTips)
              const Center(
                child: InlineLoading(
                  message: 'Generating cooking tips...',
                  size: 40,
                ),
              )
            else if (_cookingTips.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _cookingTips,
                  style: const TextStyle(fontSize: 16, color: mainTextColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientWithAlternatives(String ingredient) {
    final hasAlternatives = _alternativeIngredients.containsKey(ingredient);
    final isLoading = _loadingAlternatives[ingredient] ?? false;
    final isOpen = _openDropdownIngredient == ingredient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.circle, size: 10, color: badgeColor),
            title: Text(
              ingredient, 
              style: const TextStyle(
                color: mainTextColor, 
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: badgeColor),
                  )
                : IconButton(
                    icon: Icon(
                      isOpen ? Icons.expand_less : Icons.swap_horiz,
                      size: 18,
                      color: badgeColor,
                    ),
                    onPressed: () async {
                      setState(() {
                        _openDropdownIngredient = isOpen ? null : ingredient;
                      });
                      if (!hasAlternatives && !isLoading && !isOpen) {
                        await _getAlternativeIngredients(ingredient);
                        setState(() {}); // Refresh after fetch
                      }
                    },
                    tooltip: isOpen ? 'Hide Alternatives' : 'Show Alternatives',
                  ),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 12, bottom: 12, top: 4),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: badgeColor))
                : _alternativeIngredients[ingredient] != null
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF23242B), // lighter dark for dropdown
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: DefaultTextStyle(
                          style: const TextStyle(color: Colors.white),
                          child: _buildSummarizedAlternatives(_alternativeIngredients[ingredient]!),
                        ),
                      )
                    : const Text('No alternatives found.', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildSummarizedAlternatives(String alternatives) {
    final bulletRegex = RegExp(r'^(?:[-]|\d+\.)\s+', multiLine: true);
    final lines = alternatives.split(RegExp(r'\n+')).where((line) => line.trim().isNotEmpty).toList();
    final bulletLines = lines.where((line) => bulletRegex.hasMatch(line)).toList();
    final displayLines = bulletLines.isNotEmpty ? bulletLines : lines;
    bool showAll = false;
    int maxLines = 3;
    Color bulletColor = badgeColor;
    TextStyle altTextStyle = const TextStyle(fontSize: 14);
    TextStyle linkStyle = const TextStyle(color: badgeColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline);

    Widget buildList(List<String> linesToShow) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: linesToShow.map((line) {
        // Safe string replacement to prevent RangeError
        String displayText = line;
        try {
          final match = bulletRegex.firstMatch(line);
          if (match != null && match.end <= line.length) {
            displayText = line.substring(match.end);
          }
        } catch (e) {
          // If there's any error in parsing, just use the original line
          displayText = line;
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0, right: 8.0),
                child: Icon(Icons.circle, size: 8, color: bulletColor),
              ),
              Expanded(
                child: Text(
                  displayText, 
                  style: altTextStyle.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (displayLines.length <= maxLines) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lightbulb_outline, size: 18, color: bulletColor),
            title: Text(
              'Alternative Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold, color: bulletColor, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Divider(thickness: 1, color: Colors.grey[300]),
          const SizedBox(height: 8),
          buildList(displayLines),
        ],
      );
    } else {
      return StatefulBuilder(
        builder: (context, setState) {
          final linesToShow = showAll ? displayLines : displayLines.take(maxLines).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.lightbulb_outline, size: 18, color: bulletColor),
                title: Text(
                  'Alternative Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold, color: bulletColor, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),
              buildList(linesToShow),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => setState(() => showAll = !showAll),
                  child: Text(showAll ? 'Show less' : 'Show more', style: linkStyle),
                ),
              ),
            ],
          );
        },
      );
    }
  }
} 