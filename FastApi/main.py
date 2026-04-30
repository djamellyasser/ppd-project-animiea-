import cv2
import numpy as np
import tempfile
import os
import torch
import torch.nn as nn
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from keras.models import load_model

# ============================================================
#  U-Net Architecture (must match training)
# ============================================================

class DoubleConv(nn.Module):
    def __init__(self, in_ch, out_ch):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(in_ch, out_ch, 3, padding=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_ch, out_ch, 3, padding=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True),
        )
    def forward(self, x):
        return self.conv(x)

class UNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.enc1 = DoubleConv(3,   64)
        self.enc2 = DoubleConv(64,  128)
        self.enc3 = DoubleConv(128, 256)
        self.enc4 = DoubleConv(256, 512)
        self.pool = nn.MaxPool2d(2)
        self.bottleneck = DoubleConv(512, 1024)
        self.up4  = nn.ConvTranspose2d(1024, 512, 2, stride=2)
        self.dec4 = DoubleConv(1024, 512)
        self.up3  = nn.ConvTranspose2d(512, 256, 2, stride=2)
        self.dec3 = DoubleConv(512,  256)
        self.up2  = nn.ConvTranspose2d(256, 128, 2, stride=2)
        self.dec2 = DoubleConv(256,  128)
        self.up1  = nn.ConvTranspose2d(128, 64,  2, stride=2)
        self.dec1 = DoubleConv(128,  64)
        self.out  = nn.Conv2d(64, 1, 1)

    def forward(self, x):
        e1 = self.enc1(x)
        e2 = self.enc2(self.pool(e1))
        e3 = self.enc3(self.pool(e2))
        e4 = self.enc4(self.pool(e3))
        b  = self.bottleneck(self.pool(e4))
        d4 = self.dec4(torch.cat([self.up4(b),  e4], dim=1))
        d3 = self.dec3(torch.cat([self.up3(d4), e3], dim=1))
        d2 = self.dec2(torch.cat([self.up2(d3), e2], dim=1))
        d1 = self.dec1(torch.cat([self.up1(d2), e1], dim=1))
        return torch.sigmoid(self.out(d1))

# ============================================================
#  STARTUP — Load models once
# ============================================================

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
IMG_SIZE = 256

print("Loading U-Net segmentation model...")
unet = UNet().to(DEVICE)
unet.load_state_dict(torch.load("unet_conjunctiva.pth", map_location=DEVICE))
unet.eval()
print(f"✅ U-Net loaded on {DEVICE}")

print("Loading CNN classifier...")
cnn_model = load_model("model_anemia.keras")
print("✅ CNN model loaded")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
#  SEGMENTATION
# ============================================================

def segment_conjunctiva(img_bgr: np.ndarray) -> np.ndarray:
    # Preprocess for U-Net
    img_rgb     = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    img_resized = cv2.resize(img_rgb, (IMG_SIZE, IMG_SIZE))
    inp         = torch.from_numpy(img_resized.astype(np.float32) / 255.0)
    inp         = inp.permute(2, 0, 1).unsqueeze(0).to(DEVICE)

    # Predict mask
    with torch.no_grad():
        pred = unet(inp).squeeze().cpu().numpy()
    mask = (pred > 0.5).astype(np.uint8)

    # Crop conjunctiva region
    cropped = img_resized.copy()
    cropped[mask == 0] = 0  # black out background

    # Tight crop around region
    ys, xs = np.where(mask == 1)
    if len(ys) > 0:
        y1, y2 = ys.min(), ys.max()
        x1, x2 = xs.min(), xs.max()
        cropped = cropped[y1:y2, x1:x2]

    # Resize to CNN input size
    cropped = cv2.resize(cropped, (128, 128))
    cv2.imwrite('debug_segmented.jpg', cv2.cvtColor(cropped, cv2.COLOR_RGB2BGR))
    normalized = cropped.astype(np.float32) / 255.0
    return np.expand_dims(normalized, axis=0)  # (1, 128, 128, 3)

# ============================================================
#  ENDPOINTS
# ============================================================

@app.get("/")
def root():
    return {"status": "AnemiaLens API is running"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
        tmp.write(contents)
        tmp_path = tmp.name

    try:
        img = cv2.imread(tmp_path)
        if img is None:
            return {"error": "Could not read image"}

        # Segment conjunctiva using U-Net
        preprocessed = segment_conjunctiva(img)

        # Classify using CNN
        prediction  = cnn_model.predict(preprocessed, verbose=0)
        score       = float(prediction[0][0])

        if score >= 0.5:
            result     = "anemic"
            confidence = score
        else:
            result     = "notAnemic"
            confidence = 1 - score

        print(f"Score: {score:.4f} | Result: {result} | Confidence: {confidence:.4f}")

        return {
            "result":     result,
            "confidence": round(confidence, 4)
        }

    finally:
        os.unlink(tmp_path)

import base64

@app.post("/segment")
async def segment(file: UploadFile = File(...)):
    contents = await file.read()
    with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
        tmp.write(contents)
        tmp_path = tmp.name

    try:
        img = cv2.imread(tmp_path)
        if img is None:
            return {"error": "Could not read image"}

        segmented = segment_conjunctiva(img)  # returns (1, 128, 128, 3)
        
        # Convert back to displayable image
        seg_img = (segmented[0] * 255).astype(np.uint8)
        seg_bgr = cv2.cvtColor(seg_img, cv2.COLOR_RGB2BGR)
        _, buffer = cv2.imencode('.jpg', seg_bgr)
        b64 = base64.b64encode(buffer).decode('utf-8')
        
        return {"segmented_image": b64}
    finally:
        os.unlink(tmp_path)