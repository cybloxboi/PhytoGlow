class FluorescentException implements Exception {
  const FluorescentException(this.message);

  final String message;

  @override
  String toString() => message;
}
