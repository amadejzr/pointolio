# Pointolio

**Pointolio** is an Flutter app for keeping track of game scores.

## Why Pointolio?

 I decided to build this app because I play card games with my friends and we were mostly tracking scores in the Notes app. Yes I know there are many apps that already do this, but I wanted to build my own my way and also show you how I build things. 
 
 I hope you’ll learn something from this project. Feel free to ask questions, suggest improvements, or share ideas.


 ## How it started

When I started it there was one goal create an app that will keep the scores of games we play, no sketches no ideas written. I'm not a designer so a big thanks to AI, for helping with the design :).

At the beginning, I didn't focus much on logging or error handling, proper reusability... The goal was to ship something as early as possible. Over time, I plan to improve the project with proper error handling, logging, tests...

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Bloc** - State management solution for predictable state management
- **Drift** - Reactive persistence library for local database storage
- **Offline-first** - All data is stored locally, works without internet connection

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK installed

### Running the App

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate code** (for Drift database and Bloc)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development

When making changes to Drift database models or Bloc classes, run the build runner in watch mode:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Screenshot Generation

This project includes automated screenshot generation for App Store using integration tests:

### Generate iPhone Screenshots

```bash
flutter drive --driver=screenshots/driver.dart --target=screenshots/screenshot_test.dart
```

Screenshots will be saved to `screenshots/output/output-ios/`

### Generate iPad Screenshots

```bash
flutter drive --driver=screenshots/driver.dart --target=screenshots/screenshot_test.dart -- ipad
```

Screenshots will be saved to `screenshots/output/output-ipad/`

### Styling Screenshots

After generating screenshots:
- iPhone: Open `screenshots/output/appstore_screenshots.html` to view styled screenshots
- iPad: Open `screenshots/output/output-ipad/appstore_ipad_screenshots.html` to view styled screenshots

Each HTML template applies beautiful backgrounds and frames to the screenshots, ready for App Store submission.
