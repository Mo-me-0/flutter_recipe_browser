import 'package:flutter/material.dart';
import 'package:flutter_recipe_browser/models/meal.dart';
import 'package:flutter_recipe_browser/screens/detail_screen.dart';
import 'package:flutter_recipe_browser/services/meal_api_service.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName; // to search using strCategory
  
  const CategoryScreen({
    super.key, 
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Meal>> _categoryData;
  @override
  void initState(){
    super.initState();
    // get meals list at the start
    _categoryData = MealApiService()
      .searchByCategoryName(widget.categoryName);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Meal>>(
        // trucks the progress of fetching meals list
        future: _categoryData,
        
        // handle loading, error, no data, and data
        builder: (context, snapshot) {
          
          // if it is still loading, show loading circle
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
          
          // catch errors and display it
          if(snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // error message
                  Text(
                    snapshot.error.toString()
                    // to make it more clear for users
                    .replaceAll('Exception: ', ''),
                  ),
                  const SizedBox(height: 10,),
                  
                  // retry button to reload
                  IconButton(
                    onPressed: _refreshScreen,
                    color: Colors.blue,
                    icon: const Icon(Icons.refresh),
                  ),
                  const Text('Retry'),
                ],
              ),
            );
          }
          
          // checks if any data have been fetched
          if(!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              // if no data
              child: Text('No meal available'),
            );
          }
          
          // if done loading access the meal list
          final meals = snapshot.data!;
          
          return RefreshIndicator(
            // refresh when scrolling down
            color: Colors.blue, // refresh icon color
            onRefresh: () async {
              _refreshScreen();
              await _categoryData;
            },
            
            // meal list UI
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
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
            ),
          );
        },
      ),
    );
  }
  
  // refresh meals screen
  void _refreshScreen(){
    setState(() {
      _categoryData = MealApiService()
        .searchByCategoryName(widget.categoryName);
    });
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