import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scor/create_goal.dart';
import 'package:scor/goal_page.dart';
import 'package:scor/leaderboard.dart';
import 'package:scor/profile.dart';

import 'goals.dart';

Future navigateToSubPage(context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateGoal()));
}

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  final String email;

  HomePage({Key key, this.user, this.email}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future navigateToGoalPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GoalsPage(
                  user: widget.user,
                  email: widget.email,
                )));
  }

  Random random = new Random();
  final firestoreInstance = Firestore.instance;

  var name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25, 60, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _welcomeText('name'),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: new Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: new Color(0xFF82e4b5),
                                    offset: Offset(0, 5),
                                    blurRadius: 10),
                              ],
                            ),
                            child: FlatButton(
                              color: new Color(0xFF72d4a5),
                              onPressed: () {
                                navigateToSubPage(context);
                                // print(widget.email);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Create a goal",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: new Container(
                            child: FlatButton(
                              color: new Color(0xFF000000),
                              onPressed: () {
                                navigateToGoalPage(context);
                                // print(widget.email);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Search goals",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _tagTitle("Following", Icons.star, Colors.blueAccent),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: followGoals(),
              ),
              _tagTitle("Created by you", Icons.star, Colors.blueAccent),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: yourGoals(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index != 0) {
            setState(() {
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
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) =>
                        ProfilePage(
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

  Widget yourGoals() {
    return StreamBuilder(
      stream: Firestore.instance.collection('goals').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading...");
          default:
            List<Widget> list = new List<Widget>();

            for (var i = 0; i < snapshot.data.documents.length; i++) {
              if (snapshot.data.documents.elementAt(i).data['creator'] ==
                  widget.email) {
                list.add(_card(
                  snapshot.data.documents.elementAt(i).data['name'],
                  snapshot.data.documents.elementAt(i).data['location'],
                  snapshot.data.documents.elementAt(i).data['purpose'],
                  snapshot.data.documents.elementAt(i).data['target'],
                  snapshot.data.documents.elementAt(i).data['creator'],
                  snapshot.data.documents.elementAt(i).data['score'],
                ));
              }
            }
            return new Row(children: list);
        }
      },
    );
  }

  Widget followGoals() {
    return StreamBuilder(
      stream: Firestore.instance.collection('goals').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading...");
          default:
            List<Widget> list = new List<Widget>();

            for (var i = 0; i < snapshot.data.documents.length; i++) {
              for (var j = 0;
                  j <
                      snapshot.data.documents
                          .elementAt(i)
                          .data['followers']
                          .length;
                  j++) {
                if (snapshot.data.documents
                        .elementAt(i)
                        .data['followers']
                        .elementAt(j) ==
                    widget.email) {
                  list.add(_card(
                    snapshot.data.documents.elementAt(i).data['name'],
                    snapshot.data.documents.elementAt(i).data['location'],
                    snapshot.data.documents.elementAt(i).data['purpose'],
                    snapshot.data.documents.elementAt(i).data['target'],
                    snapshot.data.documents.elementAt(i).data['creator'],
                    snapshot.data.documents.elementAt(i).data['score'],
                  ));
                }
              }
            }
            return new Row(children: list);
        }
      },
    );
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Widget _card(String name, String location, String purpose, String target,
      String creator, double score) {
    Color color1 = new Color.fromARGB(200, random.nextInt(1),
        random.nextInt(100) + 50, random.nextInt(50) + 50);

    Color color2 = lighten(color1, 0.2);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GoalView(
                      name: name,
                      location: location,
                      purpose: purpose,
                      target: target,
                      creator: creator,
                      score: score,
                      email: widget.email,
                    )));
      },
      child: new Container(
        margin: EdgeInsets.all(10),
        height: 200,
        width: 150,
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            end: FractionalOffset(1, 0.6),
            stops: [1, 1],
            begin: Alignment.bottomRight,
            colors: [color1, color2],
            tileMode: TileMode.clamp,
          ),
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(12.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: lighten(color1, 0.1),
              blurRadius: 8.0,
              offset: new Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                location,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagTitle(String name, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Icon(
          //   icon,
          //   color: color,
          //   size: 30.0,
          // ),
        ],
      ),
    );
  }

  Widget _welcomeText(String data) {
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
            name = snapshot.data[data];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Hello, ${snapshot.data[data]}!\nWhat inspires you today?",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.brown[900],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}
