# Interval Timer

A simple, focused Interval Timer for **HiiT**, **Strength**, and **Cardio** sessions — built with SwiftUI for iPhone.

---

## Features

### HiiT
Configure and run high-intensity interval training sessions with:
- Exercise name
- Work duration (seconds)
- Rest duration (seconds)
- Intervals per round
- Number of rounds

### Strength
Step through strength training sets with an automatic rest-period countdown:
- Exercise name
- Reps per set
- Number of sets
- Rest period (seconds) between sets

### Cardio
Same interval structure as HiiT, tuned for longer steady-state cardio blocks:
- Exercise name
- Work duration
- Rest duration
- Intervals per round
- Number of rounds

---

## Project Structure

```
interval_timer/
├── Package.swift                        # SPM package (core logic, testable on any platform)
├── Sources/
│   └── IntervalTimerCore/
│       ├── WorkoutModels.swift          # HiitConfig, StrengthConfig, CardioConfig
│       └── WorkoutTimer.swift           # IntervalTimerSession, StrengthTimerSession
├── Tests/
│   └── IntervalTimerCoreTests/
│       ├── WorkoutModelsTests.swift
│       └── WorkoutTimerTests.swift
└── IntervalTimerApp/                    # SwiftUI iOS app source files
    ├── IntervalTimerApp.swift           # @main app entry point
    ├── ContentView.swift                # 3-tab navigation
    ├── Views/
    │   ├── HiitSetupView.swift
    │   ├── StrengthSetupView.swift
    │   ├── CardioSetupView.swift
    │   ├── IntervalTimerView.swift      # Shared timer view (HiiT & Cardio)
    │   ├── StrengthSessionView.swift
    │   └── TimerRingView.swift          # Reusable circular countdown ring
    └── ViewModels/
        ├── IntervalTimerViewModel.swift
        └── StrengthTimerViewModel.swift
```

---

## Running the Core Tests

The timer logic is pure Swift and can be tested on any platform:

```bash
swift test
```

---

## Setting Up the iOS App in Xcode

1. Open Xcode and create a new **iOS App** project (SwiftUI, Swift).
2. Set the **Minimum Deployment Target** to iOS 16 or later.
3. Delete the default `ContentView.swift` Xcode generates.
4. Drag the entire `IntervalTimerApp/` folder into the Xcode project navigator (checking *Copy items if needed*).
5. In **Package Dependencies**, add this repository (or a local path) and link `IntervalTimerCore` to the app target.
6. Build and run on a simulator or device.

---

## Requirements

- iOS 16+
- Xcode 15+
- Swift 5.9+
