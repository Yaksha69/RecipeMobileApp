import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AlternativeIngredientsPage extends StatefulWidget {
  final String? initialIngredient;
  final String? recipeName;
  const AlternativeIngredientsPage({super.key, this.initialIngredient, this.recipeName});

  @override
  State<AlternativeIngredientsPage> createState() => _AlternativeIngredientsPageState();
}

class _AlternativeIngredientsPageState extends State<AlternativeIngredientsPage> {
  final TextEditingController _ingredientController = TextEditingController();
  final AIService _aiService = AIService();
  String _aiResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIngredient != null && widget.initialIngredient!.isNotEmpty) {
      _ingredientController.text = widget.initialIngredient!;
      _getAlternatives();
    }
  }

  Future<void> _getAlternatives() async {
    if (_ingredientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ingredient')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    try {
      final response = await _aiService.getAlternativeIngredients(
        _ingredientController.text.trim(),
        recipeName: widget.recipeName,
      );
      setState(() {
        _aiResponse = response;
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setExampleIngredient(String ingredient) {
    _ingredientController.text = ingredient;
    _getAlternatives();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF181A20);
    const cardColor = Color(0xFF23242B);
    const badgeColor = Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alternative Ingredients'),
        backgroundColor: backgroundColor,
        foregroundColor: mainTextColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Section
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Alternative Ingredients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter an ingredient to find substitutes for your recipes',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        labelText: 'Enter an ingredient',
                        labelStyle: TextStyle(color: secondaryTextColor),
                        hintText: 'e.g., parmesan cheese, chicken breast, olive oil',
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                        filled: true,
                        fillColor: cardColor,
                      ),
                      style: const TextStyle(color: mainTextColor),
                      onSubmitted: (_) => _getAlternatives(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getAlternatives,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: mainTextColor),
                            )
                          : const Icon(Icons.auto_awesome, color: mainTextColor),
                        label: Text(_isLoading ? 'Searching...' : 'Find Alternatives', style: const TextStyle(color: mainTextColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: mainTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick Examples Section
            if (_aiResponse.isEmpty && !_isLoading)
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Examples',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap an example to see alternatives:',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'parmesan cheese',
                          'chicken breast',
                          'olive oil',
                          'flour',
                          'eggs',
                          'butter',
                        ].map((ingredient) => ActionChip(
                          label: Text(ingredient, style: const TextStyle(color: mainTextColor)),
                          backgroundColor: cardColor,
                          onPressed: () => _setExampleIngredient(ingredient),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_aiResponse.isNotEmpty || _isLoading) ...[
              const SizedBox(height: 16),
              // Response Section
              Expanded(
                child: Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                           Icon(
                              Icons.lightbulb_outline,
                              color: badgeColor,
                            ),
                           SizedBox(width: 8),
                            Text(
                              'AI Suggestions',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: badgeColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: mainTextColor),
                                SizedBox(height: 16),
                                Text('Searching for alternatives...', style: TextStyle(color: secondaryTextColor)),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _aiResponse,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: mainTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }
} 