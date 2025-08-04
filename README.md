<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

A Flutter widget that integrates with the `flutter_google_places_sdk` and `google_maps_flutter` to provide a search input field with Google Places autocomplete and LatLng callback support. Ideal for apps that need smooth location search functionality.

## Features

- Google Places autocomplete integration
- Real-time search with debouncing
- Customizable input decoration and text style
- Easy retrieval of selected location's coordinates (`LatLng`)
- Clean overlay UI with search suggestions

## Getting started

### Prerequisites

1. Enable the **Places API** and **Maps SDK for Android/iOS** in Google Cloud Console.
2. Add your API key with the required restrictions.

## Installation

In your `pubspec.yaml`, add:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Add the latest version
  flutter_google_places_sdk:

  # Add the latest version
  google_maps_flutter:

  # This package (use latest)
  google_places_search_field:
  ```

## Preview

<p align="center">
  <img src="https://github.com/iampranavk/google-places-search-field/blob/main/assets/google_places_search_field_screen_shot.jpg" width="300" alt="Google Places Search Field Screen Shot" />
</p>


## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅ Yes     |
| iOS      | ✅ Yes     |
| Web      | ❌ No      |
| macOS    | ⚠️ Untested |
| Windows  | ⚠️ Untested |
| Linux    | ⚠️ Untested |

> ❗️ This package does **not support Flutter Web** due to limitations in `flutter_google_places_sdk` and `google_maps_flutter`. Consider using `google_maps_webservice` or a platform-channel implementation for web-specific use cases.

## Usage

```dart
GooglePlacesSearchField(
  apiKey: 'YOUR_GOOGLE_API_KEY',
  onLatLngSelected: (LatLng latLng) {
    print('Selected location: ${latLng.latitude}, ${latLng.longitude}');
  },
  hintText: 'Search for a place',
);
