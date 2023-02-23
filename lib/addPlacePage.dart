import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'addPlaceForm.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPlaceRoute extends StatefulWidget {
  AddPlaceRoute({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<AddPlaceRoute> createState() => AddPlaceRouteState();
}

class AddPlaceRouteState extends State<AddPlaceRoute> {
  void dispose() {
    super.dispose();
  }

  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = Set();

  static final CameraPosition _kFrauenfeld = CameraPosition(
    target: LatLng(47.553600, 8.898754),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(47.5449717, 9.3002409),
      tilt: 90,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Photogenica',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontSize: 30,
              letterSpacing: 3,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: Colors.black45,
            width: 4,
          ),
        ),
      ),
      floatingActionButton: TextButton(
        child: Text(
          "Take GPS Location",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        onPressed: () async {
          if (await Permission.locationWhenInUse.request().isGranted) {
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPlaceForm(
                  placelat: position.latitude,
                  placelng: position.longitude,
                  camera: widget.camera,
                ),
              ),
            );
          }
        },
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        initialCameraPosition: _kFrauenfeld,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: (position) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPlaceForm(
                placelat: position.latitude,
                placelng: position.longitude,
                camera: widget.camera,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
