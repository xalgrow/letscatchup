import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  String? _profileImageUrl;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = user?.displayName ?? '';
    _loadUserProfile();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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

    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<void> _loadUserProfile() async {
    try {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      if (userData.exists) {
        setState(() {
          _displayNameController.text = userData['displayName'];
          _interestsController.text = userData['interests'];
          _profileImageUrl = userData['profilePicture'];
        });
      } else {
        print('User profile not found.');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      await user?.updateDisplayName(_displayNameController.text);
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'displayName': _displayNameController.text,
        'interests': _interestsController.text,
        'profilePicture': _profileImageUrl,
        'location': GeoPoint(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {}); // Refresh the UI to show updated display name
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          // Upload to Firebase Storage
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child(user!.uid)
              .child(file.name);

          print('Uploading image...');
          await ref.putData(file.bytes!);
          String downloadURL = await ref.getDownloadURL();
          print('Upload complete. URL: $downloadURL');

          setState(() {
            _profileImageUrl = downloadURL;
          });

          // Create or update profile in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
            'profilePicture': _profileImageUrl,
          }, SetOptions(merge: true));
          print('Profile updated with image URL.');
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: _interestsController,
              decoration: InputDecoration(labelText: 'Interests'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Profile Picture'),
            ),
            if (_profileImageUrl != null) ...[
              Text('Profile Image URL: $_profileImageUrl'),
              Image.network(
                _profileImageUrl!,
                errorBuilder: (context, error, stackTrace) {
                  return Text('Error loading image');
                },
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
            SizedBox(height: 20),
            Text('Email: ${user?.email}'),
          ],
        ),
      ),
    );
  }
}
