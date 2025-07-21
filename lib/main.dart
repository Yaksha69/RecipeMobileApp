import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/saved_recipes_page.dart';
import 'pages/alternative_ingredients_page.dart';
import 'providers/saved_recipes_provider.dart';
import 'pages/recipe_book_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SavedRecipesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Let Him Cook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/recipes': (context) => const RecipeBookPage(),
        '/saved': (context) => const SavedRecipesPage(),
        '/alternatives': (context) => const AlternativeIngredientsPage(),
        // Add more routes as needed
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;


  static const backgroundColor = Color(0xFF181A20);
  static const selectedColor = Color.fromARGB(255, 58, 136, 237);
  static const unselectedColor = Color(0xFFB0B0B0);

  final List<Widget> _pages = [
    const RecipeBookPage(),
    const SavedRecipesPage(),
    const AlternativeIngredientsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: backgroundColor,
        child: BottomNavigationBar(
          backgroundColor: backgroundColor,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          currentIndex: _selectedIndex,
          onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
          items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Recipes',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Alternatives',
          ),
        ],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
