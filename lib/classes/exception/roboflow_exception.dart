class RoboflowException implements Exception {
  final String message;

  const RoboflowException(this.message);

  @override
  String toString() => message;
}
