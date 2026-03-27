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

## Vercel

Set these environment variables in Vercel:

- `ROBOFLOW_API_KEY`
- `ROBOFLOW_MODEL_ID`
- `ROBOFLOW_API_URL` (optional)

Then run the config generator before Flutter build. Example install/build flow:

```bash
if cd flutter; then git pull && cd ..; else git clone https://github.com/flutter/flutter.git; fi && \
./scripts/create_roboflow_config.sh && \
flutter/bin/flutter doctor && \
flutter/bin/flutter clean && \
flutter/bin/flutter config --enable-web
```
