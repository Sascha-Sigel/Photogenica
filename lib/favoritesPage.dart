import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'loginPage.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place.dart';
import 'globals.dart' as globals;

Future<List> get_favorites(int userid) async {
  var client = http.Client();
  try {
    var response = await http.post(
      Uri.parse(globals.host),
      body: {
        'request': 'getFavorites',
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

class FavoritesRoute extends StatefulWidget {
  const FavoritesRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<FavoritesRoute> createState() => _FavoritesRouteState();
}

List<ListTile> favorites = [];

class _FavoritesRouteState extends State<FavoritesRoute> {
  List<ListTile> getPlaceTiles() {
    get_favorites(globals.global_userid).then((places) {
      // clear the global list
      favorites.clear();
      // get places
      for (int i = 0; i < places.length; i++) {
        setState(() {
          favorites.add((ListTile(
            title: Text(places[i].descr),
            subtitle: Text(
                places[i].lat.toString() + ", " + places[i].lng.toString()),
          )));
        });
      }
    });
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> favorites = getPlaceTiles();

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
        title: Text("Your Favorites"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemBuilder: ((BuildContext context, int index) {
                return Container(
                  child: favorites[index],
                );
              }),
              itemCount: favorites.length,
            ),
          ),
        ],
      ),
    );
  }
}
