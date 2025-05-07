# Habit Builder App

A privacy-first, iOS 18+ habit tracker built with Swift 6 and SwiftUI.

## Overview
Habit Builder helps users build and maintain positive habits through a friendly, intuitive interface. All data is stored locally—no sign-up, no cloud, just you and your goals.

## Features
- **Onboarding:** Friendly, accessible onboarding for new users
- **Habit Creation:** Name, icon, color, frequency, and optional daily reminder
- **Dashboard:** List of all habits, with completion status and quick actions
- **Progress Tracking:** Detail view with calendar, streaks, and completion rate
- **Reminders:** Local notifications for daily habit reminders
- **Editing & Deleting:** Full habit management, with notification updates
- **Settings:** Notification permissions, app info, privacy policy
- **Accessibility:** Dynamic Type, VoiceOver, color contrast, haptics
- **Privacy:** All data is stored on-device using UserDefaults (MVP)

## Architecture
- **SwiftUI-first**: All UI is built with SwiftUI
- **MVVM**: Modular, testable, and scalable
- **Local Storage**: UserDefaults for MVP, easily upgradable to Core Data/SwiftData
- **Notifications**: UNUserNotificationCenter for reminders
- **Modular Structure**: Core, Modules (Habits, Onboarding, Settings), SharedUI, Resources

## Setup
1. **Requirements:**
   - Xcode 16+
   - iOS 18+ (iPhone only)
   - Swift 6
2. **Clone the repo:**
   ```sh
   git clone <your-repo-url>
   ```
3. **Open in Xcode:**
   - Open the `.xcodeproj` or `.xcworkspace` file
4. **Configure Info.plist:**
   - Ensure `NSUserNotificationUsageDescription` is set for reminders
   - Set your app icon and launch screen in `Assets.xcassets`
   - Update the privacy policy link in Settings
5. **Build & Run:**
   - Select an iPhone simulator or device and run the app

## App Store Readiness
- All user data is private and local
- All permissions are explained and requested in context
- Fully accessible and localization-ready
- No debug prints or placeholder text in production
- App icon and launch screen included

## License
MIT (or your preferred license) 