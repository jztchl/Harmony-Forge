<p align="center">
  <img src="/icon.png" alt="Harmony Forge Logo" width="200">
</p>

<h1 align="center"> Harmony Forge</h1>

<p align="center">
 
Harmony Forge is a music generation platform that combines the power of a Flask server for backend processing, a Flutter app for the Android client interface, and allows users to generate music seamlessly.
</p>


---


## 🎵 Flask Server

The Flask server acts as the backend for the Harmony Forge project. It handles music generation requests, manages user authentication and accounts, provides an admin panel for model management, and ensures a secure environment. Additionally, Harmony Forge leverages LSTM networks for MIDI generation, enabling users to create diverse musical compositions.

### Features:

- **Music Generation with LSTM**: Utilizes LSTM (Long Short-Term Memory) networks trained on MIDI datasets to generate music based on user preferences and inputs. The LSTM model can capture complex musical patterns and nuances, resulting in diverse and expressive MIDI outputs.
  
- **Multiple Instrument Support**: Harmony Forge supports multiple instruments for MIDI generation, allowing users to specify instrument tracks and arrangements to create rich and varied musical compositions.

- **Custom Model Creation**: Users have the flexibility to create custom LSTM models tailored to their musical style and preferences. By training the LSTM network on specific MIDI datasets, users can fine-tune the model to generate music that aligns with their artistic vision.

### Technologies Used:

- Python with Flask framework for server-side logic.
- TensorFlow for creating and training the LSTM model for MIDI generation.
- SQLAlchemy for database management.
- Flask JWT Extended for user authentication and JWT handling.
- Flask Mail for sending verification emails and notifications.
- Flask RESTful API for smooth communication with the Flutter app.

### Setup Instructions:

1. Clone the repository:
   ```bash
   git clone https://github.com/jztchl/Harmony-Forge.git
   ```

2. Navigate to the Flask server directory:
   ```bash
   cd Harmony-Forge/server
   ```

3. Install dependencies:
   ```bash
   pip install -r needs.txt
   ```

4. Set up environment variables:
   Configure the following in the config.py after adding it:
   ```python

import os
from datetime import timedelta



   ```

class Config: 
    SECRET_KEY = 'your_secret_key_here'
    SQLALCHEMY_DATABASE_URI = 'sqlite:///users.db'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=3)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    MAIL_SERVER = 'smtp.example.com'
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_DEFAULT_SENDER = your_email@example.com
    MAIL_USERNAME = your_email@example.com
    MAIL_PASSWORD = your_email_password

   ```

5. Run the Flask server:
   ```bash
   python flask_app.py
   ```

6. The Flask server will run on `http://localhost:5000`.

7. Or you could run the project in the command line:
   ```bash
   python control.py
   ```

### Sample Music File Space:

You can find sample music files in the `sample_music` directory. These files can be used to train custom LSTM models and generate diverse MIDI compositions with multiple instrument tracks.

---

By integrating LSTM networks for MIDI generation, Harmony Forge offers users the ability to create sophisticated and personalized musical pieces with rich instrumentation and customized model training.
## 📱 Flutter App

The Harmony Forge project includes an Android Flutter app that serves as the client-side interface for users. Here are some key points about the Flutter app:

- **Technology**: Developed using the Flutter framework, which allows for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Platform**: Specifically designed for Android devices, providing a smooth and native-like user experience.
- **User Interface**: Features a user-friendly interface designed to interact seamlessly with the Flask server backend.
- **Functionality**:
  - Music Generation: Allows users to generate music by interacting with the Flask server endpoints.
  - User Authentication: Enables user registration, login, and password management functionalities.
  - UI/UX Design: Incorporates modern design principles for an engaging and intuitive user experience.
- **Integration with Flask Server**: Communicates with the Flask server backend through HTTP requests to perform various actions such as music generation, user management, and feedback submission.
- **Security Measures**: Implements secure communication protocols and authentication mechanisms to ensure data privacy and user authentication integrity.

### Setup Instructions:

1. Install Flutter SDK and set up your development environment: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. Clone the repository:

   ```bash
   git clone https://github.com/jztchl/Harmony-Forge.git
   ```

3. Navigate to the Flutter app directory:

   ```bash
   cd Harmony-Forge/flutter_app
   ```

4. Install dependencies:

   ```bash
   flutter pub get
   ```
5. Configure the urls in api lib/api_endpoints.dart:
   ```bash
   const String BASE_URL = 'server url';
   ```
   note:be in same network running locally
   
6. Run the Flutter app:

   ```bash
   flutter run
   ```

7. The Flutter app will build and run on your connected Android device or emulator.

### Sample Music File Space:

You can add your sample music files to the `sample_music` directory inside the Flutter app. These files can be used for testing and demonstration purposes within the app.

---

Feel free to explore the full potential of Harmony Forge by setting up both the Flask server and Flutter app and experimenting with music generation and user interactions!

---
