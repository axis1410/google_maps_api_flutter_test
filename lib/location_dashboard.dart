// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_api_flutter_test/shared/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class LocationDashboard extends StatefulWidget {
  const LocationDashboard({super.key});

  @override
  _LocationDashboardState createState() => _LocationDashboardState();
}

class _LocationDashboardState extends State<LocationDashboard> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 500, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final String userName = user?.displayName ?? 'Anonymous';
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
        backgroundColor: Colors.black,
        title: const Text('Live Location Tracker'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                _getLocation(userName);
              },
              child: const Text('Add my location'),
            ),
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                _listenLocation(userName);
              },
              child: const Text('Enable live location'),
            ),
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                _stopListening();
              },
              child: const Text('Stop live location'),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('location').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          snapshot.data!.docs[index]['name'].toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              snapshot.data!.docs[index]['latitude'].toString(),
                              style: const TextStyle(
                                  color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              snapshot.data!.docs[index]['longitude'].toString(),
                              style: const TextStyle(
                                  color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text('Signed in as ${user?.displayName}',
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  _getLocation(userName) async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('location')
          .where('name', isEqualTo: userName)
          .get();
      if (result.docs.isNotEmpty) {
        // User already exists in the location collection, update their location
        await result.docs.first.reference.update({
          'latitude': _locationResult.latitude,
          'longitude': _locationResult.longitude,
        });
      } else {
        // User does not exist in the location collection, create a new document
        await FirebaseFirestore.instance.collection('location').add({
          'latitude': _locationResult.latitude,
          'longitude': _locationResult.longitude,
          'name': userName
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation(userName) async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      print('long: ' +
          currentlocation.longitude.toString() +
          ' lat: ' +
          currentlocation.latitude.toString());
      await FirebaseFirestore.instance.collection('location').doc(userName).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': userName
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
