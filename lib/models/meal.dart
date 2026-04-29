class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strYoutube;
  final List<String> ingredients;
  
  const Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strYoutube,
    required this.ingredients,
  });
  
  // map json data to Meal object filds
  factory Meal.fromJson(Map<String, dynamic> json) {
    final meal = Meal(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strMealThumb: json['strMealThumb'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strYoutube: json['strYoutube'],
      ingredients: [], // will be added later
    );
    
    // adds an ingredients list to the meal object
    return meal.copyWith(ingredients: meal._parseIngredients(json));
  }
  
  // to convert individual key-value pairs of ingredients and measures to a list
  List<String> _parseIngredients(Map<String, dynamic> json) {
    final List<String> ingredientList = [];
    
    /**
     * since ingredients are stored as strIngredient1, strIngredient2, ...20
     * and each ingredients has measures as strMeasure1, strMeasure2, ...20
     * we need to combine the ingredients and with their measures then 
     * add the combined string to the list
    */
    
    for(int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      
      // check if the ingredient is null or an empty string
      if(ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final combined = measure != null && // check if measure is null
          measure.toString().trim().isNotEmpty // check if measure is empty string
            ? '$measure $ingredient' // return as 1 kg Chicken
            : ingredient; // if there is no measure
        ingredientList.add(combined);
      }
    }
    return ingredientList;
  }
  
  // convert object data to json
  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strYoutube': strYoutube,
      'ingredients': ingredients,
    };
  }
  
  // to change the values of filds of Meal object 
  // or to copy object data to another
  Meal copyWith({
    String? idMeal,
    String? strMeal,
    String? strMealThumb,
    String? strCategory,
    String? strArea,
    String? strInstructions,
    String? strYoutube,
    List<String>? ingredients, 
  }) {
    // change the initial value if only the values are provided
    return Meal(
      idMeal: idMeal ?? this.idMeal,
      strMeal: strMeal ?? this.strMeal,
      strMealThumb: strMealThumb ?? this.strMealThumb,
      strCategory: strCategory ?? this.strCategory,
      strArea: strArea ?? this.strArea,
      strInstructions: strInstructions ?? this.strInstructions,
      strYoutube: strYoutube ?? this.strYoutube,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}