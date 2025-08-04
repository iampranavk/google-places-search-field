import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

/// A search field widget that uses the Google Places API to suggest locations.
///
/// Requires a valid API key from Google Cloud with Places API enabled.
/// When a place is selected, it returns the coordinates (LatLng) via [onLatLngSelected].
class GooglePlacesSearchField extends StatefulWidget {
  /// Your Google API key
  final String apiKey;

  /// Callback when a location is selected. Returns a [maps.LatLng].
  final Function(maps.LatLng) onLatLngSelected;

  /// Optional decoration for the input field.
  final InputDecoration? inputDecoration;

  /// Optional text style for the input text.
  final TextStyle? textStyle;

  /// Hint text for the search field.
  final String hintText;

  /// Creates a [GooglePlacesSearchField].
  const GooglePlacesSearchField({
    super.key,
    required this.apiKey,
    required this.onLatLngSelected,
    this.hintText = 'Search location',
    this.inputDecoration,
    this.textStyle,
  });

  @override
  State<GooglePlacesSearchField> createState() =>
      _GooglePlacesSearchFieldState();
}

class _GooglePlacesSearchFieldState extends State<GooglePlacesSearchField> {
  late FlutterGooglePlacesSdk _places;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<AutocompletePrediction> _suggestions = [];
  bool _isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(widget.apiKey);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  /// Handles the logic for selecting a prediction from the list.
  ///
  /// It fetches the full place details using the place ID and passes the
  /// resulting latitude and longitude to the parent callback.
  Future<void> _handlePlaceSelection(AutocompletePrediction prediction) async {
    _controller.text = prediction.primaryText;
    _removeOverlay();
    FocusScope.of(context).unfocus();

    final placeId = prediction.placeId;
    // if (placeId!=null) return;

    final response = await _places.fetchPlace(
      placeId,
      fields: [PlaceField.Location],
    );

    final latLng = response.place?.latLng;
    if (latLng != null) {
      widget.onLatLngSelected(maps.LatLng(latLng.lat, latLng.lng));
    } else {
      //Print statement if its null
    }
  }

  /// Shows the autocomplete suggestions overlay when the input field is focused.
  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  /// Removes the autocomplete suggestions overlay.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Debounced text change handler.
  ///
  /// Triggers the autocomplete request after a delay (400ms).
  /// If the query is empty, clears suggestions.
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

      final response = await _places.findAutocompletePredictions(
        value,
        placeTypesFilter: [PlaceTypeFilter.REGIONS],
      );

      setState(() {
        _suggestions = response.predictions;
        _isLoading = false;
        _overlayEntry?.markNeedsBuild();
      });
    });
  }

  /// Builds the overlay entry with the list of predictions or loading state.
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
                        color: Color(0XFF8A8486),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                                color: Color(0XFF8A8486),
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
                color: Color(0XFF605F65),
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
