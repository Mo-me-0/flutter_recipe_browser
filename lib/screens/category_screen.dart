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
      backgroundColor: Color(0xFF010101),
      appBar: AppBar(
        title: Text(widget.categoryName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF010101),
        foregroundColor: Color(0xFFF2FCFC),
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
                color: Color(0xFFFF5f39),
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
                    .replaceAll('Exception: ', ''), // to make it more clear for users
                    style: TextStyle(color: Color(0xFFF2FCFC),),
                  ),
                  const SizedBox(height: 10,),
                  
                  // retry button to reload
                  IconButton(
                    onPressed: _refreshScreen,
                    color: Color(0xFFFF5f39),
                    icon: const Icon(Icons.refresh),
                  ),
                  const Text('Retry',
                    style: TextStyle(color: Color(0xFFF2FCFC),),
                  ),
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
            color: Color(0xFFFF5f39), // refresh icon color
            onRefresh: () async {
              _refreshScreen();
            },
            
            // meal list UI
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: meals.length, // number of meals
              itemBuilder: (context, index){
                // access individual meal data
                final meal = meals[index];
                
                return ListTile(
                  // navigate to details screen
                  onTap: () => _openMeal(context, meal.idMeal),
                  contentPadding: const EdgeInsets.all(0),
                  
                  // meal title
                  title: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            meal.strMealThumb, // image from api
                            fit: BoxFit.cover, // fit the image to the container
                            height: 150,
                                          
                            // while loading the image, show loding circle
                            loadingBuilder: (context, child, loadingProgress) {
                              if(loadingProgress == null) return child;
                              return Center(
                                child: const CircularProgressIndicator(
                                    color:Color(0xFFFF5f39),
                                ),
                              );
                            },
                            
                            // when image didn't load, show brocken image icon
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: Color(0xFFFF5f39),
                                size: 150,
                              );
                            },
                          ),
                        ),
                      ),

                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF010101),
                              Color(0xFF010101).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      Positioned.fill(
                        top: 10,
                        left: 10,
                        child: Text(
                          meal.strMeal,
                          style: const TextStyle(
                            color: Color(0xFFF2FCFC),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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