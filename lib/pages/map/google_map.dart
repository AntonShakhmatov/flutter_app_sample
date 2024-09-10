import 'dart:async';
import 'screen_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late Future<LatLng> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = ScreenView().locationHereIs(); // Запускаем асинхронный запрос
  }

  // LatLng _currentPos = LatLng(50.073658, 14.418540); // Изначальная позиция (например, 0, 0)
  final LatLng _currentPos = const LatLng(0, 0); // Изначальная позиция (например, 0, 0)
  late GoogleMapController mapController;

// target: LatLng({_currentPosition?.latitude ?? ""} as double, {_currentPosition?.longitude ?? ""} as double),
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: FutureBuilder<LatLng>(
          future: _locationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Пока данные загружаются, показываем индикатор загрузки
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Если произошла ошибка, показываем сообщение
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              // Если данные успешно загружены, отображаем карту
              LatLng currentPos = snapshot.data!;
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentPos,
                  zoom: 11.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("CurrentPosition"),
                    position: currentPos,
                    infoWindow: const InfoWindow(
                      title: "Your Location",
                      snippet: "Current Position",
                    ),
                  ),
                },
              );
            } else {
              // Если данных нет (что маловероятно), показываем сообщение
              return const Center(child: Text("Could not fetch location."));
            }
          },
        ),
      ),
    );
  }
}


// Осталось испробовать геолокацию на физическом устройстве(не на эмуляторе)