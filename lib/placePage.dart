import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place.dart';
import 'globals.dart' as globals;

import 'main.dart';

class PlaceRoute extends StatefulWidget {
  const PlaceRoute({
    super.key,
    required this.placeid,
    required this.camera,
  });

  final int placeid;
  final CameraDescription camera;

  @override
  State<PlaceRoute> createState() => _PlaceRouteState();
}

class _PlaceRouteState extends State<PlaceRoute> {
  Future getPlace(int placeid) async {
    var client = http.Client();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'getPlace',
          'placeid': placeid.toString(),
        },
      );
      // works
      var decodedResponse = jsonDecode(response.body);

      return decodedResponse;
    } finally {
      client.close();
    }
  }

  Future<String> getImage(int placeid) async {
    var client = http.Client();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'getImage',
          'placeid': placeid.toString(),
        },
      );
      // works
      var decodedResponse = jsonDecode(response.body);

      Base64Codec base64 = const Base64Codec();

      //img = base64Decode(base64.normalize(decodedResponse));

      return base64.normalize(decodedResponse);
    } finally {
      client.close();
    }
  }

  _fetchImageData() async {
    return this._memoizer_img.runOnce(() async {
      return await getImage(widget.placeid);
    });
  }

  Future<dynamic> _fetchPlaceData() async {
    return this._memoizer_plc.runOnce(() async {
      return await getPlace(widget.placeid);
    });
  }

  AsyncMemoizer _memoizer_img = AsyncMemoizer();
  AsyncMemoizer _memoizer_plc = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainRoute(camera: widget.camera),
          ),
        );
        return false;
      }),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Your Places"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: FutureBuilder(
                  future: _fetchPlaceData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Container();

                    place plc = place.fromJson(snapshot.data);
                    //print(place.fromJson(snapshot.data));
                    return Text(plc.descr, style: TextStyle(fontSize: 30));
                    //return Container();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 70.0,
                  right: 70.0,
                ),
                child: FutureBuilder(
                  future: _fetchImageData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Container();
                    return Image.memory(
                        base64Decode(snapshot.data.toString() ?? ""));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: FutureBuilder(
                  future: _fetchPlaceData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Container();
                    place plc = place.fromJson(snapshot.data);
                    String num_likes = plc.num_likes.toString();
                    return ElevatedButton.icon(
                      onPressed: () {},
                      label: Text(num_likes),
                      icon: Icon(Icons.thumb_up),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "Coordinates",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: FutureBuilder(
                  future: _fetchPlaceData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Container();

                    place plc = place.fromJson(snapshot.data);
                    //print(place.fromJson(snapshot.data));
                    String lat = plc.lat.toString();
                    String lng = plc.lng.toString();
                    return Text("$lat, $lng");
                    //return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
