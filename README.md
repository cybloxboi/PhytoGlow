# Phyto Glow

An application for analyzing fluorescence from local plant extracts to detect blood stains and help
indicate blood abnormalities at the initial level using image processing.

## Vercel

Set these environment variables in Vercel:

- `ROBOFLOW_API_KEY`
- `ROBOFLOW_MODEL_ID`
- `ROBOFLOW_API_URL`
- `FLUORESCENT_API_ENDPOINT`

Then run the config generator before Flutter build. Example install/build flow:

```bash
if cd flutter; then git pull && cd ..; else git clone https://github.com/flutter/flutter.git; fi && \
./scripts/create_config_vercel.sh && \
flutter/bin/flutter doctor && \
flutter/bin/flutter clean && \
flutter/bin/flutter config --enable-web
```
