import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'globals.dart' as globals;
import 'dart:io';

import 'package:camera/camera.dart';
import 'placePage.dart';

class AddPlaceForm extends StatefulWidget {
  AddPlaceForm({
    super.key,
    required this.placelng,
    required this.placelat,
    required this.camera,
  });

  final double placelng;
  final double placelat;
  final CameraDescription camera;

  @override
  State<AddPlaceForm> createState() => _AddPlaceFormState();
}

class _AddPlaceFormState extends State<AddPlaceForm> {
  // Login success or failure
  bool isInvalidVisible = false;

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Take the picture"),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            _controller.setFlashMode(FlashMode.off);

            final image = await _controller.takePicture();

            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                    imagePath: image.path,
                    placelat: widget.placelat,
                    placelng: widget.placelng,
                    camera: widget.camera),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.placelat,
    required this.placelng,
    required this.camera,
  });

  final double placelng;
  final double placelat;
  final CameraDescription camera;

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  // text input controllers
  final descrController = TextEditingController();

  @override
  void dispose() {
    descrController.dispose();
  }

  Future addPlace(String descr, double lat, double lng, int userid) async {
    var client = http.Client();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'addPlace',
          'descr': descr,
          'lat': lat.toString(),
          'lng': lng.toString(),
          'userid': userid.toString(),
        },
      );

      return int.parse(jsonDecode(response.body));
    } finally {
      client.close();
    }
  }

  Future uploadImage(String imagePath, int placeid) async {
    var client = http.Client();
    try {
      final bytes = File(imagePath).readAsBytesSync();
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'addImage',
          'placeid': placeid.toString(),
          'imagedata': base64.encode(bytes),
        },
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    String lat = widget.placelat.toString();
    String lng = widget.placelng.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload your Place')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30.0, left: 50, right: 50),
              child: Image.file(
                File(widget.imagePath),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
              child: TextField(
                controller: descrController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                    hintText: 'Beatiful place in city...'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text("Coordinates", style: TextStyle(fontSize: 30)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1),
              child: Text("$lat, $lng", style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 0),
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    addPlace(descrController.text, widget.placelat,
                            widget.placelng, globals.global_userid)
                        .then((newPlaceId) {
                      uploadImage(widget.imagePath, newPlaceId).then(
                        (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceRoute(
                                  placeid: newPlaceId, camera: widget.camera),
                            ),
                          );
                        },
                      );
                    });
                  },
                  child: const Text(
                    'Publsh!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
