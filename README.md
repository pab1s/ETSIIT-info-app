# ETSIIT Info App

This Flutter project is designed to be a comprehensive app for college students. It features a range of functionalities including login capabilities, a home page with various resources, and navigation to different sections like events, clubs, locations, and dining options.

## Features

- **Login Page**: A user-friendly login page with options to log in or access the app as a guest.
- **Home Page**: Includes a welcome message, a user avatar, and a banner image, followed by a grid of buttons for navigation.
- **Navigation**: A bottom navigation bar to access the home page, events, and maps, as well as a side drawer for logging out and accessing the user profile.
- **Additional Pages**: Pages for locations, clubs, time table, events, and places to eat, each with a unique layout and content.

## Project Setup

1. **Clone the Repository**: Clone this repository to your local machine.

```
git clone [repository-url]
```

2. **Install Dependencies**: Navigate to the project directory and run:

```
flutter pub get
```

3. **Run the App**: Ensure you have an emulator running, or a device connected, then execute:

```
flutter run
```

## Building the App

To generate an APK for Android:

1. **Build APK**: Run the following command in your terminal:
```
flutter build apk
```

2. **Locate APK**: Find the `app-release.apk` in `[project root]/build/app/outputs/flutter-apk/`.

3. **Testing APK**: Before distribution, test the APK on different devices to ensure functionality.

## Key Implementations

- **Common Widgets**: Reusable widgets like `TopBar`, `BottomBar`, and `SideBar` are used across the app.
- **Home Page Layout**: Includes a `GridView` for navigation buttons, a `CircleAvatar` for the user image, and a welcome banner.
- **Styling**: Material design and a color scheme of orange and white are used throughout the app.
- **Scrollable Page**: The home page is made scrollable for better user experience on devices with varying screen sizes.

## Notes

- Update `pubspec.yaml` for assets and dependencies.
- Test the app extensively on different devices and emulators.
- Follow Flutter's guidelines for building and releasing the app on different platforms.

## Contributing

Contributions to this project are welcome. Please ensure to follow the existing code structure and style guidelines.

---

**Author:** All of us
**Version:** 1.0.0
