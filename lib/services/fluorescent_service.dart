import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:phyto_glow/classes/exception/fluorescent_exception.dart';
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/config/fluorescent_api_config.dart';

class FluorescentService {
  FluorescentService({http.Client? client}) : _client = client ?? http.Client();

  static const String _endpoint = FluorescentApiConfig.endpoint;
  final http.Client _client;

  Future<LuminolResult> detectFluorescent({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (_endpoint.isEmpty) {
      throw const FluorescentException(
        'FastAPI endpoint is missing. Set it in lib/config/fluorescent_api_config.dart',
      );
    }

    final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
      ..files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FluorescentException(
        'Fluorescent API request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FluorescentException(
        'Fluorescent API response is not a JSON object.',
      );
    }

    final errorMessage = decoded['error'];
    if (errorMessage is String && errorMessage.isNotEmpty) {
      throw FluorescentException(errorMessage);
    }

    final previewHex = decoded['preview_image']?.toString() ?? '';
    final previewBytes = _decodeHex(previewHex);
    if (previewBytes.isEmpty) {
      throw const FluorescentException(
        'Fluorescent API did not return a valid preview image.',
      );
    }

    return LuminolResult(
      previewBytes: previewBytes,
      area: _toInt(decoded['area']),
      meanIntensity: _toDouble(decoded['mean_intensity']),
      maxIntensity: _toInt(decoded['max_intensity']),
    );
  }

  Uint8List _decodeHex(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length.isOdd) {
      return Uint8List(0);
    }

    final bytes = Uint8List(normalized.length ~/ 2);
    for (var i = 0; i < normalized.length; i += 2) {
      final parsed = int.tryParse(normalized.substring(i, i + 2), radix: 16);
      if (parsed == null) {
        return Uint8List(0);
      }
      bytes[i ~/ 2] = parsed;
    }

    return bytes;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
