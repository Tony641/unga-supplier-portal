# Flutter

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release

# For Web
flutter build web --release
```

### ✅ **Web Build Status: SUCCESSFUL**

The Unga Supplier Portal has been successfully built for web deployment. The build output is located in `build/web/` directory.

**Build Details:**
- ✅ Web support enabled
- ✅ Theme compilation fixed
- ✅ Production build completed
- ✅ CanvasKit renderer used for better performance
- ✅ Service worker generated for offline support
- ✅ PWA manifest configured

**Build Output:**
```
build/web/
├── index.html              # Main entry point
├── main.dart.js           # Compiled Dart code (3.3MB)
├── flutter.js             # Flutter web runtime
├── manifest.json          # PWA manifest
├── favicon.png            # App icon
├── assets/                # Static assets
├── icons/                 # App icons
├── canvaskit/             # CanvasKit renderer files
└── flutter_service_worker.js # Service worker for offline support
```

### 🌐 Web Deployment

The application is optimized for web deployment with the following features:

#### **Build for Web:**
```bash
# Development build
flutter build web

# Production build (optimized)
flutter build web --release

# Production build with specific base href
flutter build web --release --base-href "/unga-supplier-portal/"
```

#### **Web-Specific Configuration:**

1. **Update index.html** (in `web/index.html`):
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Unga Supplier Portal - Streamline your invoice management">
  
  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Unga Supplier Portal">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>Unga Supplier Portal</title>
  <link rel="manifest" href="manifest.json">

  <script>
    // The value below is injected by flutter build, do not touch.
    const serviceWorkerVersion = null;
  </script>
  <!-- This script adds the flutter initialization JS code -->
  <script src="flutter.js" defer></script>
</head>
<body>
  <script>
    window.addEventListener('load', function(ev) {
      // Download main.dart.js
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: serviceWorkerVersion,
        },
        onEntrypointLoaded: function(engineInitializer) {
          engineInitializer.initializeEngine().then(function(appRunner) {
            appRunner.runApp();
          });
        }
      });
    });
  </script>
</body>
</html>
```

2. **Update manifest.json** (in `web/manifest.json`):
```json
{
    "name": "Unga Supplier Portal",
    "short_name": "Unga Portal",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "Streamline your invoice management with our mobile-first platform integrated with SAP systems.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
```

#### **Deployment Options:**

1. **Firebase Hosting:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy
```

2. **Netlify:**
```bash
# Build the app
flutter build web --release

# Deploy to Netlify (drag and drop the build/web folder)
# Or use Netlify CLI
netlify deploy --prod --dir=build/web
```

3. **GitHub Pages:**
```bash
# Build with base href
flutter build web --release --base-href "/your-repo-name/"

# Push to gh-pages branch
git subtree push --prefix build/web origin gh-pages
```

4. **Vercel:**
```bash
# Install Vercel CLI
npm i -g vercel

# Build the app
flutter build web --release

# Deploy
vercel build/web
```

#### **Web Performance Optimization:**

1. **Enable Web Renderer:**
```bash
# Use HTML renderer (default)
flutter build web --web-renderer html

# Use CanvasKit renderer (better performance)
flutter build web --web-renderer canvaskit
```

2. **Optimize for Production:**
```bash
# Build with all optimizations
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

#### **Environment Configuration for Web:**

Create `web/env.js` for web-specific environment variables:
```javascript
window.flutterConfiguration = {
  apiUrl: "https://api.unga.com",
  environment: "production"
};
```

Update `web/index.html` to include:
```html
<script src="env.js"></script>
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
