import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place.dart';
import 'globals.dart' as globals;
import 'loginPage.dart';
import 'addPlacePage.dart';

Future<List> get_user_places(int userid) async {
  var client = http.Client();
  try {
    var response = await http.post(
      Uri.parse(globals.host),
      body: {
        'request': 'getUserPlaces',
        'userid': userid.toString(),
      },
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

class LocationsRoute extends StatefulWidget {
  const LocationsRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<LocationsRoute> createState() => _LocationsRouteState();
}

List<ListTile> place_tiles = [];

class _LocationsRouteState extends State<LocationsRoute> {
  List<ListTile> getPlaceTiles() {
    get_user_places(globals.global_userid).then((places) {
      // clear the global list
      place_tiles.clear();
      // get places
      for (int i = 0; i < places.length; i++) {
        setState(() {
          place_tiles.add((ListTile(
            title: Text(places[i].descr),
            subtitle: Text(
                places[i].lat.toString() + ", " + places[i].lng.toString()),
          )));
        });
      }
    });
    return place_tiles;
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> place_tiles = getPlaceTiles();

    if (globals.global_userid == -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => LoginRoute(camera: widget.camera)));
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Your Places"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemBuilder: ((BuildContext context, int index) {
                return Container(
                  child: place_tiles[index],
                );
              }),
              itemCount: place_tiles.length,
            ),
          ),
          TextButton(
            child: Text("Add a Place"),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPlaceRoute(
                      camera: widget.camera,
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
