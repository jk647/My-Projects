# Taskura App

A Flutter task management application built with Hive local database, featuring file attachments, profile management, and responsive UI design.

## 📦 Folder Structure

```
lib/
├── constants/
│   ├── app_colors.dart
│   ├── app_decor.dart
│   ├── app_text_styles.dart
│   ├── custom_tap_feedback.dart
│   ├── tap_feedback_helpers.dart
│   └── theme_color.dart
├── models/
│   ├── task_model.dart
│   └── task_model.g.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── login/
│   │   └── login_screen.dart
│   ├── signup/
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── home_screen_widgets/
│   ├── add_task/
│   │   └── add_task_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── menu_options/
│   └── attachment_viewers/
├── services/
│   └── storage_service.dart
├── utils/
│   └── date_time_utils.dart
└── main.dart
```

## 🛠 Dependencies

- **Flutter SDK**: ^3.7.2
- **Hive**: ^2.2.3 → Local NoSQL database
- **Hive Flutter**: ^1.1.0 → Flutter integration
- **Shared Preferences**: ^2.5.3 → User preferences
- **Image Picker**: ^1.1.2 → Image selection
- **Image Cropper**: ^9.1.0 → Image editing
- **File Picker**: ^8.0.0+1 → File attachments
- **Video Player**: ^2.8.2 → Video playback
- **Audio Players**: ^5.2.1 → Audio playback
- **Google Fonts**: ^6.2.1 → Typography
- **Package Info Plus**: ^8.3.0 → App information

## ⚡ Features

- Task creation and management with categories
- Priority levels (Critical, High, Medium, Low)
- Date and time scheduling with reminders
- Recurring tasks (Daily, Weekly, Monthly, Yearly)
- File attachments (Images, Videos, Audio)
- Profile photo management with cropping
- Multi-selection for bulk operations
- Pin/unpin important tasks
- Search and filter functionality
- Dark theme with custom tap feedback
- Local storage with offline support
- Cross-platform (Android & iOS)

## 🧩 Folder Overview

**constants/**
Store app-wide constants, colors, decorations, and helper functions.

**models/**
Dart classes representing your data structures.
Example: TaskModel with Hive adapters.

**screens/**
UI screens organized by feature:
- splash_screen/
- login_screen/
- signup_screen/
- home_screen/
- add_task_screen/
- profile_screen/
- menu_options/

**services/**
Handles data storage and other services.
Example: StorageService for Hive operations.

**utils/**
Helper functions and utilities.
Example: DateTimeUtils for date formatting.

## 🚀 Getting Started

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/taskura_app.git
cd taskura_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

Make sure your device/emulator is connected.

## 📌 Notes

- Uses Hive for local data storage with offline support
- Custom tap feedback system for smooth interactions
- Profile photos support cropping and rotation
- File attachments include built-in media playback
- Multi-selection action bar for bulk operations
- All data is stored locally for privacy

## 👨‍💻 Developer

**Rabia Aziz**
- Flutter App Developer
- Software Engineering Student
- UI/UX Designer

---

**Made with ❤️ by Rabia Aziz**