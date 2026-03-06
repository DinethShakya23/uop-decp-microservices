# Getting Started — DECP Mobile App (Android)

This guide walks you through setting up the DECP Flutter app on an **Android emulator** for local development.

---

## Prerequisites

Make sure you have the following installed before proceeding:

| Tool | Notes |
|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | Stable channel recommended |
| [Android Studio](https://developer.android.com/studio) | Required for the Android emulator and SDK |
| Java Development Kit (JDK) | Usually bundled with Android Studio |

After installing Flutter, verify your environment is ready:

```bash
flutter doctor
```

Resolve any issues flagged before continuing. Pay attention to the **Android toolchain** and **Android Studio** sections.

---

## 1. Clone the Repository

```bash
git clone <repository-url>
cd decp-mobile
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Set Up the Android Emulator

1. Open **Android Studio**
2. Go to **Device Manager** (the phone icon in the toolbar, or via *Tools → Device Manager*)
3. Click **Create Device**
4. Select a device definition (e.g. Pixel 6) and click **Next**
5. Choose a system image — **API 33 (Android 13)** or higher is recommended
6. Click **Finish** to create the AVD
7. Start the emulator by pressing the **Play (▶)** button next to your device

Confirm the emulator is visible to Flutter:

```bash
flutter devices
```

You should see your emulator listed, e.g.:

```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
```

---

## 4. Configure the Backend URL

The app communicates with the DECP backend through a locally running API gateway. Because Android emulators run in an isolated network environment, `localhost` on the emulator refers to the **emulator itself**, not your development machine.

The standard workaround is to use `10.0.2.2`, which the Android emulator automatically maps to your host machine's `localhost`.

The base URL is hardcoded in:

```
lib/core/network/api_client.dart   (or wherever your Dio client is configured)
```

It is currently set to:

```dart
const String baseUrl = 'http://10.0.2.2:8080';
```

**If you need to change the port or target a different host** (e.g., a staging server or a device on a physical network), update this constant in that file. Avoid committing personal or environment-specific URLs — consider moving this to a `.env` file or a build-time configuration if the project grows.

> ⚠️ **Physical device note:** `10.0.2.2` only works on Android emulators. If you are running the app on a **real Android device**, use your machine's local network IP address (e.g. `192.168.x.x`) and ensure both are on the same Wi-Fi network.

---

## 5. Start the Backend

Make sure the DECP backend services are running locally before launching the app. The API gateway should be accessible at:

```
http://localhost:8080
```

Refer to the backend repository's setup guide for instructions on starting the services.

---

## 6. Run the App

With the emulator running and the backend up, launch the app:

```bash
flutter run
```

Flutter will detect the active emulator and deploy automatically. To target a specific device if multiple are connected:

```bash
flutter run -d emulator-5554
```

---

## 7. WebSocket Connection

The messaging feature connects over WebSocket using STOMP. The WebSocket endpoint is also routed through the API gateway:

```
ws://10.0.2.2:8080/ws/chat
```

This follows the same `10.0.2.2` convention as the REST base URL. Update it in the same way if your host or port changes.

---

## Common Issues

| Problem | Solution |
|---|---|
| `flutter doctor` reports missing Android SDK | Open Android Studio → SDK Manager and install the required SDK |
| Emulator not listed by `flutter devices` | Ensure the AVD is running; try `flutter emulators --launch <id>` |
| Network requests fail with connection refused | Confirm the backend is running on port 8080 and the base URL uses `10.0.2.2` |
| App builds but shows auth errors immediately | Check that the backend auth service is reachable and the JWT flow is working |
| Slow emulator performance | Enable hardware acceleration (HAXM on Intel / Hyper-V on AMD) in Android Studio |

---

## Useful Commands

```bash
# List all connected devices and emulators
flutter devices

# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch <emulator_id>

# Run with verbose logging
flutter run -v

# Run in release mode
flutter run --release

# Hot reload shortcut (while app is running)
r

# Hot restart
R
```

---

## Next Steps

- Read [ARCHITECTURE.md](./ARCHITECTURE.md) to understand the project structure and conventions
- Explore the `lib/features/` directory to get familiar with the feature modules
- Check the `lib/core/network/` module to understand how API requests and interceptors are set up