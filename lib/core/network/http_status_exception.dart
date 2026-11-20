class HttpStatusException implements Exception {
  final int statusCode;
  final String path;

  HttpStatusException(this.statusCode, this.path);

  @override
  String toString() => 'HttpStatusException($statusCode, $path)';
}
