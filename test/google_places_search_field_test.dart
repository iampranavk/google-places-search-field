import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_search_field/google_places_search_field.dart';
import 'package:google_places_search_field/models/place_latlng.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
    'Full flow: types text, shows overlay, taps result, returns LatLng',
    (WidgetTester tester) async {
      PlaceLatLng? selectedLocation;

      // 1. Create a Mock HTTP Client to intercept Google API calls
      final mockClient = MockClient((request) async {
        // Intercept the Autocomplete API call
        if (request.url.path.contains('autocomplete')) {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'predictions': [
                {
                  'place_id': 'ChIJOwg_06VPwokRYv534QaPC8g',
                  'structured_formatting': {
                    'main_text': 'New York',
                    'secondary_text': 'NY, USA',
                  },
                },
              ],
            }),
            200,
          );
        }

        // Intercept the Place Details API call
        if (request.url.path.contains('details')) {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'result': {
                'geometry': {
                  'location': {'lat': 40.7128, 'lng': -74.0060},
                },
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      // 2. Pump the widget with our mocked client
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GooglePlacesSearchField(
              apiKey: 'DUMMY_API_KEY',
              httpClient: mockClient,
              onLatLngSelected: (PlaceLatLng latLng) {
                selectedLocation = latLng;
              },
            ),
          ),
        ),
      );

      // 3. Enter text to trigger the autocomplete
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'New ');

      // 4. Wait for the debounce timer (400ms) and the async HTTP call to finish
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(); // Wait for overlay animations

      // 5. Verify the overlay rendered our mock data
      expect(find.text('New York'), findsOneWidget);
      expect(find.text('NY, USA'), findsOneWidget);

      // 6. Tap the prediction in the list
      await tester.tap(find.text('New York'));
      await tester.pumpAndSettle(); // Wait for details HTTP call to finish

      // 7. Verify the callback was triggered with the correct coordinates!
      expect(selectedLocation, isNotNull);
      expect(selectedLocation?.latitude, 40.7128);
      expect(selectedLocation?.longitude, -74.0060);
    },
  );
}
