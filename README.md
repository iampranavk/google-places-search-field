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

1. Add your Google Maps API key with Places API enabled.
2. Make sure the following packages are added in your `pubspec.yaml`:
   - `flutter_google_places_sdk`
   - `google_maps_flutter`
3. Set up billing and permissions for the Google Maps SDK on Android/iOS.

## Usage

```dart
GooglePlacesSearchField(
  apiKey: 'YOUR_GOOGLE_API_KEY',
  onLatLngSelected: (LatLng latLng) {
    print('Selected location: ${latLng.latitude}, ${latLng.longitude}');
  },
  hintText: 'Search for a place',
);
