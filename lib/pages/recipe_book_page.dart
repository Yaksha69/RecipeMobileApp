import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';
import 'ai_suggestions_page.dart';
import '../services/recipe_api_service.dart';
import 'loading_page.dart';

class RecipeBookPage extends StatefulWidget {
  const RecipeBookPage({super.key});

  @override
  State<RecipeBookPage> createState() => _RecipeBookPageState();
}

class _RecipeBookPageState extends State<RecipeBookPage> with TickerProviderStateMixin {
  final List<String> selectedIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedArea;
  bool _searchByIngredient = false;
  List<String> _categories = [];
  List<String> _areas = [];
  Future<List<Recipe>> _futureRecipes = Future.value([]);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    RecipeApiService.fetchAreas().then((areas) {
      setState(() {
        _areas = areas;
        _selectedArea = 'All'; // Default to "All Countries"
        _futureRecipes = RecipeApiService.fetchPopularRecipes();
      });
    });
    RecipeApiService.fetchCategoriesForAllAreas().then((cats) {
      setState(() {
        _categories = cats;
      });
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }







  void _onAreaChanged(String? area) async {
    setState(() {
      _selectedArea = area;
      _selectedCategory = null;
      _searchController.clear();
    });
    
    // Update recipes
    if (area == null || area == 'All') {
      setState(() {
        _futureRecipes = RecipeApiService.fetchPopularRecipes();
      });
    } else {
      setState(() {
        _futureRecipes = RecipeApiService.fetchByArea(area);
      });
    }
    
    // Update categories for the selected area
    try {
      List<String> newCategories;
      if (area == null || area == 'All') {
        newCategories = await RecipeApiService.fetchCategoriesForAllAreas();
      } else {
        newCategories = await RecipeApiService.fetchCategoriesForArea(area);
      }
      setState(() {
        _categories = newCategories;
      });
    } catch (e) {
      // If category fetching fails, keep existing categories
      print('Error fetching categories for area $area: $e');
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty && _selectedCategory == null) {
      setState(() {
        _futureRecipes = _selectedArea != null ? RecipeApiService.fetchByArea(_selectedArea!) : RecipeApiService.fetchFilipinoRecipes();
      });
    } else if (query.isNotEmpty) {
      setState(() {
        if (_selectedArea == null || _selectedArea == 'All') {
          // Search across all recipes
          _futureRecipes = _searchByIngredient
            ? RecipeApiService.searchByIngredient(query)
            : RecipeApiService.searchByName(query);
        } else {
          // Search within the selected area
          _futureRecipes = _searchByIngredient
            ? RecipeApiService.searchByIngredientInArea(query, _selectedArea!)
            : RecipeApiService.searchByNameInArea(query, _selectedArea!);
        }
      });
    } else if (_selectedCategory != null) {
      setState(() {
        if (_selectedArea != null) {
          _futureRecipes = RecipeApiService.fetchByAreaAndCategory(_selectedArea!, _selectedCategory!);
        } else {
          _futureRecipes = RecipeApiService.fetchFilipinoByCategory(_selectedCategory!);
        }
      });
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _futureRecipes = _selectedArea != null ? RecipeApiService.fetchByArea(_selectedArea!) : RecipeApiService.fetchFilipinoRecipes();
      } else {
        if (_selectedArea != null) {
          _futureRecipes = RecipeApiService.fetchByAreaAndCategory(_selectedArea!, category);
        } else {
          _futureRecipes = RecipeApiService.fetchFilipinoByCategory(category);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Custom colors to match the reference image
    const backgroundColor = Color(0xFF181A20);
    const cardColor = Color(0xFF23242B);
    const badgeColor =  Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Let Him Cook App'),
        backgroundColor: const Color.fromARGB(255, 102, 140, 255),
        foregroundColor: mainTextColor,
        actions: [
          if (selectedIngredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              color: mainTextColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AISuggestionsPage(
                      ingredients: selectedIngredients,
                    ),
                  ),
                );
              },
              tooltip: 'AI Suggestions',
            ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          if (_areas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButton<String>(
                value: _selectedArea,
                hint: const Text('Select Country/Area'),
                dropdownColor: cardColor,
                style: const TextStyle(color: mainTextColor),
                iconEnabledColor: badgeColor,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: 'All',
                    child: Text('All Countries', style: TextStyle(color: mainTextColor)),
                  ),
                  ..._areas.map((area) => DropdownMenuItem<String>(
                    value: area,
                    child: Text(area, style: const TextStyle(color: mainTextColor)),
                  )),
                ],
                onChanged: _onAreaChanged,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _searchByIngredient ? 'Search by ingredient...' : 'Search by name...',
                      border: const OutlineInputBorder(),
                      fillColor: cardColor,
                      filled: true,
                      hintStyle: const TextStyle(color: Colors.white),
                      prefixIcon: IconButton(
                        icon: Icon(_searchByIngredient ? Icons.restaurant : Icons.search, color: badgeColor),
                        onPressed: () {
                          setState(() {
                            _searchByIngredient = !_searchByIngredient;
                          });
                        },
                        tooltip: _searchByIngredient ? 'Switch to name search' : 'Switch to ingredient search',
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: badgeColor),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                        tooltip: 'Clear search',
                      ),
                    ),
                    style: const TextStyle(color: mainTextColor),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badgeColor,
                      foregroundColor: mainTextColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: _onSearch,
                    child: const Text('Search', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          if (_categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                dropdownColor: cardColor,
                style: const TextStyle(color: mainTextColor),
                iconEnabledColor: badgeColor,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Categories', style: TextStyle(color: mainTextColor)),
                  ),
                  ..._categories.map((cat) => DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat, style: const TextStyle(color: mainTextColor)),
                  )),
                ],
                onChanged: _onCategoryChanged,
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingPage(
                      message: 'Bros cooking...',
                      showGif: true,
                      gifPath: 'assets/loadingcook.gif',
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFB0B0B0),
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: mainTextColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _futureRecipes = _selectedArea != null 
                                ? RecipeApiService.fetchByArea(_selectedArea!)
                                : RecipeApiService.fetchFilipinoRecipes();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: badgeColor,
                            foregroundColor: mainTextColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: Color(0xFFB0B0B0),
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No recipes found',
                          style: TextStyle(color: mainTextColor, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search criteria',
                          style: TextStyle(color: Color(0xFFB0B0B0)),
                        ),
                      ],
                    ),
                  );
                }
                final recipes = snapshot.data!;
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _selectedArea == null || _selectedArea == 'All' 
                              ? 'All Recipes' 
                              : '${_selectedArea} Recipes',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            color: backgroundColor,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetailPage(
                                          recipe: recipe,
                                          matchingCount: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          // Recipe image
                                          recipe.imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: recipe.imageUrl,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) => Container(
                                                    color: cardColor,
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                  children: [
                                                            Icon(
                                                              Icons.restaurant,
                                                              color: secondaryTextColor,
                                                              size: 40,
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              'Loading...',
                                                              style: TextStyle(
                                                                color: secondaryTextColor,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Container(
                                                    color: cardColor,
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                  children: [
                                                            Icon(
                                                              Icons.restaurant,
                                                              color: secondaryTextColor,
                                                              size: 40,
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              'No Image',
                                                              style: TextStyle(
                                                                color: secondaryTextColor,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  color: cardColor,
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                            Icon(
                                                              Icons.restaurant,
                                                              color: secondaryTextColor,
                                                              size: 40,
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              'No Image',
                                                              style: TextStyle(
                                                                color: secondaryTextColor,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                    ),
                                                  ),
                                                ),
                                          // Recipe number badge
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: badgeColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '#${index + 1}',
                                                style: const TextStyle(
                                                  color: mainTextColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Overlay with gradient and title
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Color.fromARGB(200, 0, 0, 0),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                              child: Text(
                                                recipe.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black54,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 