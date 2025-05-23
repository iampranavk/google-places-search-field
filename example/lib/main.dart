import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_places_search_field/google_places_search_field.dart';

void main() {
  runApp(const GooglePlacesExampleApp());
}

class GooglePlacesExampleApp extends StatelessWidget {
  const GooglePlacesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Places Search Field Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  maps.LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places Search Field')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePlacesSearchField(
              apiKey: 'YOUR_GOOGLE_API_KEY', // Replace with your actual API key
              onLatLngSelected: (maps.LatLng latLng) {
                setState(() {
                  _selectedLatLng = latLng;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_selectedLatLng != null)
              Text(
                'Selected Location: ${_selectedLatLng!.latitude}, ${_selectedLatLng!.longitude}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
