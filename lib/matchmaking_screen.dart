import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MatchmakingScreen extends StatefulWidget {
  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  late Future<List<DocumentSnapshot>> futureNearbyMatches;

  @override
  void initState() {
    super.initState();
    String userId = "your_user_id"; // Replace with actual user ID
    double userLatitude = 0.0; // Replace with actual latitude
    double userLongitude = 0.0; // Replace with actual longitude
    futureNearbyMatches = fetchNearbyMatches(userId, userLatitude, userLongitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Matches'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: futureNearbyMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No nearby matches found.'));
          }

          List<DocumentSnapshot> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              var name = userData['name'] ?? 'No name';
              var location = userData['location'] ?? 'No location';

              return ListTile(
                title: Text(name),
                subtitle: Text(location.toString()),
              );
            },
          );
        },
      ),
    );
  }
}

Future<List<DocumentSnapshot>> fetchNearbyMatches(String userId, double userLatitude, double userLongitude) async {
  final firestore = FirebaseFirestore.instance;

  // Example query to get nearby users
  QuerySnapshot querySnapshot = await firestore.collection('users').get();
  List<DocumentSnapshot> allUsers = querySnapshot.docs;

  // Filter users based on your criteria (e.g., distance)
  List<DocumentSnapshot> nearbyUsers = allUsers.where((user) {
    Map<String, dynamic> userData = user.data() as Map<String, dynamic>;

    if (userData.containsKey('location') && userData['location'] != null) {
      GeoPoint location = userData['location'];
      double distance = calculateDistance(userLatitude, userLongitude, location.latitude, location.longitude);
      return distance < 50.0; // Example: within 50 kilometers
    }

    return false;
  }).toList();

  return nearbyUsers;
}

double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
  const earthRadius = 6371.0; // Earth's radius in kilometers
  double dLat = _degreeToRadian(endLat - startLat);
  double dLng = _degreeToRadian(endLng - startLng);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreeToRadian(startLat)) * cos(_degreeToRadian(endLat)) *
          sin(dLng / 2) * sin(dLng / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _degreeToRadian(double degree) {
  return degree * pi / 180;
}
