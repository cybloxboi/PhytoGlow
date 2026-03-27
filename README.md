# Phyto Glow

An application for analyzing fluorescence from local plant extracts to detect blood stains and help
indicate blood abnormalities at the initial level using image processing.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Roboflow configuration

Create `/Users/tutor/StudioProjects/phyto_glow/lib/config/roboflow_config.dart`
from `/Users/tutor/StudioProjects/phyto_glow/lib/config/roboflow_config.example.dart`
and put your Roboflow values there.

That file is ignored by Git so the key will not be committed with the project.

Note: this keeps the key out of the repository, but a client-side Flutter app
still cannot truly hide a secret. If the key must remain private, move the
Roboflow request to your own backend.
