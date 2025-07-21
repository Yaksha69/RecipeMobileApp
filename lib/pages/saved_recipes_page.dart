import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_recipes_provider.dart';
import 'recipe_detail_page.dart';

class SavedRecipesPage extends StatelessWidget {
  const SavedRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF181A20);
    const cardColor = Color(0xFF23242B);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: backgroundColor,
        foregroundColor: mainTextColor,
      ),
      backgroundColor: backgroundColor,
      body: Consumer<SavedRecipesProvider>(
        builder: (context, savedRecipesProvider, child) {
          final savedRecipes = savedRecipesProvider.savedRecipes.toList();
          if (savedRecipes.isEmpty) {
            return const Center(
              child: Text(
                'No saved recipes yet',
                style: TextStyle(fontSize: 18, color: secondaryTextColor),
              ),
            );
          }
          return Container(
            color: backgroundColor,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return Card(
                  color: cardColor,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            recipe: recipe,
                            matchingCount: recipe.ingredients.length,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                    child: recipe.imageUrl.isNotEmpty
                                        ? Image.network(
                                            recipe.imageUrl,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: cardColor,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.restaurant,
                                                  size: 40,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: cardColor,
                                            child: const Center(
                                              child: Icon(
                                                Icons.restaurant,
                                                size: 40,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: Text(
                                recipe.name,
                                style: const TextStyle(
                                  color: mainTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Delete Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(128, 71, 71, 71),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: mainTextColor,
                                size: 20,
                              ),
                              onPressed: () => savedRecipesProvider.toggleSave(recipe),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 