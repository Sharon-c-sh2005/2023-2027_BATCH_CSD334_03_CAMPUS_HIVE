# 🐝 Campus Hive

**A Flutter-based Peer Mentorship & Campus Community App**

Campus Hive connects college students through project 
collaboration, academic doubt solving, and college event 
discovery — all in one integrated mobile application.

---

## 📱 App Overview

| Feature | Description |
|---------|-------------|
| 🗂️ Projects | Create, browse, and join student projects with group chat |
| 💬 AskHub | Post academic doubts, reply, and vote on answers |
| 📅 Events | Browse and register for college events |
| 👥 Role System | Student, Forum Admin, Super Admin access levels |

---

## ✨ Features

### 🗂️ Project Zone (My Section)
- Browse all live student projects with search and filter
- Create new projects with title, description, tech stack,
  cover image, and categories
- Join open projects or send a join request
- Project detail page with live real-time updates via 
  Firestore streams
- Project group chat with text and image messaging
- Unread message count badge on project tiles
- Owner can accept or decline join requests
- Owner can change project status (Active / On Hold / Finished)
- Owner can delete project or transfer ownership
- Activity log for every project action

### 💬 AskHub (Doubt Hub)
- Post academic doubts with title, body, and tags
- Reply to doubts with nested replies
- Upvote and downvote doubts and replies
- Filter by Hot, Recent, Unsolved
- Real-time updates — new doubts appear instantly

### 📅 Events
- Browse college events filtered by category
- View event details — date, time, venue, fee, spots
- Register for events via Google Form integration
- Forum admins create and manage events
- Super admin approves forum admin account requests

---

## 👥 Team & Contributions

| Name | Role | Section |
|------|------|---------|
| Sharon | Developer | Project Zone, Group Chat |
| [Teammate 1] | Developer | Doubt Hub (AskHub) |
| [Teammate 2] | Developer | Events, Auth, Admin |

---

## 🔐 User Roles

| Role | What They Can Do |
|------|-----------------|
| Student | Browse projects, doubts, events. Join projects. Chat. |
| Forum Admin | Create and manage events for their forum/club |
| Super Admin | Approve or reject forum admin account requests |

---

## 🔗 How Sections Are Integrated

All three sections are integrated inside `project_zone_page.dart`
using a single `IndexedStack` with 4 tabs:
```
ProjectZonePage (IndexedStack)
├── Tab 0 → Projects (project_zone_page.dart)
├── Tab 1 → AskHub  (doubt_hub/screens/home_screen.dart)
├── Tab 2 → Events  (events/screens/home/explore_tab.dart)
└── Tab 3 → Profile (doubt_hub/screens/profile_screen.dart)
```

All sections share:
- Same Firebase Authentication
- Same Firestore `users` collection
- Same Inter font and AppColors theme
- Profile tab shows data from all three sections

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform mobile framework |
| Dart | 3.x | Programming language |
| Firebase Auth | Latest | User authentication |
| Cloud Firestore | Latest | Real-time NoSQL database |
| Firebase Storage | Latest | Image storage for chat |
| Provider | 6.x | State management |
| Google Fonts | 6.x | Inter font family |
| Google Sign In | Latest | Google OAuth login |
| url_launcher | 6.x | Open Google Forms in browser |
| image_picker | Latest | Pick images for chat |
| intl | 0.19.x | Date formatting |

---

## 📂 Project Structure
```
lib/
├── main.dart                    # App entry, Firebase init, routing
├── firebase_options.dart        # Firebase configuration
│
├── auth/                        # Authentication
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── login_page.dart          # Login screen
│   ├── signup_page.dart         # Signup screen
│   ├── profile_setup_page.dart  # First-time profile setup
│   ├── forum_request_page.dart  # Forum admin account request
│   └── pending_approval_page.dart
│
├── projects/                    # Project Zone (My Section)
│   ├── models/
│   │   └── project_model.dart   # Project data model
│   ├── screens/
│   │   ├── project_zone_page.dart  # Main 4-tab shell
│   │   ├── project_detail_page.dart
│   │   └── create_project_page.dart
│   ├── services/
│   │   └── project_service.dart # All Firestore operations
│   └── widgets/
│       ├── my_projects_section.dart
│       ├── my_project_tile.dart
│       ├── live_projects_feed.dart
│       ├── category_pills.dart
│       └── filter_sheet.dart
│
├── chat/                        # Group Chat (Projects)
│   ├── chat_page.dart
│   ├── chat_service.dart
│   └── models/
│       └── message_model.dart
│
├── doubt_hub/                   # AskHub Section
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   └── utils/
│
└── events/                      # Events Section
    ├── models/
    ├── screens/
    ├── services/
    ├── utils/
    └── widgets/
```

---

## ⚙️ How to Run

### Prerequisites
- Flutter SDK (3.0 or above)
- Android Studio or VS Code
- Android device or emulator (API 21+)
- A Firebase project

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/Sharon-c-sh2005/CampusHive.git
cd CampusHive
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Add Firebase configuration**

Add your `google-services.json` to `android/app/`

**4. Run the app**
```bash
flutter run
```

---

## 🗄️ Firestore Database Structure
```
users/{uid}
projects/{projectId}
  └── activities[]
doubts/{doubtId}
  └── replies/{replyId}
events/{eventId}
registrations/{regId}
forums/{forumId}
forum_requests/{requestId}
```

---

## 📸 Screenshots

*(Screenshots will be added here)*

---

## 📄 License

This project was developed as part of a college academic project.
