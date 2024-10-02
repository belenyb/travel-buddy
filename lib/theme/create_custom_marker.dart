import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarker(String type) async {
    // Load your image as a ByteData object
    final ByteData imageData = await rootBundle.load('assets/images/custom-marker-$type.png');

    // Convert the ByteData to a Uint8List
    final Uint8List imageBytes = imageData.buffer.asUint8List();

    // Create the BitmapDescriptor from the image
    return BitmapDescriptor.bytes(imageBytes);
  }
