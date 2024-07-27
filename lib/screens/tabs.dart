import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/fliters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/providers/filter_provider.dart';
import 'package:meals/widgets/main_drawer.dart';
import 'package:meals/providers/meals_provider.dart';
import 'package:meals/providers/favorite_provider.dart';

const kIntialFiletr = {
  Filter.glutenFree: false,
  Filter.lactosFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectPageIndex = 0;
  // Map<Filter, bool> _selectedFilter = kIntialFiletr;

  // void toggleMealFavoriteStatus(Meal meal) {
  //   final isExisting = _favoriteMeals.contains(meal);
  //   if (isExisting) {
  //     setState(() {
  //       _favoriteMeals.remove(meal);
  //     });
  //     _showInfoMessage('Meal is no longer a favorite');
  //   } else {
  //     setState(() {
  //       _favoriteMeals.add(meal);
  //     });
  //     _showInfoMessage('Meal added to favorites!');
  //   }
  // }

  void _selectPage(int index) {
    setState(() {
      _selectPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'Filters') {
      await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => const FliterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = ref.watch(mealsProvider);
    final activeFilters = ref.watch(filterProvider);
    final availableMeals = meal.where((meal) {
      if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree)
        return false;
      if (activeFilters[Filter.lactosFree]! && !meal.isLactoseFree)
        return false;
      if (activeFilters[Filter.vegetarian]! && !meal.isVegetarian)
        return false;
      if (activeFilters[Filter.vegan]! && !meal.isVegan) return false;
      return true;
    }).toList();
    Widget activePage = CategoriesScreen(
      availableMeals: availableMeals,
    );
    var activePageTittle = 'Categories';
    if (_selectPageIndex == 1) {
      final favortieMeals = ref.watch(favoriteMealProvider);
      activePage = MealsScreen(
        meals: favortieMeals,
      );
      activePageTittle = 'your Favorites!';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTittle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}
