import 'package:flutter/material.dart';
import 'package:flutter_recipe_browser/models/meal.dart';
import 'package:flutter_recipe_browser/services/meal_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String mealId;
  
  const DetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Meal> _meal;
  
  @override
  void initState() {
    super.initState();
    _meal = MealApiService().fetchByMealId(widget.mealId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010101),
      
      body: FutureBuilder<Meal>(
        // trucks the progress of fetching meals data
        future: _meal, 
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
                    // to make it more clear for users
                    .replaceAll('Exception: ', ''),
                    style: TextStyle(color: Color(0xFFF2FCFC)),
                  ),
                  const SizedBox(height: 10,),
                  
                  // retry button to reload
                  IconButton(
                    onPressed: _refreshScreen,
                    color: Color(0xFFFF5f39),
                    icon: const Icon(Icons.refresh),
                  ),
                  const Text('Retry',
                    style: TextStyle(
                      color: Color(0xFFF2FCFC),
                    ),
                  ),
                ],
              ),
            );
          }
          
          // checks if any data have been fetched
          if(!snapshot.hasData) {
            return const Center(
              // if no data
              child: Text('Meal detail unavailable'),
            );
          }
          
          // get meal detail data
          final mealData = snapshot.data!;
          
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 250,
                backgroundColor: Color(0xFF010101),
                pinned: true,
                
                leading: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Color(0xFF010101).withValues(alpha: 0.3),
                  ),
                  icon: Icon(Icons.arrow_back,
                    color: Color(0xFFF2FCFC),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    mealData.strMeal,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2FCFC),
                    ),
                  ),

                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          mealData.strMealThumb,
                          fit: BoxFit.fill,
                          
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

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF010101).withValues(alpha: 0),
                              Color(0xFF010101),
                            ], 
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Main Containt
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF010101),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    // ingredients with measures
                    children: [
                      Text('Ingredients',
                        style: TextStyle(
                          color: Color(0xFFF2FCFC),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                      for (String ingredient in mealData.ingredients) 
                        ListTile(
                          title: Text('• $ingredient', 
                            style: TextStyle(
                              color: Color(0xFFF2FCFC),
                            ),
                          ),
                        ),
                      
                      // instructions
                      Text('Instructions',
                        style: TextStyle(
                          color: Color(0xFFF2FCFC),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(mealData.strInstructions,
                          style: TextStyle(
                            color: Color(0xFFF2FCFC),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20,),

                      // youtube url launcher
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF5f39),
                          disabledBackgroundColor: Colors.grey[900],
                        ),
                        onPressed: mealData.strYoutube.isEmpty 
                        ? null 
                        : () => _openYoutube(mealData.strYoutube),
                        child: Text('Youtube Video',
                          style: TextStyle(
                            color: Color(0xFFF2FCFC),
                          ),
                        ),
                      ),

                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ),
            ],
          ); 
        }
      ),
    );
  }
  
  // refresh screen
  void _refreshScreen() {
    setState(() {
      _meal = MealApiService().fetchByMealId(widget.mealId);
    });
  }
  
  // open the video through youtube
  Future<void> _openYoutube(String url) async {
    // create the uri based on strYoutube
    final Uri video = Uri.parse(url);
    
    // open's the video on youtube
    final success = await launchUrl( video, 
      mode: LaunchMode.inAppBrowserView,
    );
    
    // show a snackbar message when failed to open the video
    if(!success){
      if(!mounted) return; // to handle async gap
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video')),
      );
    }
  }
}