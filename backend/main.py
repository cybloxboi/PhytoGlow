import base64

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
    allow_methods=["POST"],
    allow_headers=["*"],
)


def encode_base64(img: np.ndarray) -> str:
    _, buf = cv2.imencode(".png", img)
    return base64.b64encode(buf).decode("utf-8")


def build_overlay(img: np.ndarray, mask: np.ndarray) -> np.ndarray:
    bgr = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    highlight = np.zeros_like(bgr)
    highlight[mask > 0] = (0, 255, 100)
    overlay = cv2.addWeighted(bgr, 0.7, highlight, 0.3, 0)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(overlay, contours, -1, (0, 220, 255), 1)
    return overlay


@app.post("/fluorescent-detect")
async def detect_fluorescent(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        return JSONResponse(status_code=400, content={"error": "Invalid file type"})

    contents = await file.read()
    np_arr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_GRAYSCALE)

    if img is None:
        return JSONResponse(status_code=400, content={"error": "Invalid image"})

    # Threshold
    otsu_thresh, mask = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    mask_bg = cv2.bitwise_not(mask)

    # Intensity
    fg_vals = img[mask > 0].astype(np.float64)
    bg_vals = img[mask_bg > 0].astype(np.float64)

    mean_fg = float(np.mean(fg_vals)) if fg_vals.size > 0 else 0.0
    mean_bg = float(np.mean(bg_vals)) if bg_vals.size > 0 else 0.0

    corrected = max(0.0, mean_fg - mean_bg)
    intensity_pct = (corrected / 255.0) * 100

    total = img.size
    fg_px = int(np.count_nonzero(mask))
    area_pct = fg_px / total * 100

    # Signal quality
    std_bg = float(np.std(bg_vals)) if bg_vals.size > 0 else 0.0
    snr = (corrected / std_bg) if std_bg > 1e-6 else 0.0
    snr = min(snr, 100.0)  # cap

    # Regions
    num_labels, _, stats, _ = cv2.connectedComponentsWithStats(mask, connectivity=8)
    region_count = num_labels - 1
    largest_area = int(np.max(stats[1:, cv2.CC_STAT_AREA])) if region_count > 0 else 0

    # Preview
    overlay = build_overlay(img, mask)

    return {
        # ตัวเลขหลักสำหรับแสดงผล
        "intensity_percentage": round(intensity_pct, 2),  # % ความเข้มแสง (corrected)
        "area_percent": round(area_pct, 2),  # % พื้นที่ที่เรืองแสง
        "snr": round(snr, 2),  # Signal-to-Noise Ratio

        # ค่าดิบ (สำหรับ tooltip / detail panel)
        "mean_foreground": round(mean_fg, 2),
        "mean_background": round(mean_bg, 2),
        "otsu_threshold": round(float(otsu_thresh), 1),

        # ข้อมูล region
        "region_count": region_count,
        "largest_area_px": largest_area,

        # Preview images (base64 PNG)
        "preview_overlay": encode_base64(overlay),
    }
