import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

import 'place.dart';
import 'globals.dart' as globals;

import 'locationsPage.dart';
import 'loginPage.dart';
import 'placePage.dart';
import 'favoritesPage.dart';

import 'package:google_fonts/google_fonts.dart';

Future<List> get_places() async {
  var client = http.Client();
  try {
    var response = await http.post(
      Uri.parse(globals.host),
      body: {'request': 'getPlaces'},
    );
    // works
    List places = [];
    List decodedResponse = jsonDecode(response.body);
    for (int i = 0; i < decodedResponse.length; i++) {
      places.add(place.fromJson(decodedResponse[i]));
    }
    return places;
  } finally {
    client.close();
  }
}

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatefulWidget {
  MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photogenica',
      debugShowCheckedModeBanner: false,
      home: MainRoute(camera: widget.camera),
    );
  }
}

class MainRoute extends StatefulWidget {
  MainRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<MainRoute> createState() => MainRouteState();
}

class MainRouteState extends State<MainRoute> {
  void dispose() {
    super.dispose();
  }

  Future add_place(String descr, double lat, double lng, int userid) async {
    var client = http.Client();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'addPlace',
          'descr': descr,
          'lat': lat,
          'lng': lng,
          'userid': userid,
        },
      );
    } finally {
      client.close();
    }
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: Icon(Icons.account_circle),
              label: 'Login',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRoute(camera: widget.camera),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.add_location),
              label: 'Locations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationsRoute(camera: widget.camera),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.star),
              label: 'Favorites',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesRoute(camera: widget.camera),
                  ),
                );
              },
            ),
          ],
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          buildingsEnabled: false,
          initialCameraPosition: _kFrauenfeld,
          markers: _getMarkers(),
          zoomControlsEnabled: false,
          compassEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }

  Set<Marker> _getMarkers() {
    get_places().then((marker_array) {
      for (int i = 0; i < marker_array.length; i++) {
        setState(
          () {
            LatLng position = LatLng(marker_array[i].lat, marker_array[i].lng);
            markers.add(
              Marker(
                markerId: MarkerId(position.toString()),
                position: position,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceRoute(
                        placeid: marker_array[i].id,
                        camera: widget.camera,
                      ),
                    ),
                  );
                },
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          },
        );
      }
    });
    return markers;
  }
}
