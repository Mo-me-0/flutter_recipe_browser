class Meal {
  final int idMeal;
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
}