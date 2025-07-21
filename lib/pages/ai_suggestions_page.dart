import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AISuggestionsPage extends StatefulWidget {
  final List<String> ingredients;

  const AISuggestionsPage({
    super.key,
    required this.ingredients,
  });

  @override
  State<AISuggestionsPage> createState() => _AISuggestionsPageState();
}

class _AISuggestionsPageState extends State<AISuggestionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AIService _aiService = AIService();
  String _recipeSuggestions = '';
  String _alternativeIngredients = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateSuggestions();
  }

  Future<void> _generateSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await _aiService.getRecipeSuggestions(widget.ingredients);
      setState(() {
        _recipeSuggestions = suggestions;
      });
    } catch (e) {
      setState(() {
        _recipeSuggestions = 'Error generating suggestions: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getAlternativeIngredients(String ingredient) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final alternatives = await _aiService.getAlternativeIngredients(ingredient);
      setState(() {
        _alternativeIngredients = alternatives;
      });
    } catch (e) {
      setState(() {
        _alternativeIngredients = 'Error generating alternatives: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF181A20);
    const badgeColor =  Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Suggestions'),
        backgroundColor: backgroundColor,
        foregroundColor: mainTextColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: badgeColor,
          labelColor: badgeColor,
          unselectedLabelColor: secondaryTextColor,
          tabs: const [
            Tab(text: 'Recipe Suggestions'),
            Tab(text: 'Alternatives'),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipeSuggestionsTab(),
          _buildAlternativesTab(),
        ],
      ),
    );
  }

  Widget _buildRecipeSuggestionsTab() {
    const cardColor = Color(0xFF23242B);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Recipe Suggestions for:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.ingredients.map((ingredient) => Chip(
              label: Text(ingredient, style: const TextStyle(color: mainTextColor)),
              backgroundColor: cardColor,
            )).toList(),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: mainTextColor),
                  SizedBox(height: 16),
                  Text('Generating AI suggestions...', style: TextStyle(color: secondaryTextColor)),
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
                    _recipeSuggestions.isEmpty
                        ? 'No suggestions available'
                        : _recipeSuggestions,
                    style: const TextStyle(fontSize: 16, color: mainTextColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlternativesTab() {
    const cardColor = Color(0xFF23242B);
    const badgeColor =  Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alternative Ingredients',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an ingredient to find alternatives:',
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = widget.ingredients[index];
                return Card(
                  color: cardColor,
                  child: ListTile(
                    title: Text(ingredient, style: const TextStyle(color: mainTextColor)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: badgeColor),
                    onTap: () => _getAlternativeIngredients(ingredient),
                  ),
                );
              },
            ),
          ),
          if (_alternativeIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alternative Suggestions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _alternativeIngredients,
                    style: const TextStyle(fontSize: 16, color: mainTextColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 