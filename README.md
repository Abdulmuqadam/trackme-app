# TrackMe App

> **An emergency safety & tracking platform** connecting people in distress with nearby facilitators in real time.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Tech Stack](#tech-stack)
5. [Project Structure](#project-structure)
6. [Getting Started](#getting-started)
7. [Configuration](#configuration)
8. [App Screens & Flow](#app-screens--flow)
9. [Known Bugs Fixed](#known-bugs-fixed)
10. [API Endpoints](#api-endpoints)
11. [Deployment](#deployment)
12. [Contributing](#contributing)

---

## Overview

**TrackMe** is a cross-platform Flutter mobile application paired with a Node.js REST + WebSocket backend. It enables two distinct user roles:

| Role | Purpose |
|---|---|
| **User** | Reports an emergency query (home invasion, medical help, fire, travel emergency), shares location and a voice note, and tracks the assigned facilitator on a live map. |
| **Facilitator** | Receives assigned emergency queries, navigates to the requester's location via a live map, and marks each query as complete. |

Both roles communicate in real time through an in-app chat powered by Socket.io.

---

## Features

### User Features

- 🆘 **Emergency Query Submission** — choose from four emergency categories (Home Invasion, Medical Help, Fire Extinguisher, Travel Emergency).
- 🎙️ **Voice Note Attachment** — record and attach an audio description to each query.
- 📍 **Live Location Sharing** — automatic background location reporting so the assigned facilitator can navigate to the user.
- 📞 **SMS to Contacts** — send a location link via SMS to a chosen contact for additional safety.
- 🗺️ **Map View** — see the facilitator's real-time position and a polyline route between the two parties.
- 💬 **Real-time Chat** — instant messaging with the assigned facilitator via Socket.io.
- 📋 **Query History** — list all previously submitted queries with their status.

### Facilitator Features

- 📂 **Assigned Queries Dashboard** — view all emergency queries routed to this facilitator.
- ▶️ **Audio Playback** — listen to the user's voice note directly within the app.
- ✅ **Completion Toggle** — mark queries as resolved; status is synced to the backend.
- 🗺️ **Navigation Map** — polyline routing from the facilitator's live position to the requester.
- 💬 **Real-time Chat** — communicate with the user before or during the response.

### Common Features

- 🔐 **JWT Authentication** — secure login / registration for both user types.
- 👤 **Profile Management** — view and edit name, email.
- 📖 **Help & Support** and **Terms & Conditions** screens.
- 🌐 **Connectivity Check** — splash-screen network validation before app load.

---

## Architecture

```
┌───────────────────────┐          ┌──────────────────────────────┐
│   Flutter Frontend     │  HTTPS   │   Node.js Backend (REST)      │
│                        │◄────────►│   /api/users/*                │
│  Screens               │          │   /api/facilitators/*         │
│  ├─ SplashScreen       │          │   /api/queries/*              │
│  ├─ LoginScreen        │          └──────────────────────────────┘
│  ├─ UserSignupScreen   │
│  ├─ FacilitatorSignup  │  WSS     ┌──────────────────────────────┐
│  ├─ HomeScreen         │◄────────►│   Node.js Backend (Socket.io) │
│  │  ├─ UserHomeContent │          │   Event: "message"            │
│  │  └─ FacilitatorHome │          └──────────────────────────────┘
│  ├─ MapPage            │
│  ├─ ChatScreen         │  SharedPreferences (local)
│  ├─ ProfileScreen      │  jwt_token, user_id, user_type,
│  └─ QueriesListPage    │  location, facilitator_location,
│                        │  facilitator_id, username
│  Misc                  │
│  ├─ UserService        │
│  ├─ LocationFetcher    │
│  ├─ AudioManager       │
│  └─ UserBloc (Cubit)   │
└───────────────────────┘
```

### State Management

| Layer | Technology |
|---|---|
| User-type selection (login toggle) | `flutter_bloc` (Cubit) |
| Chat messages | `provider` (`ChangeNotifier`) |
| Location & query state | `StatefulWidget` + `SharedPreferences` |

---

## Tech Stack

### Frontend (Flutter)

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC/Cubit state management |
| `provider` | Chat message state |
| `google_maps_flutter` | Map rendering |
| `location` | Device GPS |
| `flutter_sound` | Audio recording on query-send screen |
| `audioplayers` | Audio playback in facilitator cards |
| `socket_io_client` | Real-time chat |
| `http` / `dio` | REST API calls / audio download |
| `shared_preferences` | Persistent session storage |
| `permission_handler` | Runtime permission requests |
| `fluttercontactpicker` | Pick emergency SMS contact |
| `url_launcher` | Open SMS intent |
| `custom_info_window` | Custom map marker pop-overs |
| `line_awesome_flutter` | Icon set |
| `intl` | Date / time formatting |

### Backend (Node.js — `backend_app_nodejs/`)

> The backend directory is currently a placeholder. The live API is hosted at the URL configured in `lib/misc/const.dart`.

Expected backend structure:

```
backend_app_nodejs/
├── routes/
│   ├── users.js          # /api/users/login, register, verify, getuser
│   ├── facilitators.js   # /api/facilitators/login, register, verify, getfacilitator
│   └── queries.js        # /api/queries/save, getQueryByFacilitatorId,
│                         #   getquerybyusername, updatequerycomplete, updatelocation
├── models/               # ORM models (User, Facilitator, Query)
├── middleware/           # JWT verification
├── socket/               # Socket.io "message" event handler
└── index.js
```

---

## Project Structure

```
trackme-app/
├── README.md
├── backend_app_nodejs/        # Node.js backend (placeholder)
└── frontend_app_flutter/
    ├── lib/
    │   ├── main.dart           # App entry point; CupertinoTabScaffold
    │   ├── misc/
    │   │   ├── const.dart      # API URL, colour palette, HexColor helper
    │   │   ├── user_bloc.dart  # Cubit: normalUser <-> facilitatorUser
    │   │   ├── user_service.dart  # Fetches & caches user profile
    │   │   ├── audioManager.dart  # record package wrapper
    │   │   ├── recorder.dart      # audio_waveforms controller
    │   │   └── flash_message_screen.dart  # Custom SnackBar widget
    │   └── screens/
    │       ├── splash_screen.dart      # JWT verification + redirect
    │       ├── login_screen.dart       # Login form (user / facilitator toggle)
    │       ├── user_signup.dart        # New user registration
    │       ├── facilitator_signup.dart # New facilitator registration
    │       ├── user_home.dart          # Emergency category card grid
    │       ├── facilitator_home.dart   # Assigned queries card list
    │       ├── query_send.dart         # Submit query with text + audio
    │       ├── queries_list.dart       # User's historical queries
    │       ├── map_page.dart           # Google Maps + polyline tracking
    │       ├── chat_screen.dart        # Socket.io real-time chat
    │       ├── profile_screen.dart     # Profile info + logout
    │       ├── update_profile.dart     # Edit profile form
    │       ├── help_and_support.dart   # FAQ / support page
    │       ├── terms_and_conditions.dart
    │       └── location_fetcher.dart   # Background GPS + periodic upload
    ├── assets/
    │   ├── fonts/Poppins/      # Poppins font family
    │   ├── images/             # Emergency category images, logo
    │   ├── icons/icon.png      # App icon
    │   └── ca/lets-encrypt-r3.pem  # TLS certificate pinning
    └── pubspec.yaml
```

---

## Getting Started

### Prerequisites

| Tool | Minimum Version |
|---|---|
| Flutter SDK | 3.3.0 |
| Dart SDK | 3.3.0 |
| Android SDK | API 21+ |
| Xcode (iOS) | 14+ |
| Google Maps API Key | — |

### 1. Clone the repository

```bash
git clone https://github.com/Abdulmuqadam/trackme-app.git
cd trackme-app/frontend_app_flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure secrets (see [Configuration](#configuration))

### 4. Run

```bash
# Android
flutter run

# iOS (requires macOS + Xcode)
flutter run -d ios
```

---

## Configuration

### API Base URL

Edit `lib/misc/const.dart`:

```dart
const String Api_Link = "https://your-backend-domain.com";
```

### Google Maps API Key

**Android** — `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

> ⚠️ **Never commit real API keys to version control.** Use environment variables or a secrets manager.

### TLS Certificate Pinning

The app pins the Let's Encrypt R3 intermediate certificate. If your backend uses a different CA, replace `assets/ca/lets-encrypt-r3.pem` with the appropriate PEM file.

---

## App Screens & Flow

```
App Launch
  └─► SplashScreen
        ├─ No JWT token  ──────────────────► LoginScreen
        │                                        ├─ User Login  ──► MainPage (UserHome)
        │                                        ├─ Facilitator Login ─► MainPage (FacilitatorHome)
        │                                        └─ Sign Up ─► UserSignup / FacilitatorSignup
        └─ Valid JWT      ─────────────────► MainPage
               ┌──────────────────────────────────────┐
               │           CupertinoTabBar              │
               │  Home | Location | Messages | Account  │
               └──────────────────────────────────────┘
                  │           │          │          │
             HomeScreen   MapPage   ChatScreen  ProfileScreen
             (User)
              └─ UserCardView
                  └─ QuerySendPage
                      └─ TextBox (text + audio + SMS)
             (Facilitator)
              └─ FacilitatorCardView
                  └─ FacilitatorCards (info dialog + audio + toggle)
```

---

## Known Bugs Fixed

The following bugs were identified and corrected:

| # | File | Bug | Fix |
|---|---|---|---|
| 1 | `misc/user_bloc.dart` | `toggleUserType()` always emitted `UserType.normalUser` regardless of current state (inverted ternary branch) | Corrected ternary to emit `facilitatorUser` when state is `normalUser` |
| 2 | `screens/login_screen.dart` | Regular-user login did not persist `user_type = "user"` to `SharedPreferences`, causing role detection to fail on subsequent launches | Added `prefs.setString("user_type", "user")` after successful user login |
| 3 | `screens/profile_screen.dart` | Username stored without a space: `firstname + "" + lastname` produced `"JohnDoe"` | Changed to `firstname + " " + lastname` |
| 4 | `screens/query_send.dart` | `late String filePath` threw `LateInitializationError` if user tapped **Send** before recording any audio | Changed to `String? filePath`; added null-guard with a user-visible snackbar before calling `sendData` |
| 5 | `screens/facilitator_home.dart` | Audio download URL hardcoded to a specific domain instead of the configurable `Api_Link` constant | Replaced with `$Api_Link/${widget.audioData}` |
| 6 | `screens/chat_screen.dart` | Socket.io callbacks called bare `print()` in release builds, leaking debug info | Wrapped with `if (kDebugMode)` guards |
| 7 | `screens/map_page.dart` | `late LatLng _source` could throw `LateInitializationError` if `_addPolylines` was called before `facilitatorLocation()` resolved | Initialised `_source = const LatLng(0.0, 0.0)` at declaration; removed duplicate declaration |
| 8 | `screens/splash_screen.dart` | `prefs.setInt("user_id", data["userId"])` called before checking `response.statusCode`, crashing on error responses without `userId`; also missing `mounted` guards on async `Navigator` calls | Moved userId save inside `statusCode == 200` branch with null guard; added `if (!mounted) return` before all async navigations |
| 9 | `screens/login_screen.dart` | Form field label/border colours hard-coded to an old green value instead of the app theme | Replaced hard-coded `Color.fromRGBO(14, 116, 57, 1)` with `secondaryColor` from `const.dart` |

---

## API Endpoints

The following REST endpoints are consumed by the Flutter app:

### Users

| Method | Path | Description |
|---|---|---|
| POST | `/api/users/login` | Authenticate user, returns JWT + userId |
| POST | `/api/users/register` | Create new user account |
| POST | `/api/users/verify` | Verify JWT token, returns userId |
| POST | `/api/users/getuser` | Fetch user profile by userId |
| PUT | `/api/users/updateuser` | Update user profile |

### Facilitators

| Method | Path | Description |
|---|---|---|
| POST | `/api/facilitators/login` | Authenticate facilitator, returns JWT + userId |
| POST | `/api/facilitators/register` | Create new facilitator account |
| POST | `/api/facilitators/verify` | Verify facilitator JWT |
| POST | `/api/facilitators/getfacilitator` | Fetch facilitator profile by userId |

### Queries

| Method | Path | Description |
|---|---|---|
| POST | `/api/queries/save` | Submit new emergency query (multipart: text, querytype, postedBy, location, audio) |
| POST | `/api/queries/getQueryByFacilitatorId` | Get all queries assigned to a facilitator |
| POST | `/api/queries/getquerybyusername` | Get all queries submitted by a user |
| POST | `/api/queries/updatequerycomplete` | Toggle query completion status |
| POST | `/api/queries/updatelocation` | Update facilitator's live location |

### WebSocket (Socket.io)

| Event | Direction | Payload |
|---|---|---|
| `message` | Bidirectional | `{ message, username, sentAt }` |

---

## Deployment

### Backend

The Node.js backend should be deployed behind HTTPS with:

- JWT secret stored as an environment variable (`JWT_SECRET`)
- A relational or NoSQL database for Users, Facilitators, and Queries
- Static file serving for uploaded audio files (returned as relative paths under `/uploads/`)
- Socket.io configured with CORS for the Flutter app's origin

### Frontend

Build release APK / IPA:

```bash
# Android
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/)
4. Open a Pull Request against `main`

---

*TrackMe — Keeping people safe, one location at a time.*
