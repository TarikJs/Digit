# Digit Habit Tracking App – Project Context

Digit is an intuitive, iOS-native habit-tracking app designed to help users focus on building one important habit or task at a time. The app emphasizes simplicity, clarity, and a delightful user experience, leveraging modern Apple technologies and a robust backend.

---

## Official Color Palette

> All app color definitions are maintained in `SharedUI/Color+Digit.swift` for a single source of truth.

- **Background color:**
  - HEX: #FFFFFF
  - RGB: 255, 255, 255
- **Brand color:**
  - HEX: #000000
  - RGB: 0, 0, 0
- **Secondary text:**
  - HEX: #6B7280
  - RGB: 107, 114, 128

- **Habit Progress Greens:**
  - #E9F6E2 (233, 246, 226)
  - #B6E3A1 (182, 227, 161)
  - #6CC644 (108, 198, 68)
  - #44A340 (68, 163, 64)
  - #216E39 (33, 110, 57)

- **Accent Green:**
  - #44A340 (68, 163, 64)

## Recent Implementation Details

### Legal Documents
- Legal documents (Privacy Policy, Terms of Service, Licenses) are stored as markdown strings in `Core/Models/LegalDocuments.swift`.
- Displayed in-app using SwiftUI's markdown rendering for accessibility and a native look.

### Settings/Profile
- Profile display name logic: shows "Profile" as a placeholder if the name is missing, otherwise "FirstName L.".
- Email verification status is checked against the Supabase `profiles` table and shown in the settings.
- All user-facing strings are localized; UI supports Light/Dark Mode and Dynamic Type.

### Statistics
- The stats view uses Swift Charts for a modern, branded bar chart.
- Chart is styled with brand colors, supports dark mode, and features detailed Y-axis ticks.

### Architecture
- MVVM + Coordinators pattern for clear separation of concerns.
- Shared models/services in `Core/`, reusable UI in `SharedUI/`.
- No force unwraps, no print statements, no global mutable state (except AppCoordinator).
- SwiftLint and Apple best practices enforced.

### Testing
- Unit and UI tests cover all critical flows.
- Dependency injection and protocol-oriented design for testability.

### Supabase Integration
- Authentication and user data (including email verification) managed via Supabase.
- App queries Supabase for user status, profile info, and progress.

## Supabase Integration

### Overview
- **Supabase** is the backend for authentication, user profiles, habit data, and progress tracking.
- The app uses the official Supabase Swift SDK for all network/database operations.
- All Supabase logic is encapsulated in service classes under `Core/Services/` for modularity and testability.

### Authentication
- **User authentication** is handled via Supabase Auth, supporting email/password and Apple sign-in.
- The app uses `SupabaseManager.shared.client.auth` for session management and user ID retrieval.
- Deep links for authentication (e.g., email verification) are handled in `DigitApp.swift` via `.onOpenURL`.

### User Profiles
- **Profiles** are stored in the Supabase `profiles` table.
- `SupabaseProfileService` provides:
  - `fetchProfile()`: Loads the current user's profile from Supabase.
  - `updateProfile(_:)`: Updates the user's profile in Supabase.
- The app checks the `profiles` table for email verification status and displays it in the settings.

### Habits
- **Habits** are stored in the Supabase `habits` table.
- `HabitService` provides:
  - `fetchHabits()`: Loads all habits for the current user.
  - `addHabit(_:)`, `updateHabit(_:)`, `deleteHabit(id:)`: CRUD operations for habits.
  - `getCurrentHabit(for:)`: Fetches the most recent habit for a user.
- The `Habit` model matches the Supabase schema, including all relevant fields and date handling.

### Habit Progress
- **Habit progress** is tracked in the Supabase `habit_progress` table.
- `HabitProgressService` provides:
  - `fetchProgress(userId:habitId:date:)`: Loads progress for a specific habit and date.
  - `upsertProgress(progress:)`: Inserts or updates progress for a habit.
  - `fetchProgressForRange(userId:habitId:startDate:endDate:)`: Loads progress over a date range.
- All date handling is UTC and matches Supabase/Postgres conventions.

### Supabase Client Management
- `SupabaseManager.shared.client` is the singleton instance for all Supabase operations.
- All services use dependency injection for the client, allowing for easy testing and mocking.

### Edge Functions
- Custom backend logic (e.g., sending emails) is implemented as Supabase Edge Functions in `supabase/functions/`.
- Example: `send-email` function for transactional or notification emails.

### Error Handling
- All Supabase service methods use `async/await` and throw errors for robust error handling.
- Custom error enums (e.g., `HabitServiceError`, `SupabaseError`) provide user-friendly error messages and debugging info.

### Data Privacy & Security
- All user data is securely stored in Supabase.
- The app never stores sensitive data locally except as required for session management.
- All network requests are encrypted via HTTPS.

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