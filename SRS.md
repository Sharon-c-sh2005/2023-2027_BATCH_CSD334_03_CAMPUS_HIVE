# Software Requirements Specification (SRS)
## Campus Hive — Peer Mentorship Mobile Application

**Version:** 1.0  
**Date:** 2025  
**Team:** Sharon C Shaji, M Aswathy, Devu , Anija T Anna

---

## 1. Introduction

### 1.1 Purpose
This document describes the software requirements for 
Campus Hive — a Flutter-based mobile application designed 
to connect college students through project collaboration, 
academic doubt solving, and campus event discovery.

### 1.2 Scope
The application serves three types of users — Students, 
Forum Admins, and Super Admin — each with different 
access levels and capabilities.

### 1.3 Definitions

| Term | Meaning |
|------|---------|
| Flutter | Google's UI framework for cross-platform apps |
| Firebase | Google's backend-as-a-service platform |
| Firestore | Firebase's NoSQL real-time cloud database |
| Stream | Continuous flow of real-time data from Firestore |
| Provider | Flutter state management package |
| Forum Admin | Club/forum representative who manages events |
| Super Admin | App administrator who approves forum admins |

---

## 2. System Requirements

### 2.1 Software Requirements to RUN this app

| Software | Minimum Version | Purpose |
|----------|----------------|---------|
| Android OS | 5.0 (API 21) | Mobile operating system |
| iOS | 12.0 | Mobile operating system (if needed) |
| Internet Connection | Any | Firebase real-time sync |
| Google Account | Any | Google Sign-In feature |

### 2.2 Software Requirements to DEVELOP this app

| Software | Version | Purpose | Download |
|----------|---------|---------|----------|
| Flutter SDK | 3.0+ | App framework | flutter.dev |
| Dart SDK | 3.0+ | Programming language | Included with Flutter |
| Android Studio | Latest | IDE + emulator | developer.android.com |
| VS Code | Latest | Code editor (alternative) | code.visualstudio.com |
| Git | Latest | Version control | git-scm.com |
| Android SDK | API 33+ | Build tools | Via Android Studio |
| Java JDK | 11+ | Android build requirement | adoptium.net |

### 2.3 Firebase Services Used

| Service | Purpose |
|---------|---------|
| Firebase Authentication | User login, signup, Google Sign-In |
| Cloud Firestore | Real-time database for all app data |
| Firebase Storage | Store chat images |
| Firebase Core | Base Firebase initialization |

### 2.4 Flutter Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | Latest | Initialize Firebase |
| firebase_auth | Latest | Authentication |
| cloud_firestore | Latest | Database |
| firebase_storage | Latest | Image storage |
| provider | ^6.1.2 | State management |
| google_sign_in | Latest | Google OAuth |
| google_fonts | ^6.2.1 | Inter font family |
| url_launcher | ^6.2.5 | Open Google Forms |
| image_picker | Latest | Pick images from gallery |
| intl | ^0.19.0 | Date and time formatting |
| shimmer | ^3.0.0 | Loading skeleton animations |
| timeago | ^3.7.0 | Relative time display |

---

## 3. Functional Requirements

### 3.1 Authentication Module

| ID | Requirement |
|----|------------|
| FR1 | User shall register with email and password |
| FR2 | User shall login with email and password |
| FR3 | User shall login with Google account |
| FR4 | User shall reset password via email |
| FR5 | New user shall complete profile setup before accessing app |
| FR6 | Forum admin shall submit account request for approval |
| FR7 | System shall route users based on their role |

### 3.2 Project Zone Module

| ID | Requirement |
|----|------------|
| FR8 | Student shall create projects with details and cover image |
| FR9 | Student shall browse all live projects |
| FR10 | Student shall search projects by name |
| FR11 | Student shall filter projects by category and status |
| FR12 | Student shall join open projects directly |
| FR13 | Student shall send join request for approval-required projects |
| FR14 | Project owner shall accept or decline join requests |
| FR15 | Project owner shall change project status |
| FR16 | Project owner shall delete the project |
| FR17 | Project owner shall transfer ownership to a member |
| FR18 | All members shall access the project group chat |
| FR19 | Chat shall support text and image messages |
| FR20 | System shall show unread message count on project tile |
| FR21 | System shall log all project activities |

### 3.3 AskHub Module

