import 'package:flutter/material.dart';
import 'package:google_places_search_field/google_places_search_field.dart';
import 'package:google_places_search_field/models/place_latlng.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Places Search Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const GooglePlacesSearchExampleScreen(),
    );
  }
}

class GooglePlacesSearchExampleScreen extends StatefulWidget {
  const GooglePlacesSearchExampleScreen({super.key});

  @override
  State<GooglePlacesSearchExampleScreen> createState() =>
      _GooglePlacesSearchExampleScreenState();
}

class _GooglePlacesSearchExampleScreenState
    extends State<GooglePlacesSearchExampleScreen> {
  PlaceLatLng? _selectedLocation;

  final String _googleApiKey =
      'YOUR_GOOGLE_API_KEY'; // Replace with your actual Google API key
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Search Field'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GooglePlacesSearchField(
                apiKey: _googleApiKey,
                hintText: 'Search places',
                onLatLngSelected: (PlaceLatLng coords) {
                  setState(() {
                    _selectedLocation = coords;
                  });
                },
              ),
              const SizedBox(height: 40),
              if (_selectedLocation != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Coordinates:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Latitude: ${_selectedLocation!.latitude}'),
                      Text('Longitude: ${_selectedLocation!.longitude}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
