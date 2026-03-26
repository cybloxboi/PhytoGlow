import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:phyto_glow/classes/roboflow_inference_result.dart';

class RoboflowService {
  static const String _apiUrl = 'https://serverless.roboflow.com';
  static const String _apiKey = 'xpamAda3bPe450nKuFjc';
  static const String _modelId = 'bccd-ouzjz/1';

  final http.Client _client;

  RoboflowService({http.Client? client}) : _client = client ?? http.Client();

  Future<RoboflowInferenceResult> inferImage(Uint8List imageBytes) async {
    final uri = Uri.parse('$_apiUrl/$_modelId').replace(
      queryParameters: <String, String>{
        'api_key': _apiKey,
        'image_type': 'base64',
        'format': 'json',
      },
    );

    final response = await _client.post(
      uri,
      headers: const <String, String>{
        'Content-Type': 'text/plain',
      },
      body: base64Encode(imageBytes),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RoboflowException(
        'Roboflow request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const RoboflowException('Roboflow response is not a JSON object.');
    }

    return RoboflowInferenceResult.fromJson(decoded);
  }
}

class RoboflowException implements Exception {
  final String message;

  const RoboflowException(this.message);

  @override
  String toString() => message;
}
