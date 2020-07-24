import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => new _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final firestoreInstance = Firestore.instance;

  String _email, _password, _name, _age;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: Form(
          key: _formKey,
          child: Container(
              margin: EdgeInsets.all(20),
              child: Center(
                  child: Wrap(
                runAlignment: WrapAlignment.center,
                runSpacing: 40,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                  ),
                  Wrap(
                    runSpacing: 10,
                    children: [
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Provide your name';
                          }
                        },
                        onSaved: (input) => _name = input,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Name'),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Provide your age';
                          }
                        },
                        onSaved: (input) => _age = input,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Age'),
                      ),
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Provide an email';
                          }
                        },
                        onSaved: (input) => _email = input,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Email'),
                      ),
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Provide a password';
                          }
                          if (input.length < 6) {
                            return 'Password must be longer than 6 letters';
                          }
                        },
                        onSaved: (input) => _password = input,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: new OutlineButton(
                          borderSide: BorderSide(width: 1),
                          onPressed: signUp,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Login Page"),
                      ),
                    ],
                  ),
                ],
              )))),
    );
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);

        var firebaseUser = await FirebaseAuth.instance.currentUser();
        Random rand = new Random();

        firestoreInstance
            .collection("users")
            .document(firebaseUser.uid)
            .setData({
          "name": _name,
          "email": _email,
          "age": _age,
          "friends": [],
          "friendRequests": [],
          "points": 0,
        }).then((_) {
          print("success!");
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: firebaseUser, email: _email),
          ),
        );
      } on PlatformException catch (error) {
        List<String> errors = error.toString().split(',');
        print("Error: " + errors[1]);
        var snackBar = SnackBar(
          content: Text('${errors[1]}'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
