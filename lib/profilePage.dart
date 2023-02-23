import 'package:camera/camera.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'globals.dart' as globals;
import 'user.dart';

class ProfileRoute extends StatefulWidget {
  ProfileRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<ProfileRoute> createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {
  // Login success or failure
  bool isInvalidVisible = false;

  user global_user = user(id: 0, name: "0", email: "0");

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void get_user() async {
    if (globals.global_userid != -1) {
      var client = http.Client();
      try {
        var response = await http.post(
          Uri.parse(globals.host),
          body: {
            'request': 'getUser',
            'userid': globals.global_userid.toString(),
          },
        );
        // works
        setState(() {
          global_user = user.fromJson(jsonDecode(response.body));
        });
      } finally {
        client.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    get_user();
    String usr_email = global_user.email;
    String usr_name = global_user.name;

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
          title: const Text("Profile Page"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 60.0),
                  child: Icon(
                    Icons.account_circle,
                    size: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Benutzername: $usr_name",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Text(
                  "EMail: $usr_email",
                  style: TextStyle(fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 0, top: 30, bottom: 0),
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          globals.global_userid = -1;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainRoute(
                                camera: widget.camera,
                              ),
                            ),
                          );
                        });
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 130,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
