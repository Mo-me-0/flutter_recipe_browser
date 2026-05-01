class ApiException implements Exception {
  final int statusCode;
  late final String message;
  
  ApiException(this.statusCode, this.message);
  
  @override
  String toString(){
    return 'ApiException: ($statusCode) $message';
  }
}