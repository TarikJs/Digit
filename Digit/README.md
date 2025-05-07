# Habit Builder App

[![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)](https://swift.org) [![iOS](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)](https://developer.apple.com/ios/) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Repository

[Digit on GitHub](https://github.com/TarikJs/Digit/tree/main/Digit)

---

A **privacy-first, iOS 18+ habit tracker** built with Swift 6 and SwiftUI.

---

## ✨ Overview

Habit Builder helps users build and maintain positive habits through a friendly, intuitive interface. All data is stored locally—no sign-up, no cloud, just you and your goals.

---

## 🏆 Features

- **Onboarding:** Friendly, accessible onboarding for new users
- **Habit Creation:** Name, icon, color, frequency, and optional daily reminder
- **Dashboard:** List of all habits, with completion status and quick actions
- **Progress Tracking:** Detail view with calendar, streaks, and completion rate
- **Reminders:** Local notifications for daily habit reminders
- **Editing & Deleting:** Full habit management, with notification updates
- **Settings:** Notification permissions, app info, privacy policy
- **Accessibility:** Dynamic Type, VoiceOver, color contrast, haptics
- **Privacy:** All data is stored on-device using UserDefaults (MVP)

---

## 🏗️ Architecture

- **SwiftUI-first:** All UI is built with SwiftUI
- **MVVM:** Modular, testable, and scalable
- **Local Storage:** UserDefaults for MVP, easily upgradable to Core Data/SwiftData
- **Notifications:** UNUserNotificationCenter for reminders
- **Modular Structure:** Core, Modules (Habits, Onboarding, Settings), SharedUI, Resources

---

## 📁 Project Structure & Naming Conventions

Our project follows Apple and SwiftUI community best practices for folder structure and naming, supporting maintainability and scalability:

```text
Digit/
├─ Core/           # Shared models, notifications, persistence
├─ Modules/        # Feature modules (Habits, Onboarding, Settings, etc.)
│  ├─ Habits/
│  │   ├─ Views/
│  │   ├─ ViewModels/
│  │   └─ Models/
│  └─ ...
├─ SharedUI/       # Reusable UI components and extensions
│  ├─ Components/
│  └─ Extensions/
├─ Resources/      # Localized strings, assets, etc.
│  └─ Localized/
├─ Assets.xcassets # Images and color assets
├─ DigitApp.swift  # App entry point
├─ Info.plist
└─ README.md
```

- **Feature-based:** Each feature (e.g., Habits) has its own folder with Views, ViewModels, and Models.
- **Shared code:** Core/ for cross-cutting models/services, SharedUI/ for reusable UI.
- **Resources:** All assets and localization in Resources/ and Assets.xcassets.

### Naming Conventions

- **Views:** End with `View` (e.g., `HabitCreateView.swift`)
- **ViewModels:** End with `ViewModel` (e.g., `HabitCreateViewModel.swift`)
- **Models:** Named as entities (e.g., `Habit.swift`)
- **Services/Managers:** End with `Service` or `Manager` (e.g., `NotificationService.swift`)
- **Extensions:** Named as `Type+Extensions.swift` (e.g., `String+Extensions.swift`)
- **Assets:** Lowercase with underscores or hyphens (e.g., `icon_habit`, `background_main`)
- **One type per file:** Each file contains one main type for clarity.

---

## 📚 References & Best Practices

- [Apple Developer: Get Started with iOS](https://developer.apple.com/ios/get-started/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [MVVM and Feature-based SwiftUI Project Structure (Medium)](https://medium.com/)
- [SwiftGen](https://github.com/SwiftGen/SwiftGen)
- [SwiftLint](https://github.com/realm/SwiftLint)

This structure ensures the codebase is easy to navigate, maintain, and scale as new features are added.

---

## 🛠️ Setup

1. **Requirements:**
    - Xcode 16+
    - iOS 18+ (iPhone only)
    - Swift 6
2. **Clone the repo:**
    ```sh
    git clone https://github.com/TarikJs/Digit.git
    ```
3. **Open in Xcode:**
    - Open the `.xcodeproj` or `.xcworkspace` file
4. **Configure Info.plist:**
    - Ensure `NSUserNotificationUsageDescription` is set for reminders
    - Set your app icon and launch screen in `Assets.xcassets`
    - Update the privacy policy link in Settings
5. **Build & Run:**
    - Select an iPhone simulator or device and run the app

---

## 🏁 App Store Readiness

- All user data is private and local
- All permissions are explained and requested in context
- Fully accessible and localization-ready
- No debug prints or placeholder text in production
- App icon and launch screen included

---

## 📄 License

MIT (or your preferred license) 