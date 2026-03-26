class DetectionResult {
  final String title;
  final String type;
  final double confidence;
  final DateTime date;

  DetectionResult({
    required this.title,
    required this.type,
    required this.confidence,
    required this.date,
  });
}
