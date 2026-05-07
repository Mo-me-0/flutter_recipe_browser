import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_browser/models/meal.dart';
import 'package:flutter_recipe_browser/screens/detail_screen.dart';
import 'package:flutter_recipe_browser/services/meal_api_service.dart';

class MySearchDelegate extends SearchDelegate{
  final _serviceApi = MealApiService(); // connect with api
  
  // for debounce implementation
  Timer? _debounce;
  final ValueNotifier<List<Meal>> _resultsNotifier = ValueNotifier<List<Meal>>([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false); 

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      onPressed: () {
        if(query.isNotEmpty) {
          query = '';
        } else {
          close(context, null);
        }
      }, 
      icon: Icon(Icons.clear),
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    
    if(query.isEmpty) {
      return const Center(
        child: Text('Search for Meal'),
      );
    }
    
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder:(context, loading, child) {
        // while loading show loading screen
        if(loading){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
        
        // is done loading
        return ValueListenableBuilder<List<Meal>>(
          valueListenable: _resultsNotifier,
          builder: (context, meals, child) {
            // if meal is not found, notify user
            if(meals.isEmpty) {
              return const Center(
                child: Text('No meals found')
              );
            }
            
            // if meal found, show result list
            return _buildMealList(meals);
          },
        );
      },
    );
  }
  
  // run the debounce logic
  void _onQueryChanged(String query) {
    // cancel the timer if set earlier
    if(_debounce?.isActive ?? false) _debounce?.cancel();
    
    _isLoading.value = true; // notifies it is loading
    
    // sets a delay for 400ms for each key strock
    _debounce = Timer(Duration(milliseconds: 400), () async {
      try{
        // searchs for the meal
        final results = await _serviceApi.searchMeal(query);
        _resultsNotifier.value = results;
      } catch (e) {
        // if error wile connecting to api
        _resultsNotifier.value = [];
      } finally {
        // notify it has finished loading
        _isLoading.value = false;
      }
    });
  }
  
  Widget _buildMealList(List<Meal> meals) {
    return ListView.builder(
      itemCount: meals.length, // number of meals
      itemBuilder: (context, index){
        // access individual meal data
        final meal = meals[index];
        
        return Card(
          color: Colors.blueGrey,
          child: ListTile(
            // navigate to details screen
            onTap: () => _openMeal(context, meal.idMeal),
            contentPadding: const EdgeInsets.all(16),
            textColor: Colors.white,
            
            // meal image
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.network(
                meal.strMealThumb, // image from api
                
                // while loading the image, show loding circle
                loadingBuilder: (context, child, loadingProgress) {
                  if(loadingProgress == null) return child;
                  return const CircularProgressIndicator(
                      color:Colors.blue
                  );
                },
                
                // when image didn't load, show brocken image icon
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 40,
                  );
                },
              ),
            ),
            
            // meal title
            title: Text(meal.strMeal),
          ),
        );
      },
    );
  }
  
  // navigate to detail screen
  void _openMeal(BuildContext context, String mealId) {
    Navigator.push(
      context, MaterialPageRoute(
        builder:(context) => DetailScreen(mealId: mealId),
      ),
    );
  }  
}