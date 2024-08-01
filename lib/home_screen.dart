import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_catchup/matchmaking_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> matches = [];

  @override
  void initState() {
    super.initState();
    _getMatches();
  }

  Future<void> _getMatches() async {
    var matchmakingService = MatchmakingService();
    var matches = await matchmakingService.getMatches();
    setState(() {
      this.matches = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Welcome to Lets Catchup!'),
            SizedBox(height: 20),
            Text('Here are your matches:'),
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  var match = matches[index];
                  return ListTile(
                    title: Text(match['displayName'] ?? 'No Name'),
                    subtitle: Text('Interests: ${match['interests'] ?? ''}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
