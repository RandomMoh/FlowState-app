# FlowState

A minimalist, high-performance productivity app built with Flutter. Designed to help you manage tasks, track deep work sessions, and view your focus analytics without any distracting clutter.

## Features

- **Pomodoro Timer:** A clean, custom-painted focus timer to track your deep work sessions.
- **Task Management:** Add, edit, and reorder tasks with drag-and-drop support. Swipe to delete.
- **Stats & Analytics:** Visual charts showing your focus time over the week.
- **Premium UI/UX:** Built with a strict dark brutalist design system. Features haptic feedback, bespoke `CustomPaint` icons, and smooth micro-animations.

## Technical Highlights

If you're a developer or recruiter looking at this codebase, here are a few things that stand out:

* **State Management:** Uses `flutter_riverpod` (specifically the modern `Notifier` and `StateNotifier` APIs) for scalable and predictable state management instead of basic `setState`.
* **Custom Rendering:** The bottom navigation icons and the animated timer dial aren't just image assets—they are mathematically drawn from scratch using Flutter's `CustomPaint` canvas.
* **Architecture:** The project follows a feature-first folder structure (`lib/features/...`), keeping the presentation, data, and logic layers cleanly separated.
* **Navigation:** Implements `go_router` with a `StatefulShellRoute`, allowing for persistent bottom navigation state across different screens.

## Project Structure

```text
lib/
├── core/                   # Global configuration (Theme tokens, Router, Custom NavBar)
├── features/               
│   ├── stats/              # Analytics screen and data logic
│   ├── tasks/              # To-do list, reorderable views, and task providers
│   └── timer/              # The Pomodoro timer and custom painted dial
└── main.dart               # App entry point
```

## How to Run

Make sure you have [Flutter installed](https://docs.flutter.dev/get-started/install), then run:

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Build for Android (Release APK)

To build a highly optimized and obfuscated APK for your phone:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```
