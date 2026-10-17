# EduPulse

A cross-platform e-learning app built with Flutter, Riverpod, GoRouter and a local SQLite database.

## Features

- **Sign up / log in** – form validation for name, email and password strength.
  Authentication is currently a local mock: any validated credentials are accepted and the
  session is stored in SharedPreferences. There is no backend yet.
- **Course catalogue** – browse sample courses, search by title and filter by difficulty.
- **Enrollment** – enroll in courses and see them under *My Courses*.
- **Lesson progress** – mark lessons complete; course progress is recalculated automatically.
- **Profile** – view your details and set a profile picture.
- **Theme** – light, dark or system theme, persisted between launches. The colour scheme is
  generated from the app logo.
- **Quote of the day** – fetched from [dummyjson.com](https://dummyjson.com) on the home screen.

Course and lesson data is seeded into SQLite on first launch.

## Project structure

```
lib/
  core/        database helper, theme provider, validators
  features/    auth, dashboard (courses, enrollment, progress), profile
  routes/      GoRouter configuration
  main.dart
landing/       static landing page
```

## Getting started

Requires a Flutter SDK with Dart 3.12 or newer.

```bash
git clone https://github.com/m-m4h4d/edupulse.git
cd edupulse
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Roadmap

- Real authentication and a backend for syncing progress
- Per-user enrollment and progress data
- Quizzes and assignments
- Notifications
