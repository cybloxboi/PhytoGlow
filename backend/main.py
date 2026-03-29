import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/fluorescent-detect")
async def detect_fluorescent(file: UploadFile = File(...)):
    contents = await file.read()
    np_arr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if img is None:
        return JSONResponse(status_code=400, content={"error": "Invalid image"})

    # =========================
    # 1. แยก channel (ใช้ Green channel)
    # =========================
    b, g, r = cv2.split(img)

    # =========================
    # 2. Gaussian blur ลด noise
    # =========================
    blurred = cv2.GaussianBlur(g, (5, 5), 0)

    # =========================
    # 3. Threshold (ปรับค่าได้)
    # =========================
    _, thresh = cv2.threshold(blurred, 200, 255, cv2.THRESH_BINARY)

    # =========================
    # 4. Morphology (ลบจุด noise เล็ก ๆ)
    # =========================
    kernel = np.ones((5, 5), np.uint8)
    clean = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    # =========================
    # 5. คำนวณค่า fluorescence
    # =========================
    mask = clean > 0
    area = int(np.sum(mask))
    mean_intensity = float(np.mean(g[mask])) if area > 0 else 0.0
    max_intensity = int(np.max(g)) if area > 0 else 0

    # =========================
    # 6. สร้างภาพ overlay (highlight)
    # =========================
    overlay = img.copy()
    overlay[mask] = [0, 255, 0]

    # encode เป็น jpg
    _, buffer = cv2.imencode('.jpg', overlay)

    # =========================
    # 7. response
    # =========================
    return {
        "area": area,
        "mean_intensity": mean_intensity,
        "max_intensity": max_intensity,
        "preview_image": buffer.tobytes().hex(),
    }
