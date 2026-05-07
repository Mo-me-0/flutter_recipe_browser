import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_recipe_browser/models/meal.dart';
import 'package:flutter_recipe_browser/models/meal_category.dart';
import 'package:flutter_recipe_browser/services/api_exception.dart';
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
    try {
      // creates new https url to list all meal categories
      final url = Uri.https(_baseUrl, // domain
        '/api/json/v1/1/categories.php' // path
      );

      final response = await http
        .get(url, headers: _headers,) // request html Response
        .timeout(_timeout); // waits 10 seconds for responce

      // checks non-200 statuscode response
      _checkResponse(response);

      // changes the responce's body(string) to json oject
      final jsonData = jsonDecode(response.body);
      
      // map the data from json to MealCategory model
      return (jsonData['categories'] as List)
        .map((json) => MealCategory.fromJson(json))
        .toList();
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('An Unexpected error occured: $e');
    }
  }
  
  // get list of meals in a specific category
  Future<List<Meal>> searchByCategoryName(String category) async {
    try{
      // creates new https url to filter by category
      final url = Uri.https(_baseUrl, // domain
        '/api/json/v1/1/filter.php', // path
        {'c': category}, // query parameter
      );
     
      final response = await http
        .get(url, headers: _headers) // request html Response
        .timeout(_timeout); // waits 10 seconds for response
      
      // checks non-200 statuscode response
      _checkResponse(response);
      
      // convert the html body to json
      final jsonData = jsonDecode(response.body);
      
      // only take values of the 'meals' key of json
      final meals = jsonData['meals'] as List?;
      if(meals == null) return []; // if api returns null
      
      /**
       * since the json we get here only has no
       * strInstructions and other required fields foe Meal mode
       * we call fetch by meal id to get all the necessary fields
      */
      return await Future.wait(
        // convert List<Future<Meal>> to List<Meal> by waiting
        meals.map((json) => fetchByMealId(json['idMeal'] as String)),
      );
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('An Unexpected error occured: $e');
    }
  }
  
  // get meal detail data
  Future<Meal> fetchByMealId(String mealId) async {
    try {
      // creates new https url to see meal details by mealid
      final url = Uri.https(_baseUrl, // domain
        '/api/json/v1/1/lookup.php', // path
        {'i': mealId}, // query parameter
      );
      
      final response = await http
        .get(url, headers: _headers) // request html Response
        .timeout(_timeout); // waits 10 seconds for response
      
      // checks non-200 statuscode response
      _checkResponse(response);
      
      // convert the html body to json
      final jsonData = jsonDecode(response.body);
      
      // only take value of the 'meals' key of json
      final meal = jsonData['meals'] as List;
      
      // since there is only one meal in the list
      return Meal.fromJson(meal.first); // take the first one
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('An Unexpected error occured: $e');
    }
  }
  
  // Search for Meal by name
  Future<List<Meal>> searchMeal(String mealName) async {
    try {
      // create a url to search by meal name
      final url = Uri.https(_baseUrl, // domain
        '/api/json/v1/1/search.php', // path
        {'s': mealName}, // query parametr
      );
      
      final response = await http
        .get(url, headers: _headers)
        .timeout(_timeout);
      
      // checks non-200 statuscode response
      _checkResponse(response);
      
      // convert the html body to json object
      final jsonData = jsonDecode(response.body);
      
      // if no such meal found
      final meals = jsonData['meals'] as List?;
      if (meals == null) return [];
      
      return meals
          .map((json) => Meal.fromJson(json))
          .toList();
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('An Unexpected error occured: $e');
    }
  }
  
  // throw custom ApiException for non-200 responses
  void _checkResponse(http.Response response){
    // if not successful
    if(response.statusCode != 200) {
      // checks which known statuscode response they are
      
      // tried to recreate what we have seen in class
      // I may have missed some or implemented in a different way
      switch (response.statusCode) {
        case 400:
          throw ApiException(
            response.statusCode, 
            'Bad Request', // message
          );
        case 401:
          throw ApiException(
            response.statusCode, 
            'Unauthorized access', // message
          );
        case 403:
          throw ApiException(
            response.statusCode, 
            'Forbidden', // message
          );
        case 404:
          throw ApiException(
            response.statusCode, 
            'Page does not exist', // message
          );
        case 429:
          throw ApiException(
            response.statusCode, 
            'Too many requests', // message
          );
        case 500:
          throw ApiException(
            response.statusCode, 
            'Internal server error', // message
          );
        case 502:
          throw ApiException(
            response.statusCode, 
            'Bad gateway', // message
          );
        case 503:
          throw ApiException(
            response.statusCode, 
            'Service unavailable', // message
          );
        default:
          throw ApiException(
            response.statusCode, 
            'Request failed with status code ${response.statusCode}', // message
          );
      }
    }
  }
}