| ID | Requirement |
|----|------------|
| FR22 | Student shall post doubts with title, body, and tags |
| FR23 | Student shall reply to doubts |
| FR24 | Student shall upvote or downvote doubts and replies |
| FR25 | Student shall filter doubts by Hot, Recent, Unsolved |
| FR26 | Student shall search doubts by keyword |
| FR27 | Author shall delete their own doubts and replies |

### 3.4 Events Module

| ID | Requirement |
|----|------------|
| FR28 | Student shall browse events filtered by category |
| FR29 | Student shall view full event details |
| FR30 | Student shall register for events via Google Form |
| FR31 | System shall prevent duplicate event registration |
| FR32 | System shall show Registered status after registration |
| FR33 | Forum admin shall create events for their forum |
| FR34 | Forum admin shall view registrations for their events |
| FR35 | Super admin shall approve forum admin requests |
| FR36 | Super admin shall reject forum admin requests |

---

## 4. Non-Functional Requirements

| ID | Requirement | Target |
|----|------------|--------|
| NFR1 | App should load within 3 seconds | Performance |
| NFR2 | Real-time updates within 1 second | Performance |
| NFR3 | All user data protected by Firebase Auth | Security |
| NFR4 | Role-based access control enforced | Security |
| NFR5 | Consistent UI using Inter font and AppColors | Usability |
| NFR6 | App works on Android 5.0 and above | Compatibility |
| NFR7 | App works without internet for cached data | Reliability |

---

## 5. System Architecture
```
┌─────────────────────────────────┐
│         Flutter App              │
│  ┌─────────────────────────┐    │
│  │   main.dart (Router)     │    │
│  └────────────┬────────────┘    │
│               │                  │
│  ┌────────────▼────────────┐    │
│  │   ProjectZonePage        │    │
│  │   (4-tab IndexedStack)   │    │
│  │                          │    │
│  │  Projects │ AskHub       │    │
│  │  Events   │ Profile      │    │
│  └──────────────────────────┘   │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│         Firebase                 │
│                                  │
│  Auth → Firestore → Storage      │
└──────────────────────────────────┘
```

---

## 6. Database Collections

| Collection | Fields | Purpose |
|------------|--------|---------|
| users | uid, email, displayName, role, profileComplete, college, branch | User profiles |
| projects | title, description, ownerId, members[], status, techStack[], activities[] | Student projects |
| doubts | title, body, tags[], authorId, upvotes, downvotes, replyCount | Academic doubts |
| replies | body, authorId, upvotes, downvotes, parentReplyId | Doubt replies |
| events | title, description, forumId, startDate, maxParticipants, registeredCount | College events |
| registrations | eventId, userId, userName, userEmail, status | Event registrations |
| forums | name, adminIds[], isActive | Forum/club details |
| forum_requests | userId, forumName, reason, status | Admin account requests |

---

## 7. Data Flow
```
User Action
    ↓
Flutter Widget (UI)
    ↓
Service Class (ProjectService / EventService / FirebaseService)
    ↓
Firestore Database
    ↓
Stream / Future returns data
    ↓
StreamBuilder / FutureBuilder rebuilds UI
    ↓
User sees updated screen
```

---

## 8. Development Environment Setup

### Step 1 — Install Flutter
```
Download from flutter.dev
Run: flutter doctor
All checks should pass
```

### Step 2 — Install Android Studio
```
Download from developer.android.com
Install Android SDK
Create an emulator (API 33 recommended)
```

### Step 3 — Clone and Setup Project
```bash
git clone https://github.com/Sharon-c-sh2005/CampusHive.git
cd CampusHive
flutter pub get
```

### Step 4 — Firebase Setup
```
1. Go to console.firebase.google.com
2. Create a new project OR use existing
3. Add Android app with package name
4. Download google-services.json
5. Place in android/app/ folder
6. Enable Authentication (Email + Google)
7. Create Firestore database
8. Enable Firebase Storage
```

### Step 5 — Run
```bash
flutter run
```
```

---

# STEP 4 — Create `.gitignore` file

Make sure your `.gitignore` has these (Flutter creates it automatically but verify):
```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
*.iml

# Android
android/.gradle/
android/local.properties
android/key.properties

# iOS
ios/Pods/
ios/.symlinks/

# Firebase — IMPORTANT keep these private
google-services.json
GoogleService-Info.plist

# IDE
.idea/
.vscode/
*.swp
