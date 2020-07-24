import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scor/create_goal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';

Future navigateToSubPage(context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateGoal()));
}

Future navigateToGoalPage(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => GoalsPage()));
}

class GoalView extends StatefulWidget {
  final String email;

  final String name;
  final String location;
  final String purpose;
  final String target;
  final String creator;
  final double score;

  GoalView(
      {Key key,
      this.name,
      this.location,
      this.purpose,
      this.target,
      this.creator,
      this.score,
      this.email})
      : super(key: key);

  @override
  _GoalViewState createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  final firestoreInstance = Firestore.instance;
  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title(widget.name),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  card(
                    widget.purpose,
                    20,
                    150,
                    300,
                    Colors.grey,
                    Colors.black,
                  ),
                  card(
                    "Creator : ${widget.creator}",
                    30,
                    150,
                    300,
                    Colors.blueGrey[700],
                    Colors.white,
                  ),
                ],
              )),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Join",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  getGoal()
                ],
              ),
            ),
          ),
          Divider(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: new Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: FlatButton(
                color: new Color(0xFF000000),
                onPressed: addPoints,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "Log your score",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          card(
            "Location :  ${widget.location}",
            25,
            80,
            double.infinity,
            Colors.blue,
            Colors.white,
          ),
          card(
            "Target :  ${widget.target}",
            20,
            130,
            double.infinity,
            Colors.grey[300],
            Colors.black,
          ),
        ],
      ),
    );
  }

  Widget title(name) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$name",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 38,
              height: 1.5,
            ),
          ),
          Text(
            "Score :  ${format(widget.score)}/10",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget card(
      name, double size, double height, double width, Color bg, Color text) {
    // Color color = Colors.grey;
    return Container(
      child: Text(
        "$name",
        style: TextStyle(fontSize: size, color: text),
        textAlign: TextAlign.start,
      ),
      height: height,
      width: width,
      padding: new EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: new BoxDecoration(
        color: bg,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: bg,
            blurRadius: 10.0,
            offset: new Offset(0.0, 3.0),
          ),
        ],
      ),
    );
  }

  Widget getGoal() {
    Stream<QuerySnapshot> firestoreInstance;
    firestoreInstance = Firestore.instance.collection('goals').snapshots();
    bool isSwitched = false;

    return new StreamBuilder(
        stream: firestoreInstance,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text("");
            default:
              print(widget.email);
              var doc;
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                if (snapshot.data.documents.elementAt(i).data['name'] ==
                    widget.name) {
                  doc = snapshot.data.documents.elementAt(i);
                }
              }
              for (var j = 0; j < doc.data['followers'].length; j++) {
                if (doc.data['followers'].elementAt(j) == widget.email) {
                  print("bruh " + doc.data['followers'].elementAt(j));
                  isSwitched = true;
                  break;
                }
              }
          }
          return Switch(
            value: isSwitched,
            onChanged: (input) {
              setState(() {
                setGoal(input);
              });
            },
          );
        });
  }

  Future<void> setGoal(input) async {
    Firestore.instance.collection('goals').getDocuments().then((doc) {
      for (var i = 0; i < doc.documents.length; i++) {
        if (doc.documents.elementAt(i).data['name'] == widget.name) {
          print(doc.documents.elementAt(i).data['name']);
          if (input) {
            firestoreInstance
                .collection("goals")
                .document(doc.documents.elementAt(i).documentID)
                .updateData({
              "followers": FieldValue.arrayUnion(['${widget.email}']),
            }).then((_) {
              print("success!");
            });
          } else {
            firestoreInstance
                .collection("goals")
                .document(doc.documents.elementAt(i).documentID)
                .updateData({
              "followers": FieldValue.arrayRemove(['${widget.email}']),
            }).then((_) {
              print("success FALSE!");
            });
          }
        }
      }
    });
  }

  Future<void> addPoints() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .updateData({
      "points": FieldValue.increment((widget.score).round()),
    }).then((_) {
      print("success!");
    });
  }
}
