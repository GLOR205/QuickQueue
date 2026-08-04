# QuickQueue Demo Video

 **[Watch the Full Demo Video Here](https://drive.google.com/file/d/1e0BLvYgJ4TqhmZp8GVgaT6Y-yoP74cib/view?usp=sharing)**

---

##  Team — Group 5

| Name | Role |
|------|------|
| Gloria Muhorakeye | Project Manager and Report Writer |
| Elvis Nsengimana Ishema | Flutter User Screens Developer |
| Flavienne Benihirwe | Flutter Staff Screens Developer |
| Lydivine Umutesi | Firebase and Backend Developer |
| Seth Iradukunda | Architecture, State Management, and Testing |

---

##  Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore + Authentication)
- **State Management:** BLoC (flutter_bloc)
- **Architecture:** Clean Architecture
- **Navigation:** GoRouter
- **Dependency Injection:** GetIt

---

##  Test Results as shown in Demo

### flutter analyze
```
Analyzing quickqueue...
No issues found! (ran in 9.7s)
```

### flutter test
```
00:44 +85: All tests passed!
```

### dart format
```
dart format .
(Applied to all Dart source files — Windows build folder path exception is expected and does not affect source code formatting)
```

---

##  Setup Instructions

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android Studio or VS Code
- Android device or emulator
- Firebase account

### Step 1: Clone the Repository
```bash
git clone https://github.com/GLOR205/QuickQueue.git
cd QuickQueue/quickqueue
```

### Step 2: Add google-services.json
Obtain the `google-services.json` file from the project administrator and place it inside:
```
android/app/google-services.json
```
>  The app will not run without this file.

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Connect a Device
Connect a physical Android device via USB with USB debugging enabled, or launch an Android emulator.
```bash
flutter devices
```

### Step 5: Run the Application
```bash
flutter run
```
>  Run on Android device or emulator only. Web and desktop builds are not supported.

---

##  Test Credentials

| Account Type | Email | Password |
|-------------|-------|----------|
| Regular User | testuser@quickqueue.rw | (contact project admin) |
| Staff Member | stafftest@quickqueue.rw | (contact project admin) |

---

##  Project Structure

```
lib/
├── main.dart
├── app.dart
├── injection_container.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_styles.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── navigation/
│   │   └── app_routes.dart
│   └── utils/
│       └── validators.dart
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/
    │       └── screens/
    ├── queue/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/
    │       └── screens/
    ├── staff/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/
    │       └── screens/
    ├── profile/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/
    │       └── screens/
    └── location/
        ├── data/
        ├── domain/
        └── presentation/
            ├── bloc/
            └── screens/
```

---

##  Database Collections (Firestore)

| Collection | Purpose |
|-----------|---------|
| users | Registered user profiles and queue statistics |
| location | Service facilities (hospitals, banks, government offices) |
| services | Service types offered at each location |
| queues | Active queue sessions for each service |
| tickets | Virtual tickets issued to users |
| notifications | Real-time queue position alerts |
| analytics | Daily performance summaries for staff |
| skipReasons | Documented reasons for skipped patients |

---

##  Firebase Security Rules Summary

- **Unauthenticated users** cannot read or write any collection
- **Regular users** can only read and modify their own profile, tickets, and notifications
- **Staff members** have elevated permissions to manage queues and read all tickets
- **Staff accounts** can only be created by an administrator — not from the client app
- **Notifications** cannot be deleted to preserve audit history

---

##  Features

### User Side
- Register and sign in with email and password
- Browse service locations across Kigali
- Select a service and join the virtual queue remotely
- Receive a unique ticket number instantly
- Track real-time queue position and estimated wait time
- Get notified as turn approaches
- Submit rating and feedback after being served
- View personal queue history and time saved statistics

### Staff Side
- Secure staff login portal
- Live queue dashboard with current patient and waiting count
- Mark patients as served with one tap
- Skip patients with documented reasons
- Pause queue during breaks with automatic user notifications
- View daily analytics and hourly throughput charts
- Manage counter preferences and profile settings

---

##  Why QuickQueue?

Citizens in urban Rwanda spend an average of **2 to 4 hours** waiting in physical queues at hospitals, banks, and government offices. QuickQueue eliminates this by allowing users to hold their place in a queue digitally, live their lives normally while waiting, and arrive only when their turn is approaching.

---

##  Known Limitations

- Google Sign-In requires additional SHA certificate configuration for full deployment
- Push notifications via Firebase Cloud Messaging not yet implemented
- Analytics currently uses manually seeded test data rather than automated Cloud Functions
- Offline mode not yet implemented
- iOS build not yet configured

---

##  Report

The full project report is submitted as **Group5_Final_Project_Submission.pdf** alongside this repository.



*African Leadership University — Mobile Web Development — Group 5 — July 2026*