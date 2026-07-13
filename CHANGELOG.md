## 2.0.0

- **BREAKING CHANGE:** Removed the `google_maps_flutter` dependency to make the package map-agnostic. The `onLatLngSelected` callback now returns a custom `PlaceLatLng` object instead of a `maps.LatLng` object.
- **BREAKING CHANGE:** Removed the `flutter_google_places_sdk` native dependency. The package is now a 100% pure Dart implementation using direct REST API calls.
- **Feature:** Added UUID v4 Session Token management to drastically reduce Google Places API billing by grouping keystrokes into single sessions.
- **Feature:** Added full cross-platform support. The package now officially supports Web, macOS, Windows, and Linux natively.
- **Feature:** Added an optional `httpClient` parameter to the constructor to support Dependency Injection, making it easy to write automated widget tests with mock network responses.

## 1.0.2

- Fixed typo in README.md
- Added screenshot preview in `README.md`.
- No functional or API-level changes.

## 1.0.1

- Improved documentation.
- Updated `google_maps_flutter` to latest version.
- Minor code cleanup and formatting.
- Declared that the package does not support Flutter Web.
- Added platform support section in README.

## 1.0.0

- Initial stable release.
- Provides a customizable `GooglePlacesSearchField` widget.
- Integrates with `flutter_google_places_sdk` for autocomplete suggestions.
- Returns `LatLng` on place selection.
- Supports input decoration and style customization.
- Includes debounce logic and overlay suggestion list.
