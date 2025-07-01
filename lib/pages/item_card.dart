import 'package:flutter/material.dart';

import 'recipe.dart';

class Itemcard extends StatelessWidget {
  final Recipe recipe;
  const Itemcard({
    super.key
    , required this.recipe,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      shadowColor: Colors.green,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.fastfood,
                color: Colors.white,
                size: 17,
              ),
            ),
            Text(recipe.name,
            textAlign: TextAlign.center,
             style:
             const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            Text(recipe.description,
              textAlign: TextAlign.center,
             style:
             const TextStyle(
                fontSize: 12,
                color: Colors.grey
              )
            ),
            Text('Calories: ${recipe.calories}',
              textAlign: TextAlign.center,
             style: const TextStyle(
              fontSize: 12,
              color: Colors.black,  
              )
            ),
          ],
        ),
      ),
    );
  }
}