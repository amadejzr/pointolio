# App Screenshots

This project generates App screenshots using Flutter integration tests.

---

## Requirements
	•	Flutter SDK installed
	•	A simulator/emulator or real device already running

---

## Generate Screenshots

1.	Make sure your device or simulator is open
2.	Get the device id:

```
flutter devices
```
3. Run the screenshot generator:

```
flutter drive \
  --driver=screenshots/driver.dart \
  --target=screenshots/screenshot_test.dart \
  -d "{deviceId}"
```


---

What This Does
	•	Launches the app on the selected device
	•	Uses an in-memory database
	•	Seeds the database with predefined screenshot data
	•	Navigates through the app automatically
	•	Generates screenshots via takeScreenshot(...)