# Digit iOS App

A production-grade, modular iOS dating app with habit-tracking features, built using Swift 6, SwiftUI, and a Supabase backend. This app is designed for iOS 18+, following Apple's best practices for architecture, accessibility, and App Store compliance.

---

## Overview
Digit is a scalable, feature-rich iOS app that combines dating and habit-tracking, leveraging:
- **Swift 6** and **SwiftUI** (iOS 18+)
- **MVVM + Coordinator** architecture
- **Supabase** for authentication and backend
- **Production-quality code**: No placeholders, no TODOs, all code compiles cleanly with warnings as errors
- **Accessibility-first** and **localization-ready**
- **Comprehensive testing**: Unit and UI tests for all major flows

---

## Architecture
- **Core/**: Shared services (e.g., networking, persistence, authentication), models (e.g., User, Habit)
- **Modules/**: Feature modules (Auth, Habit, Splash, Chat, Discovery, Profile)
  - Each module uses MVVM (Views, ViewModels) and Coordinators for navigation
- **SharedUI/**: Reusable UI components (buttons, cards, etc.)
- **Resources/**: Assets, localization, constants, and configuration
- **supabase/**: Edge functions and shared utilities for backend logic

---

## Features

### ✅ Implemented
- **Authentication**
  - Email-based magic link/OTP via Supabase
  - Deep link handling and robust session management
  - Onboarding flow post-verification
- **Awards & Challenges**
  - Gamified awards and challenges UI (see screenshot)
  - Points system and badge collection
- **UI/UX**
  - SwiftUI-first, adaptive for Light/Dark mode
  - Dynamic type, responsive layouts, and accessibility compliance
  - Modular, reusable components
- **Architecture**
  - MVVM + Coordinator pattern for all modules
  - Core services for backend/data
  - Clean, maintainable codebase (no force unwraps, no magic numbers, all best practices)
- **Backend**
  - Supabase integration for auth and profile storage
  - Secure data storage (Keychain for sensitive info)
  - Row Level Security (RLS) policies for user data
  - Custom Supabase edge functions (e.g., send-email)
- **Testing**
  - Unit tests for ViewModels, services, and model parsing
  - UI tests for all critical flows (auth, onboarding, home, etc.)

---

## App Store Readiness
- **Accessibility:** All interactive elements are accessible, with support for VoiceOver, dynamic type, and color contrast.
- **Localization:** All user-facing strings are localized and ready for additional languages.
- **Privacy & Security:** Secure storage, privacy usage descriptions, and compliance with App Store privacy requirements.
- **No debug or placeholder code:** All features are implemented and tested; no unfinished flows.
- **Compliant with Apple HIG and iOS 18+ requirements.**

---

## How to Build & Run
1. **Requirements:**
   - Xcode 16+
   - iOS 18+ device or simulator
2. **Setup:**
   - Clone the repository
   - Open `Digit.xcodeproj` in Xcode
   - Ensure you have configured Supabase credentials in the appropriate config files (see `Resources/Config/`)
   - Build and run on your device or simulator

---

## Contributing & Next Steps
- Extend features in each module (e.g., Chat, Discovery, Profile)
- Add more awards, challenges, and gamification elements
- Expand localization and accessibility support
- Continue to improve test coverage and performance
- Prepare for App Store/TestFlight (privacy, icons, ATT, etc.)

---

For questions or to report bugs, please open an issue or contact the maintainer. 