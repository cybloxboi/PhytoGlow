#!/usr/bin/env sh
set -eu

mkdir -p lib/config

cat > lib/config/roboflow_config.dart <<CONFIG
class RoboflowConfig {
  static const String apiUrl = '${ROBOFLOW_API_URL:-https://serverless.roboflow.com}';
  static const String apiKey = '${ROBOFLOW_API_KEY:-}';
  static const String modelId = '${ROBOFLOW_MODEL_ID:-bccd-ouzjz/1}';
}
CONFIG
