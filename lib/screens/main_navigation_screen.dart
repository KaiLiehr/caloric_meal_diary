import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'meal_diary_screen.dart';
import 'recipies_screen.dart';
import 'ingredients_screen.dart';


// Navbar screen
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

// displays the chosen page via index selection from screen list
class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MealDiaryScreen(),
    RecipiesScreen(),
    IngredientsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Meal Diary',
    'Recipies',
    'Ingredients',
  ];


    @override
  Widget build(BuildContext context) {
    print("PRINT:Building MainNavigationScreen");
    return Scaffold(

      // should preserve scroll position on screen switch, not tested yet
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),


      // NAVBAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Ingredients',
          ),
        ],
      ),
    );
  }
}