import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'globals.dart' as globals;
import 'registrationPage.dart';
import 'profilePage.dart';

class LoginRoute extends StatefulWidget {
  LoginRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  // Login success or failure
  bool isInvalidVisible = false;

  // text input controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
  }

  Future login(String email, var hash) async {
    var client = http.Client();
    try {
      var response = await http.post(
        Uri.parse(globals.host),
        body: {
          'request': 'login',
          'email': email,
          'hash': hash,
        },
      );
      // works
      var decodedResponse = jsonDecode(response.body);
      return decodedResponse;
    } finally {
      client.close();
    }
  }

  void _login(String email, String password) {
    var hash = sha256.convert(utf8.encode(password)).toString();
    login(email, hash).then((response) {
      var userid = response["UserId"];
      if (userid.runtimeType != int) {
        userid = int.parse(response["UserId"]);
      }
      globals.global_userid = userid;

      if (userid == -1) {
        setState(() {
          isInvalidVisible = true;
        });
      } else {
        // logged in
        setState(() {
          isInvalidVisible = false;
        });
      }

      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (globals.global_userid != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ProfileRoute(
                      camera: widget.camera,
                    )));
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Icon(
                Icons.account_circle,
                size: 150,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 0),
              child: Container(
                height: 50,
                width: 250,
                child: Visibility(
                  child: Text(
                    'Invalid Credentials',
                    style: TextStyle(color: Colors.red, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  visible: isInvalidVisible,
                ),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
              padding: const EdgeInsets.only(
                left: 0,
                right: 0,
                top: 15,
                bottom: 0,
              ),
              child: Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    _login(emailController.text, passwordController.text);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'New User?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegistrationRoute(camera: widget.camera),
                  ),
                );
              },
              child: const Text(
                "Register now",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
