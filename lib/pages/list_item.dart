import 'package:flutter/material.dart';
import 'package:recipeapp/pages/recipe.dart';
import 'package:recipeapp/pages/itemcard.dart';

class ListItem extends StatefulWidget {
  const ListItem({super.key});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {

  List<Recipe> recipes = [
    Recipe(
      name: 'Pasta',
      description: 'Delicious pasta with tomato sauce',
      calories: '300',
    ),
    Recipe(
      name: 'Salad',
      description: 'Fresh salad with mixed greens',
      calories: '150',
    ),
    Recipe(
      name: 'Pizza',
      description: 'Cheesy pizza with pepperoni',
      calories: '400',
    ),
    Recipe(
      name: 'Burger',
      description: 'Juicy burger with lettuce and tomato',
      calories: '500',
    ),
    Recipe(
      name: 'Sushi',
      description: 'Sushi rolls with fresh fish',
      calories: '250',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List items'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: recipes.map((recipe) => Itemcard(recipe: recipe)).toList(),
        ),
      ),
    );
  }
}