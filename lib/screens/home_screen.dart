import 'package:flutter/material.dart';
import 'package:flutter_recipe_browser/models/meal_category.dart';
import 'package:flutter_recipe_browser/services/meal_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MealCategory>> _categories; 
  
  @override
  void initState() {
    super.initState();
    _categories = MealApiService().fetchAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Browser App',),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      
      body: FutureBuilder<List<MealCategory>>(
        // trucks the progress of fetching categories
        future: _categories,
        
        // handle loading, error, no data, and data
        builder: (context, snapshot) {
          
          // if it is still loading, show loading circle
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: const CircularProgressIndicator(),
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
                    .replaceAll('Exception: ', ''),
                  ),
                  const SizedBox(height: 10,),
                  
                  // retry button to reload
                  IconButton(
                    onPressed: () {
                      setState(() {
                        // reassign _categories to search again
                        _categories = MealApiService().fetchAllCategories();
                      });
                    },
                    color: Colors.blue,
                    icon: const Icon(Icons.refresh),
                  ),
                  const Text('Retry'),
                ],
              ),
            );
          }
          
          // checks if any categories have been fetched
          if(!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              // if no data
              child: Text('No Category available'),
            );
          }
          
          // if done loading access the category list
          final categoryList = snapshot.data!;
          
          // show categories in grid
          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: categoryList.length, // number of categories
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // row count
                mainAxisSpacing: 10, // horizontal spacing
                childAspectRatio: 0.9, // space between children
              ),
              itemBuilder: (context, index) {
                // to access each individual categories
                final MealCategory category = categoryList[index];
                
                return InkWell(
                  // for later to navigate to next screen
                  onTap: () {print(category.strCategory);},
            
                  // touch feedback on tap 
                  splashColor: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                  
                  // category card UI  
                  child: Card(
                    color: Colors.blueGrey,
                    child: GridTile(
                      
                      // category image
                      header: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          category.strCategoryThumb,
                          width: 70,
                          height: 70,
                          
                          // while loading the image, show loding circle
                          loadingBuilder: (context, child, loadingProgress) {
                            if(loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            );
                          },
                          
                          // when image didn't load, show brocken image icon
                          errorBuilder:(context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 60,
                            );
                          },
                        ),
                      ),
                      
                      // category description
                      footer: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          category.strCategoryDescription,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      // category title
                      child: Center(
                        child: Text(
                          category.strCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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