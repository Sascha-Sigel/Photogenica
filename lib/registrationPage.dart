import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'globals.dart' as globals;
import 'loginPage.dart';

class RegistrationRoute extends StatefulWidget {
  RegistrationRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<RegistrationRoute> createState() => _RegistrationRouteState();
}

class _RegistrationRouteState extends State<RegistrationRoute> {
  // Registration feedback
  bool isInvalidVisible = false;

  bool isSuccessVisible = false;

  // text input controllers
  final usernameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void add_user(String username, String email, String password) async {
    var client = http.Client();
    String hash = sha256.convert(utf8.encode(password)).toString();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'register',
          'username': username,
          'email': email,
          'hash': hash,
        },
      );
      // works
      var decodedResponse = jsonDecode(response.body);
      if (decodedResponse == 'success') {
        isSuccessVisible = true;
      } else {
        isInvalidVisible = true;
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSuccessVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => LoginRoute(
                      camera: widget.camera,
                    )));
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registration Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 60.0),
              child: Icon(
                Icons.assignment_ind,
                size: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Visibility(
                child: Text(
                  'Invalid Input, please try again',
                  style: TextStyle(color: Colors.red, fontSize: 25),
                ),
                visible: isInvalidVisible,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter a username'),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
              ),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email id as abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 0),
              child: Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (usernameController.text != "" &&
                          emailController.text != "" &&
                          passwordController.text != "") {
                        add_user(usernameController.text, emailController.text,
                            passwordController.text);
                      } else {
                        isInvalidVisible = true;
                      }
                    });
                  },
                  child: const Text(
                    'Register',
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
    );
  }
}
