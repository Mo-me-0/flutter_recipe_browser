class MealCategory {
  final String idCategory;
  final String strCategory;
  final String strCategoryThumb;
  final String strCategoryDescription;
  
  const MealCategory({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });
  
  // map json data to MealCategory object fields
  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      idCategory: json['idCategory'] as String? ?? '',
      strCategory: json['strCategory'] as String? ?? '',
      strCategoryThumb: json['strCategoryThumb'] as String? ?? '',
      strCategoryDescription: json['strCategoryDescription'] as String? ?? '',
    );
  }
  
  // convert object data to json
  Map<String, dynamic> toJson() {
    return {
      'idCategory': idCategory,
      'strCategory': strCategory,
      'strCategoryThumb': strCategoryThumb,
      'strCategoryDescription': strCategoryDescription,
    };
  }
  
  // to change the values of fields of MealCategory object
  // or to copy object data to another
  MealCategory copyWith({
    String? idCategory,
    String? strCategory,
    String? strCategoryThumb,
    String? strCategoryDescription,
  }) {
    // change the initial value if only the values are provided
    return MealCategory(
      idCategory: idCategory ?? this.idCategory,
      strCategory: strCategory ?? this.strCategory,
      strCategoryThumb: strCategoryThumb ?? this.strCategoryThumb,
      strCategoryDescription: 
        strCategoryDescription ?? this.strCategoryDescription,
    );
  }
}