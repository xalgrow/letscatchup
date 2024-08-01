import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationMatchmakingScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<DocumentSnapshot>> _getMatches(Position currentPosition) async {
    var matches = await FirebaseFirestore.instance.collection('users').get();
    return matches.docs.where((doc) {
      GeoPoint location = doc['location'];
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        location.latitude,
        location.longitude,
      );
      return distanceInMeters < 10000; // 10 kilometers
    }).toList();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Matches'),
      ),
      body: FutureBuilder<Position>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Unable to determine location.'));
          } else {
            Position currentPosition = snapshot.data!;
            return FutureBuilder<List<DocumentSnapshot>>(
              future: _getMatches(currentPosition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No matches found nearby.'));
                } else {
                  var matches = snapshot.data!;
                  return ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      var match = matches[index];
                      return ListTile(
                        title: Text(match['displayName']),
                        subtitle: Text('Interests: ${match['interests']}'),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
