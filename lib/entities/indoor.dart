// indoor.dart
import 'package:latlong2/latlong.dart';

// Map for storing textual instructions
Map<String, List<String>> _indoorInstructions = {
  'cafe': [
    "Sentence 1 for subfolder1",
    "Sentence 2 for subfolder1",
    "Sentence 3 for subfolder1",
  ],
  'lab': [
    "Ve a la puerta principal de la ETSIIT.",
    "Pasa la puerta y apunta al edificio principal.",
    "Ve a la puerta del fondo del camino.",
    "Entra y ve a las escaleras de la derecha.",
    "Sube las escaleras hasta el primer piso y ve a las del segundo piso.",
    "Sube las escaleras hasta el segundo piso y ve al tercer piso a mano derecha.",
    "Sigue recto y a mano derecha encontrarás el laboratorio 2.6.",
    "¡Has llegado!"
  ],
  'trial': [
    "Sentence 0 for subfolder3",
    "Sentence 1 for subfolder3",
  ],
};

// Map for storing coordinates
Map<String, List<LatLng>> _indoorCoordinates = {
  'cafe': [
    const LatLng(37.4219983, -122.084),
    const LatLng(37.4219983, -122.084),
    const LatLng(37.4219983, -122.084),
  ],
  'lab': [
    const LatLng(37.1968013, -3.6244303),
    const LatLng(37.1968097, -3.6243331),
    const LatLng(37.1971797, -3.6240768),
    const LatLng(37.1971779, -3.6238209),
    const LatLng(37.1973860, -3.6240667),
    const LatLng(37.1972702, -3.6241000),
    const LatLng(37.1973086, -3.6241293),
  ],
  'trial': [
    const LatLng(37.190695, -3.6102594),
    const LatLng(37.1902622, -3.6084813),
  ],
};

// Method to retrieve instructions
List<String> receiveInstructions(String subfolderName) {
  return _indoorInstructions[subfolderName] ?? [];
}

// Method to retrieve coordinates
List<LatLng> receiveCoordinates(String subfolderName) {
  return _indoorCoordinates[subfolderName] ?? [];
}
