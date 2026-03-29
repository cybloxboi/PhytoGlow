import base64

import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

# =========================
# CORS
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://phyto-glow.vercel.app/",
    ],
    allow_credentials=True,
    allow_methods=["POST"],
    allow_headers=["*"],
)


# =========================
# API
# =========================
@app.post("/fluorescent-detect")
async def detect_fluorescent(
        file: UploadFile = File(...)
):
    # read file
    contents = await file.read()

    # check file type
    if not file.content_type.startswith("image/"):
        return JSONResponse(status_code=400, content={"error": "Invalid file type"})

    # decode image
    np_arr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if img is None:
        return JSONResponse(status_code=400, content={"error": "Invalid image"})

    # =========================
    # OPTIMIZE: resize
    # =========================
    img = cv2.resize(img, (640, 480))

    # =========================
    # 1. ใช้ Green channel
    # =========================
    b, g, r = cv2.split(img)

    # =========================
    # 2. blur
    # =========================
    blurred = cv2.GaussianBlur(g, (3, 3), 0)

    # =========================
    # 3. threshold
    # =========================
    _, thresh = cv2.threshold(blurred, 200, 255, cv2.THRESH_BINARY)

    # =========================
    # 4. morphology
    # =========================
    kernel = np.ones((3, 3), np.uint8)
    clean = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    # =========================
    # 5. คำนวณค่า
    # =========================
    mask = clean > 0
    area = int(np.sum(mask))
    mean_intensity = float(np.mean(g[mask])) if area > 0 else 0.0
    max_intensity = int(np.max(g)) if area > 0 else 0

    # =========================
    # 6. overlay
    # =========================
    overlay = img.copy()
    overlay[mask] = [0, 255, 0]

    # =========================
    # 7. encode → base64
    # =========================
    success, buffer = cv2.imencode('.jpg', overlay)
    if not success:
        return JSONResponse(status_code=500, content={"error": "Encode failed"})

    preview_base64 = base64.b64encode(buffer).decode("utf-8")

    # =========================
    # response
    # =========================
    return {
        "area": area,
        "mean_intensity": mean_intensity,
        "max_intensity": max_intensity,
        "preview_image": preview_base64
    }
