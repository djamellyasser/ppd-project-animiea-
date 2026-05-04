<div align="center">
  <img src="https://img.icons8.com/color/96/000000/blood-sample.png" alt="Logo">
  <h1 align="center">Anemia Detection via Deep Learning</h1>

  <p align="center">
    An end-to-end medical AI solution detecting anemia from conjunctiva images, powered by Deep Learning, FastAPI, and Flutter.
    <br />
    <br />
    <a href="#about-the-project"><strong>Explore the docs »</strong></a>
  </p>
</div>

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=for-the-badge&logo=PyTorch&logoColor=white)

---

## 📝 About The Project

This repository hosts a comprehensive ecosystem designed for non-invasive **Anemia Detection**. Leveraging cutting-edge Computer Vision and Machine Learning (MobileNet, ResNet, DenseNet, and U-Net architectures), this project analyzes palpebral conjunctiva images to determine the likelihood of anemia. 

The architecture encompasses three main tiers:
1. **Deep Learning Core**: robust image segmentation and classification notebooks.
2. **Backend API**: a lightweight, fast, and scalable FastAPI server serving the ML models.
3. **Mobile Platform**: a cross-platform Flutter application providing an accessible interface for end-users and medical professionals.

## 📂 Project Structure

```text
├── dataset anemia/         # Medical image datasets (India & Italy cohorts)
├── FastApi/                # FastAPI backend serving the model inference
├── Models/                 # Pre-trained models and deep learning notebooks
│   ├── anemiadetectionmodel.ipynb
│   ├── mobile-res-densenets.ipynb
│   └── UNETModelSegementation.ipynb
├── Platform/               # Flutter mobile application
└── README.md               # Project documentation
```

## 🧠 Deep Learning Models & Datasets

- **Datasets**: The `dataset anemia/` directory includes specific conjunctiva image cohorts curated from medical centers in **India** and **Italy**, segregated by palpebral features for robust training.
- **Classification Models**: The `Models/` folder contains Jupyter notebooks detailing the implementation of advanced neural architectures: MobileNet, ResNet, and DenseNets (`mobile-res-densenets.ipynb` & `anemiadetectionmodel(2).ipynb`), tuned specifically for conjunctival pallor detection.
- **Image Segmentation**: The `UNETModelSegementation.ipynb` outlines the robust U-Net segmentation routines used to isolate the region of interest (conjunctiva) from the raw eye images before inference.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have the following installed depending on the sub-project you are developing:
*   **Deep Learning & Backend**: `Python 3.8+`, `pip`
*   **Mobile App (Platform)**: [Flutter SDK](https://flutter.dev/docs/get-started/install) and `Dart`

### ⚙️ 1. Running the Backend (FastAPI)

1. Navigate to the backend directory:
   ```bash
   cd FastApi
   ```
2. Install the necessary dependencies:
   ```bash
   pip install fastapi uvicorn tensorflow torch opencv-python pydantic
   ```
3. Boot up the ASGI development server:
   ```bash
   uvicorn main:app --reload
   ```
   *The API will be live at `http://127.0.0.1:8000` with interactive Swagger docs at `http://127.0.0.1:8000/docs`.*

### 📱 2. Running the Mobile App (Flutter)

1. Navigate to the mobile application directory:
   ```bash
   cd Platform
   ```
2. Pull all Dart packages:
   ```bash
   flutter pub get
   ```
3. Run the application on your connected device or emulator:
   ```bash
   flutter run
   ```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📊 Results / النتائج

*(Include your model evaluation metrics, accuracy graphs, and testing outcomes here. / قم بإضافة مقاييس التقييم، الرسوم البيانية، ونتائج الاختبار هنا)*

## 👥 Development Team / فريق التطوير

**Developed by / من تطوير:**
- GUERROUDJI DJAMEL EDDIN YSSER
- GOUSAS MOHAMED HOUCIN
- ABADI AYMEN
- SAHRAOUI NABIL

**Under the supervision of / تحت إشراف الأستاذ:**
- Prof. KHIAT ABDERHAMEN

---
<div align="center">
  <i>Developed with ❤️ for Medical AI Advancement.</i>
</div>