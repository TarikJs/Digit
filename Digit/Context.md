# Digit Habit Tracking App – Project Context

Digit is an intuitive, iOS-native habit-tracking app designed to help users focus on building one important habit or task at a time. The app emphasizes simplicity, clarity, and a delightful user experience, leveraging modern Apple technologies and a robust backend.

---

## Official Color Palette

- **Background color:**
  - HEX: #FFFBF9
  - RGB: 255, 251, 249
- **Brand color:**
  - HEX: #23409A
  - RGB: 35, 64, 154
- **Accent color 1:**
  - HEX: #D1ED36
  - RGB: 209, 237, 54
- **Accent color 2:**
  - HEX: #F3DAFF
  - RGB: 243, 218, 255

---

## Tech Stack

- **Frontend:** SwiftUI (iOS Native, Swift 6, iOS 18+)
- **Backend/Database:** Supabase (Authentication, Realtime Sync, Data Storage)

---

## App Flow & User Journey

### 1. Splash Screen
- Minimal, branded splash screen.
- Auto-transitions after 1–2 seconds.

### 2. Authentication Page
- Clean interface for login/signup.
- **Login Options:**
  - Email login/signup
  - Sign in with Apple

### 3. Authentication Logic
- **Existing User Check:**
  - Query Supabase to check if user exists (by email or Apple ID).
  - If user exists: Redirect to main app view.
  - If not: Initiate signup flow.

### 4. Signup Flow
- **Email Signup:**
  - Collect name, email, birthday.
  - Submit to Supabase.
  - Confirm account creation.
- **Apple Signup:**
  - Use Apple authentication.
  - Receive and submit user data to Supabase.
  - Confirm account creation.

### 5. Main App Views
- **Home View:**
  - Habit summary, current focus, daily progress, motivational messages.
- **Statistics View:**
  - Detailed stats, charts, streaks, progress tracking.
- **Awards View:**
  - Achievements, badges, gamified elements.
- **Settings View:**
  - Profile, habit customization, notifications, privacy.

---

## Key Features

- **Single Habit Focus:** One primary habit/task at a time for improved concentration.
- **Daily Tracking:** Mark daily completion, sync to Supabase.
- **Progress Indicators:** Visual charts, calendars, streak counters.
- **Reminders:** Push notifications for daily habit completion.
- **Motivation & Engagement:**
  - Motivational quotes, personalized insights.
  - Rewarding animations on completion.

---

## Backend & Data Management

- **Supabase Integration:**
  - Secure authentication and storage.
  - Real-time data sync and updates.
  - Efficient querying for user status and progress.
- **Data Privacy:**
  - Transparent privacy and security measures, aligned with Apple guidelines.

---

## UI/UX Principles

- Minimal, clean design for usability.
- Intuitive navigation for seamless habit formation.
- Immediate visual feedback for user actions.
- Full support for Light/Dark Mode, Dynamic Type, and accessibility.

---

## Next Steps for Developer Implementation

1. **Supabase Backend:**
   - Define schema for users and habit tracking.
2. **SwiftUI Frontend:**
   - Implement screens for splash, authentication, home, stats, awards, and settings.
3. **Authentication & Data Handling:**
   - Integrate Supabase APIs for robust user auth and data sync.
4. **UI/UX Enhancements:**
   - Ensure smooth animations and transitions.
   - Prioritize accessibility and responsiveness.

---

This context file serves as a high-level reference for all contributors, ensuring alignment on the app's vision, architecture, and implementation priorities. 