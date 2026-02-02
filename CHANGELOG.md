# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Theme Selector**: Added appearance settings with System/Light/Dark theme options in Manage page
- **Theme Persistence**: Theme preference is saved and restored across app sessions using SharedPreferences
- **Onboarding Flow**: First-time user onboarding to introduce the app and basic usage



## [1.1.0] - 02-02-26

### Added
- **Custom Calculator Keyboard**: New modular calculator keyboard for score entry with expression display (e.g., "50+30" shows result)
- **iPad & Tablet Support**: Responsive keyboard layout that adapts to phone (compact) and tablet (wider) screens
- **Auto-scroll for Score Entry**: Automatically scrolls to focused field when pressing "Next" in Add Round sheet
- **Enhanced Edit Points Dialog**: Displays player name and round number in dialog header
- **Haptic Feedback**: Added haptic feedback on calculator button presses for better tactile feedback
- **Backspace Button in Toolbar**: Single-character deletion button in the calculator toolbar

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
