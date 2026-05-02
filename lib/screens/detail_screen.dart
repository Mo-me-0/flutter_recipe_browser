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
      appBar: AppBar(
        title: Text('Meal Detail'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Meal>(
        // trucks the progress of fetching meals data
        future: _meal, 
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
          if(!snapshot.hasData) {
            return const Center(
              // if no data
              child: Text('Meal detail unavailable'),
            );
          }
          
          // get meal detail data
          final mealData = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshScreen();
                    await _meal;
                  },
                  color: Colors.blue,
                  child: SingleChildScrollView(
                  child: Column(
                    spacing: 20,
                    children: [
                      // meal title
                      Text(mealData.strMeal,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // meal image
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: Image.network(
                          mealData.strMealThumb, // image from api
                          
                          // while loading the image, show loding circle
                          loadingBuilder: (context, child, loadingProgress) {
                            if(loadingProgress == null) return child;
                            return const CircularProgressIndicator(
                              padding: EdgeInsets.all(100),
                              color:Colors.blue,
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
                      
                      // ingredients with measures
                      Text('Ingredients',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String ingredient in mealData.ingredients) 
                            Text('• $ingredient', 
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      
                      // instructions
                      Text('Instructions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(mealData.strInstructions,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      
                      // youtube url launcher
                      ElevatedButton(
                        onPressed: mealData.strYoutube.isEmpty 
                        ? null 
                        : () => _openYoutube(mealData.strYoutube),
                        child: Text('Youtube Video',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),)
              ),
            ),
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