# GeoCam News App

This is a Flutter application named "GeoCam News" with the following features:

- Display user location (latitude & longitude) with location permission.
- Capture photo using the device camera and display it in the app.
- Save location and photo data locally using SharedPreferences.
- Reset saved location and photo data.
- Display a list of news articles fetched from a public API.
- Bookmark news articles for later reading.
- Dark mode support with theme toggle.
- Pull-to-refresh for news list.
- State management using Provider.
- HTTP requests using Dio package.

## Build & Run

### Prerequisites

- Flutter SDK installed (version compatible with Dart SDK >=2.17.1 <3.0.0)
- Android Studio or Xcode for device emulation or a physical device connected
- Internet connection for fetching news data

### Steps to Build and Run

1. Clone the repository or download the project files.

2. Navigate to the project directory:

```bash
cd path/to/geo_cam
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app on an emulator or physical device:

```bash
flutter run
```

### Permissions

The app requires the following permissions:

- Location permission to access the user's current location.
- Camera permission to capture photos.

Make sure to grant these permissions when prompted.

## Libraries Used

- flutter (sdk)
- cupertino_icons: ^1.0.2
- provider: ^6.0.5
- shared_preferences: ^2.2.0
- dio: ^5.0.3
- permission_handler: ^10.4.3
- camera: ^0.10.5+2
- geolocator: ^9.0.2
- path_provider: ^2.0.15
- path: 1.8.2
- intl: ^0.18.1

## Development Workflow (SDLC)

The development of this Flutter application follows a typical Software Development Life Cycle (SDLC) process:

1. **Requirements Gathering:** Define the app features and functionalities based on user needs.

2. **Design:** Plan the app architecture, UI/UX design, and data flow.

3. **Implementation:** Write the code using Flutter and Dart, integrating necessary libraries and APIs.

4. **Testing:** Perform unit testing, widget testing, and integration testing to ensure app stability and correctness.

5. **Deployment:** Build and release the app to target platforms (Android, iOS).

6. **Maintenance:** Monitor app performance, fix bugs, and update features as needed.

## Notes

- Ensure your device/emulator has internet access to fetch news data.
- The news API used is JSONPlaceholder for demo purposes; you can replace it with any public news API.

If you encounter any issues or have questions, feel free to open an issue or contact the maintainer.
