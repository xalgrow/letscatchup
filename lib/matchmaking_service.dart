import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getMatches() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    var currentUserData = await _firestore.collection('users').doc(user.uid).get();
    if (!currentUserData.exists) return [];

    var currentUserInterests = currentUserData['interests'];

    var allUsersSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> matches = [];

    for (var doc in allUsersSnapshot.docs) {
      if (doc.id != user.uid) {
        var userData = doc.data();
        var userInterests = userData['interests'];
        if (userInterests != null && currentUserInterests != null) {
          var commonInterests = List<String>.from(currentUserInterests)
              .where((interest) => userInterests.contains(interest))
              .toList();
          if (commonInterests.isNotEmpty) {
            matches.add(userData);
          }
        }
      }
    }

    return matches;
  }
}
