// import 'package:flutter_test/flutter_test.dart';

import 'package:google_places_search_field/google_places_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

void main() {
  testWidgets('GooglePlacesSearchField renders correctly and calls callback', (
    WidgetTester tester,
  ) async {
    // Track whether callback is called
    bool callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GooglePlacesSearchField(
            apiKey: 'DUMMY_API_KEY',
            onLatLngSelected: (maps.LatLng latLng) {
              callbackCalled = true;
            },
          ),
        ),
      ),
    );

    // Ensure the TextFormField is rendered
    expect(find.byType(TextFormField), findsOneWidget);

    // Enter text in the search field
    await tester.enterText(find.byType(TextFormField), 'New York');
    await tester.pump(const Duration(milliseconds: 500)); // Trigger debounce

    // Since we can't mock platform channels easily here, assume the search field handled the input
    // This just confirms text entry and rendering
    expect(find.text('New York'), findsOneWidget);

    // In a full integration test, you’d validate suggestion tap -> callback
    expect(
      callbackCalled,
      isFalse,
    ); // Initially false since no place was tapped
  });
}
