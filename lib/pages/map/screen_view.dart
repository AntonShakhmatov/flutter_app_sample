import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ScreenView extends StatefulWidget {
  double? latitude;
  double? longitude;

  ScreenView({super.key, this.latitude, this.longitude});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // FirebaseAuth.instance отвечает за создание и предоставление единственного экземпляра (singleton instance) класса FirebaseAuth

  User? get currentUser => _firebaseAuth.currentUser; // Получение текущего пользователя

  getUserId() {
    User? user = _firebaseAuth.currentUser; // Получение текущего пользователя
    if(user != null) {
      String uid = user.uid;
      return uid;
    }
  }

  void lastKnownPosition() async {
    await locationServicesStatus();
    await checkLocationPermissions();
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      print(position);
    } catch (e) {
      print(e);
    }
  }

  Future<LatLng> locationHereIs() async {
      await locationServicesStatus();
      await checkLocationPermissions();
      var uid = getUserId();
      // Пример: получаем текущее местоположение пользователя
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
      FirebaseFirestore.instance.collection('locations').doc(uid).set({
        // 'id': Random(),
        'location': GeoPoint(position.latitude, position.longitude),
        // 'isOnline': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> updateStatus(String userId, bool isOnline) async {
    FirebaseFirestore.instance.collection('locations').doc(userId).update({
      'isOnline': isOnline,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    print('Current Location Permission Status = $permission.');
  }

  void checkLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> locationServicesStatus() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    print(
        'Currently, the emulator\'s Location Services Status = $isLocationServiceEnabled.');
  }

  @override
  State<ScreenView> createState() => _ScreenViewState();
}

class _ScreenViewState extends State<ScreenView> {
  @override
  void initState() {
    ScreenView().lastKnownPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}