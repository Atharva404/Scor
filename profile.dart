import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scor/home_page.dart';
import 'package:scor/leaderboard.dart';
import 'package:scor/login_page.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseUser user;
  final String email;

  ProfilePage({Key key, this.user, this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Random random = new Random();
  final firestoreInstance = Firestore.instance;

  var name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xFFFFFFFF),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.white],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: <Widget>[
              Container(
                child: Container(
                  width: double.infinity,
                  height: 350.0,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://i1.wp.com/acaweb.org/wp-content/uploads/2018/12/profile-placeholder.png?ssl=1'),
                          radius: 50.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        _welcomeText(),
                        SizedBox(
                          height: 8.0,
                        ),
                        Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 22.0, horizontal: 8.0),
                          clipBehavior: Clip.antiAlias,
                          color: Colors.white,
                          elevation: 8.0,
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(children: <Widget>[
                                Expanded(
                                    child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Email:  ${widget.email}",
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    points()
                                  ],
                                ))
                              ])),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: new Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: new Color(0xEFEF4848),
                        offset: Offset(0, 5),
                        blurRadius: 10),
                  ],
                ),
                child: FlatButton(
                  color: new Color(0xAFEF4848),
                  onPressed: signOut,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    "Log out",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(""),
          ),
        ],
        onTap: (index) {
          if (index != 2) {
            setState(() {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) => HomePage(
                      user: widget.user,
                      email: widget.email,
                    ),
                  ),
                );
              }
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) =>
                        LeaderboardPage(
                      user: widget.user,
                      email: widget.email,
                    ),
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => LoginPage(),
        ),
      );
    } on PlatformException catch (error) {
      List<String> errors = error.toString().split(',');
      print("Error: " + errors[1]);
    }
  }

  Widget _welcomeText() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(widget.user.uid)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading...");
          default:
            return Text(
              "${snapshot.data['name']}",
              style: TextStyle(fontSize: 25.0, color: Colors.white),
            );
        }
      },
    );
  }

  Widget points() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(widget.user.uid)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading...");
          default:
            return Text(
              "Total Points : ${snapshot.data['points']}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
            );
        }
      },
    );
  }
}
