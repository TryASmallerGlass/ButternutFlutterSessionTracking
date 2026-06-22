# Muscle Group Session Tracker

Personal-use Android app (built with Flutter) for tracking which muscle
groups were worked during a workout, plus optional cardio details.

## Muscle groups tracked

- **Front** — chest / shoulders / triceps
- **Back** — including biceps
- **Legs**
- **Core** — abs / lower back / glutes

## Session data

Each session records:

- Date & time
- One or more muscle groups hit
- Optional cardio (CV): duration in minutes + intensity level (1–20)
- Free-text comment

Data is stored locally on-device using SQLite (via the `drift` package) —
no cloud sync, no accounts.

## Status

MVP: create, view, edit, and delete sessions. A reporting/analytics screen
is planned as a follow-up project.

## Running

```
flutter pub get
flutter run
```

Requires Flutter stable with the Android SDK/toolchain configured
(`flutter doctor` should show no Android issues).
