# Anemia Detection Project

This repository contains the source code and deliverables for the Anemia Detection Project. The project aims to provide a complete end-to-end solution for detecting anemia using machine learning models, exposed via a FastAPI backend, and consumed by a cross-platform mobile application.

## Project Structure

The repository is organized into the following main directories:

*   **`FastApi/`**: Contains the backend server implementation.
    *   `main.py`: The main entry point for the FastAPI application, responsible for handling API requests and serving the machine learning model predictions.
*   **`Models/`** & **`Noot book/`**: Contain the Jupyter notebooks and model files used for training and inference.
    *   `anemiadetectionmodel.ipynb`: Notebook for the primary anemia detection model.
    *   `UNETModelSegementation.ipynb`: Notebook containing the U-Net model implementation for image segmentation tasks related to the project.
*   **`Platform/`**: Contains the frontend application.
    *   This is a Flutter-based mobile application that interacts with the FastAPI backend to provide a user interface for anemia detection.

## Getting Started

### Prerequisites

Ensure you have the following installed depending on the component you are working with:
*   **Backend & Models**: Python 3.8+, `pip`, and necessary ML libraries (e.g., TensorFlow/PyTorch, FastAPI, Uvicorn).
*   **Frontend (Platform)**: Flutter SDK and Dart.

### Running the Backend (FastAPI)

1.  Navigate to the `FastApi` directory:
    ```bash
    cd FastApi
    ```
2.  Install the required dependencies (assuming a `requirements.txt` exists, otherwise install manually):
    ```bash
    pip install fastapi uvicorn
    # Add other dependencies like tensorflow, pytorch, opencv-python etc. as required by main.py
    ```
3.  Start the FastAPI server:
    ```bash
    uvicorn main:app --reload
    ```
    The API will be available at `http://127.0.0.1:8000`.

### Running the Mobile App (Flutter)

1.  Navigate to the `Platform` directory:
    ```bash
    cd Platform
    ```
2.  Get the Flutter dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app on an emulator or connected device:
    ```bash
    flutter run
    ```

## Machine Learning Models

The project utilizes two primary machine learning workflows:
1.  **Anemia Detection**: A classification model to detect the presence of anemia.
2.  **Segmentation (U-Net)**: A segmentation model (U-Net) likely used to isolate relevant features (e.g., in medical images like conjunctiva or blood smears) before feeding them into the detection model.

Details of the model architecture, training data, and evaluation metrics can be found in the respective Jupyter notebooks in the `Models/` or `Noot book/` directories.

# ppd-project-animiea-
