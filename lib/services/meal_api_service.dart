import 'dart:async';
import 'dart:convert';
import 'package:flutter_recipe_browser/models/meal.dart';
import 'package:flutter_recipe_browser/models/meal_category.dart';
import 'package:http/http.dart' as http;

class MealApiService {
  final String _baseUrl = 'themealdb.com'; // the domain name
  
  // timeout and headers are static const because they are the same for every object
  static const _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // get all the categories from the api as list
  Future<List<MealCategory>> fetchAllCategories() async{
    // creates new https url to list all meal categories
    final url = Uri.https(_baseUrl, // domain
      '/api/json/v1/1/categories.php' // path
    );

    final response = await http
      .get(url, headers: _headers,) // request html Response
      .timeout(_timeout); // waits 10 seconds for responce

    // this is temporary, for handling when no responce
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    // changes the responce's body(string) to json oject
    final jsonData = jsonDecode(response.body);
    
    // map the data from json to MealCategory model
    return (jsonData['categories'] as List)
      .map((json) => MealCategory.fromJson(json))
      .toList();
  }
  
  // get list of meals in a specific category
  Future<List<Meal>> searchByCategoryName(String category) async {
    // creates new https url to filter by category
    final url = Uri.https(_baseUrl, // domain
      '/api/json/v1/1/filter.php', // path
      {'c': category}, // query parameter
    );
     
    final response = await http
      .get(url, headers: _headers) // request html Response
      .timeout(_timeout); // waits 10 seconds for responce
    
    // temporary later substituted by _checkResponse()
    if (response.statusCode != 200) {
      throw Exception('Failed to load Meals');
    }
    
    // convert the html body to json
    final jsonData = jsonDecode(response.body);
    
    // only take values of the 'meals' key of json
    final meals = jsonData['meals'] as List;
    
    /**
     * since the json we get here only has no
     * strInstructions and other required fields foe Meal mode
     * we call fetch by meal id to get all the necessary fields
    */
    return await Future.wait(
      // convert List<Future<Meal>> to List<Meal> by waiting
      meals.map((json) => fetchByMealId(json['idMeal'] as String)),
    );
  }
  
  // get meal detail data
  Future<Meal> fetchByMealId(String mealId) async {
    // creates new https url to see meal details by mealid
    final url = Uri.https(_baseUrl, // domain
      '/api/json/v1/1/lookup.php', // path
      {'i': mealId}, // query parameter
    );
    
    final response = await http
      .get(url, headers: _headers) // request html Response
      .timeout(_timeout); // waits 10 seconds for responce
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load Meal');
    }
    
    // convert the html body to json
    final jsonData = jsonDecode(response.body);
    
    // only take value of the 'meals' key of json
    final meal = jsonData['meals'] as List;
    
    // since there is only one meal in the list
    return Meal.fromJson(meal.first); // take the firt one
  }
}