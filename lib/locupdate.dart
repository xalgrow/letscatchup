import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

Future<void> updateUserLocation(String userId) async {
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    });

    print('Location updated successfully');
  } catch (e) {
    print('Failed to update location: $e');
  }
}
