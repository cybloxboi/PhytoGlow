import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:phyto_glow/classes/roboflow/roboflow_inference_result.dart';
import 'package:phyto_glow/config/roboflow_config.dart';

class RoboflowService {
  static const String _apiUrl = RoboflowConfig.apiUrl;
  static const String _apiKey = RoboflowConfig.apiKey;
  static const String _modelId = RoboflowConfig.modelId;

  final http.Client _client;

  RoboflowService({http.Client? client}) : _client = client ?? http.Client();

  Future<RoboflowInferenceResult> inferImage(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) {
      throw const RoboflowException(
        'Roboflow API key is missing. Set it in lib/config/roboflow_config.dart',
      );
    }

    final uri = Uri.parse('$_apiUrl/$_modelId').replace(
      queryParameters: <String, String>{
        'api_key': _apiKey,
        'image_type': 'base64',
        'format': 'json',
      },
    );

    final response = await _client.post(
      uri,
      headers: const <String, String>{'Content-Type': 'text/plain'},
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
