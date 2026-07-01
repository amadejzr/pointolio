# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 01-07-26

### Added
- **Notebook / Slate design system**: App-wide visual redesign with ruled-paper backgrounds, Space Grotesk + Hanken Grotesk typography, per-player colours and themed motion.
- **Floating tab navigation**: New bottom navigation bar with Parties, Players and Games tabs, with each tab preserving its own state.
- **Standings view**: The scoring screen now has a Table/Standings toggle, with standings showing rank, points and rounds won per player.
- **Share card editor**: Sharing is now a compact, transparent winner card with selectable styles (Spotlight, Podium, Scorecard, Minimal) and adjustable transparency.
- **Party actions menu**: A per-party menu with a themed delete confirmation, replacing the old edit mode.
- **Full-screen create/edit forms**: New Notebook-style forms for parties, players and game types, reused across the app.
- **Settings screen**: Redesigned with data and about sections.
- **Branding**: New app icon, wordmark and native splash screen, with reorganized logo assets.
- **Bundled fonts**: Space Grotesk and Hanken Grotesk now ship as assets, so no fonts are downloaded at runtime.
- **Test suite & CI**: Tests for DAOs, cubits, repositories and database migrations, plus widget tests for the new forms.

### Changed
- Redesigned every screen in the Notebook theme: Parties, Players, Games, Scoring, Settings, Create party and Sharing.
- Migrated navigation to `go_router`; Players and Games are now top-level tabs and the old combined Manage page is gone.
- Reworked the App Store screenshot harness to drive the real app for production-accurate captures.

### Removed
- First-time onboarding flow.

### Fixed
- Total row overflow on the scoring screen.

## [1.1.0] - 02-02-26

### Added
- **Custom Calculator Keyboard**: New modular calculator keyboard for score entry with expression display (e.g., "50+30" shows result)
- **iPad & Tablet Support**: Responsive keyboard layout that adapts to phone (compact) and tablet (wider) screens
- **Auto-scroll for Score Entry**: Automatically scrolls to focused field when pressing "Next" in Add Round sheet
- **Enhanced Edit Points Dialog**: Displays player name and round number in dialog header
- **Haptic Feedback**: Added haptic feedback on calculator button presses for better tactile feedback
- **Backspace Button in Toolbar**: Single-character deletion button in the calculator toolbar
- **Theme Selector**: Added appearance settings with System/Light/Dark theme options in Manage page
- **Theme Persistence**: Theme preference is saved and restored across app sessions using SharedPreferences
- **Onboarding Flow**: First-time user onboarding to introduce the app and basic usage

### Changed
- **Replaced Native Keyboard**: Replaced system numeric keyboard with custom calculator keyboard in score entry forms
- **Updated onEditScore Callback**: Changed signature from `Function(int, int)` to `Function(int, int, String, int)` to include player name and round number
- **Dialog Positioning**: Improved edit dialog positioning and animation handling when keyboard appears/disappears

### Fixed
- **Keyboard Animation Issues**: Fixed jumpy animations when keyboard appears and disappears in edit dialog
- **Field Visibility**: Ensured focused input fields remain visible above the custom keyboard
- **Safe Area Handling**: Added proper safe area support in bottom sheets

### Technical
- Created modular calculator keyboard architecture:
  - `calculator_logic.dart`: Pure calculation logic for expression evaluation
  - `calculator_keyboard.dart`: Responsive UI component with button widgets
  - `calculator_keyboard_exports.dart`: Clean module exports
- Implemented `CalculatorLogic` class for expression parsing and evaluation (+/- operations)
- Added `getCalculatorKeyboardHeight()` helper for accurate layout calculations
- Support for external FocusNode management in CalculatorTextField
- Responsive LayoutBuilder pattern for phone/tablet detection

## [1.0.0] - 28-01-26

### Added
- Initial app release
- Core scoring functionality with game and player management
- Material Design 3 themed interface
