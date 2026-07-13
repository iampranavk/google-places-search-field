import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_places_search_field/models/place_latlng.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Lightweight model to replace the heavy SDK prediction object
class PlacePrediction {
  final String placeId;
  final String primaryText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'];
    return PlacePrediction(
      placeId: json['place_id'],
      primaryText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class GooglePlacesSearchField extends StatefulWidget {
  /// The Google Cloud Places API key.
  ///
  /// Ensure that the Places API is enabled for this key in your
  /// Google Cloud Console.
  final String apiKey;

  /// Callback triggered when a location is selected from the dropdown menu.
  ///
  /// Returns a [PlaceLatLng] object containing the latitude and longitude
  /// coordinates of the chosen destination.
  final Function(PlaceLatLng) onLatLngSelected;

  /// Optional decoration configuration for the underlying [TextFormField].
  ///
  /// Allows you to customize the input fields visual appearance (borders,
  /// icons, labels) to match your application's design theme.
  final InputDecoration? inputDecoration;

  /// Optional typography style applied to the text entered into the search field.
  final TextStyle? textStyle;

  /// The placeholder hint text displayed inside the field when it is empty.
  ///
  /// Defaults to 'Search location'.
  final String hintText;

  /// An optional HTTP client used to execute the underlying network requests.
  ///
  /// For standard app development, leave this null. It is primarily used
  /// to inject a mock HTTP client during unit and widget testing, or to
  /// supply custom proxy client configurations.
  final http.Client? httpClient;

  const GooglePlacesSearchField({
    super.key,
    required this.apiKey,
    required this.onLatLngSelected,
    this.hintText = 'Search location',
    this.inputDecoration,
    this.textStyle,
    this.httpClient,
  });

  @override
  State<GooglePlacesSearchField> createState() =>
      _GooglePlacesSearchFieldState();
}

class _GooglePlacesSearchFieldState extends State<GooglePlacesSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  // Session Token Management
  final Uuid _uuid = const Uuid();
  String? _sessionToken;

  OverlayEntry? _overlayEntry;
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _generateSessionToken();
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  /// Initializes a new session token if one doesn't exist.
  void _generateSessionToken() {
    _sessionToken ??= _uuid.v4();
  }

  Future<void> _handlePlaceSelection(PlacePrediction prediction) async {
    _controller.text = prediction.primaryText;
    _removeOverlay();
    FocusScope.of(context).unfocus();

    final placeId = prediction.placeId;

    // Pass the SAME session token to the Details API to close the billing cycle
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?'
      'place_id=$placeId&fields=geometry&key=${widget.apiKey}&sessiontoken=$_sessionToken',
    );

    try {
      final response = await (widget.httpClient?.get(url) ?? http.get(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Place details response: $data');
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final double lat = (location['lat'] as num).toDouble();
          final double lng = (location['lng'] as num).toDouble();

          debugPrint('Selected location: $lat, $lng');
          widget.onLatLngSelected(PlaceLatLng(latitude: lat, longitude: lng));
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    } finally {
      // CLEAR the token so the next search starts a fresh billing session
      _sessionToken = null;
    }
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _overlayEntry?.markNeedsBuild();
        });
        return;
      }

      setState(() => _isLoading = true);
      _generateSessionToken();

      // Autocomplete REST API call passing the session token
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=${Uri.encodeComponent(value)}&types=(regions)&key=${widget.apiKey}&sessiontoken=$_sessionToken',
      );

      try {
        final response = await (widget.httpClient?.get(url) ?? http.get(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final predictions = data['predictions'] as List;
            setState(() {
              _suggestions = predictions
                  .map((p) => PlacePrediction.fromJson(p))
                  .toList();
            });
          } else {
            setState(() => _suggestions = []);
          }
        }
      } catch (e) {
        debugPrint('Error fetching predictions: $e');
        setState(() => _suggestions = []);
      } finally {
        setState(() {
          _isLoading = false;
          _overlayEntry?.markNeedsBuild();
        });
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                : _suggestions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "No results found",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0XFF8A8486),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final prediction = _suggestions[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          prediction.primaryText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        subtitle: Text(
                          prediction.secondaryText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0XFF8A8486),
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        onTap: () => _handlePlaceSelection(prediction),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        style:
            widget.textStyle ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
        decoration:
            widget.inputDecoration ??
            InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0XFF605F65),
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
      ),
    );
  }
}
