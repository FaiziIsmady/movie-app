# ReelsTek

A Project for RISTEK MobDev Open Recruitment.

## Short Learned Essay

In creating the movie_app, I chose to reference "LetterBox." What I mean by this is adding "social" functionalities where users can see others. To implement this, I needed a database, so I asked ChatGPT for the easiest option, and it suggested Firebase. Then, I began working. First, I used an API key from TMDB to fetch movie data. Initially, I added the key to .env for security, but since others might use my app, I ended up hardcoding it (not ideal).

For development, I used the Firebase emulator, thinking it would keep my database clean. However, this backfired, and as of two hours ago, I was struggling to transition to an online Firebase database. Thankfully, with the help of LLMs and GSGS, I resolved the issue and pushed the final product.

Several packages were essential to this project. For database implementation, I used firebase_core, firebase_auth, firebase_storage, and cloud_firestore, which provide built-in authentication and storage. I also added sqflite and shared_preferences (though I’m unsure if the latter was fully implemented). For API calls, I used http, and for profile pictures, image_picker. I also used several other packages of which I cant mention it all.

One unexpectedly hard thing to implement was statemanagement. I used provider, but getting scene transitions right took an entire day. This experience showed me that state management is a critical aspect of mobile development.

From this project, I learned that proper planning and understanding of data flow are crucial. I come upon alot of unexpected challenges. However, through trial and error, debugging, and leveraging online resources, I managed to overcome them. This experience of development process have taught me adaptability, problem-solving, and the importance of continuously learning from mistakes.

## Application Photos

### Login and Register

![Image](https://github.com/user-attachments/assets/11848378-b6f9-450b-959a-a938826b0494)

![Image](https://github.com/user-attachments/assets/0654a12e-03f0-466c-8b9d-d6a3045aef11)

### Movies Home Screen, Detail, Cast, and Review

![Image](https://github.com/user-attachments/assets/1e3dd5cf-36af-4aac-bec9-62728f6b3646)

![Image](https://github.com/user-attachments/assets/142323c1-012c-4cca-b45c-ff69dbee4809)

![Image](https://github.com/user-attachments/assets/28c6812b-7829-469b-841d-8c664fbaa963)

![Image](https://github.com/user-attachments/assets/9326873c-7ba6-4b7a-abed-6413f7acc992)

### Explore Page

![Image](https://github.com/user-attachments/assets/2eac3b38-b5dc-4490-9042-b09f9cd1bb61)

### Social Page

![Image](https://github.com/user-attachments/assets/4f043b99-3dbb-447e-83e3-8a2c0214abec)

![Image](https://github.com/user-attachments/assets/a0e16797-cfbb-4ab2-a187-2f626da93bb0)

### Profile Page Create and Read

![Image](https://github.com/user-attachments/assets/39f18ad0-3ebf-4711-a5e2-a5defe08fb1c)

![Image](https://github.com/user-attachments/assets/bf4d4b66-b0dc-45e4-b237-025f64747410)

### View User Reviews and Edit

![Image](https://github.com/user-attachments/assets/02dd9cac-1fd2-4043-97af-dd991fcf9ee0)

![Image](https://github.com/user-attachments/assets/91c92f68-a3a3-47da-b693-12130cf1110a)

## Application Package and Dependencies

- Database & Storage
sqflite (^2.3.0) – A package for using SQLite, a lightweight database for local storage in Flutter apps.
path (^1.8.3) – Provides utilities for manipulating file system paths, often used with SQLite or local file management.
shared_preferences (^2.2.0) – A key-value storage solution for saving small amounts of persistent data, like user settings or login states.
firebase_storage (^12.4.4) – Enables storing and retrieving files (such as images, PDFs, or videos) in Firebase Cloud Storage.

- Networking & API Requests
http (^1.1.0) – A package for making HTTP requests, commonly used for REST APIs to fetch or send data over the internet.
cached_network_image (^3.3.0) – Efficiently loads and caches network images, reducing redundant image downloads and improving performance.
url_launcher (^6.1.14) – Allows opening external URLs, such as launching web pages, emails, or maps from within the app.

- Firebase Services
firebase_core (^3.12.1) – The core Firebase SDK needed to initialize Firebase services in the app.
firebase_auth (^5.5.1) – Provides authentication services using Firebase, including email/password, Google, Facebook, and other authentication methods.
cloud_firestore (^5.6.5) – Enables the use of Firebase Firestore, a NoSQL cloud database for storing and syncing data in real-time.

- State Management & Dependency Injection
provider (^6.0.0) – A popular state management solution in Flutter, allowing efficient app-wide state updates.

- Environment Variables & Configuration
flutter_dotenv (^5.1.0) – Enables managing environment variables using a .env file, which is useful for storing API keys and secrets securely.

- Image & Media Handling
image_picker (^1.0.4) – Allows picking images from the device’s gallery or camera.

- UI & Styling
cupertino_icons (^1.0.8) – Provides a set of Cupertino (iOS-style) icons for use in Flutter apps.

Note: I am sorry for the late push since I missread the readme assignment.