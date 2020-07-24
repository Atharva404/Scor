
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scor/create_goal.dart';
import 'package:scor/home_page.dart';
import 'package:scor/profile.dart';

Future navigateToSubPage(context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateGoal()));
}

class LeaderboardPage extends StatefulWidget {
  final FirebaseUser user;
  final String email;

  LeaderboardPage({Key key, this.user, this.email}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  var name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xFFFFFFFF),
      body: Wrap(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 80, 30, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ],
            ),
          ),
          
          Container(
            height: 600,
            child: ListView(
              // shrinkWrap: true,
              children: [allCards()],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: yourCard(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          if (index != 1) {
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

  Widget allCards() {
    Stream<QuerySnapshot> firestoreInstance = Firestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .snapshots();
    return new StreamBuilder(
      stream: firestoreInstance,
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
                list.add(
                  leaderCard(
                    i,
                    snapshot.data.documents.elementAt(i).data['name'],
                    snapshot.data.documents.elementAt(i).data['points'],
                    90.0,
                  ),
                );
              
            }
            return new Column(children: list);
        }
      },
    );
  }

  Widget yourCard() {
    Stream<QuerySnapshot> firestoreInstance = Firestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .snapshots();
    return new StreamBuilder(
      stream: firestoreInstance,
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
                if (snapshot.data.documents.elementAt(i).data['email'] ==
                    widget.email) {
                  list.add(
                    leaderCard(
                      i,
                      snapshot.data.documents.elementAt(i).data['name'],
                      snapshot.data.documents.elementAt(i).data['points'],
                      60.0,
                    ),
                  );
                }
            }
            return list[0];
        }
      },
    );
  }

  Widget leaderCard(i, name, points, height) {
    Color color;

    if (i == 0) {
      color = new Color(0xFFE4BF57);
    } else if (i == 1) {
      color = new Color(0xFFA9A9A9);
    } else if (i == 2) {
      color = new Color(0xFFCD7F32);
    } else {
      color = Colors.grey[300];
    }
    return Container(
      child: Container(
        margin: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${i + 1}. $name",
              style: TextStyle(fontSize: 30),
            ),
            Text(
              "$points",
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
      height: height,
      width: double.infinity,
      margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: color,
            blurRadius: 10.0,
            offset: new Offset(0.0, 3.0),
          ),
        ],
      ),
    );
  }
}
