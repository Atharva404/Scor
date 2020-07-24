import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scor/create_goal.dart';

import 'goal_page.dart';

Future navigateToSubPage(context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateGoal()));
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class GoalsPage extends StatefulWidget {
  final FirebaseUser user;
  final String email;

  GoalsPage({Key key, this.user, this.email}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  var name;
  Random random = new Random();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSwitched = false;
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xFFFFFFFF),
      body: Wrap(
        children: [
          Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 80, 30, 10),
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        if (value.isEmpty) {
                          search = value;
                        } else {
                          search = capitalize(value);
                        }
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search Goals'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [allCards()],
            ),
          ),
        ],
      ),
    );
  }

  Widget allCards() {
    Stream<QuerySnapshot> firestoreInstance;
    firestoreInstance = Firestore.instance
        .collection('goals')
        .orderBy('name')
        .startAt([search]).endAt([search + '\uf8ff']).snapshots();

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
            List<Widget> list = new List<Widget>();
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              if (!isSwitched) {
                list.add(
                  leaderCard(
                    i,
                    snapshot.data.documents.elementAt(i).data['name'],
                    snapshot.data.documents.elementAt(i).data['location'],
                    snapshot.data.documents.elementAt(i).data['purpose'],
                    snapshot.data.documents.elementAt(i).data['target'],
                    snapshot.data.documents.elementAt(i).data['creator'],
                    snapshot.data.documents.elementAt(i).data['score'],
                    60.0,
                  ),
                );
              }
            }
            return new Column(children: list);
        }
      },
    );
  }

  Widget leaderCard(i, name, String location, String purpose, String target,
      String creator, double score, height) {
    Color color = new Color.fromARGB(200, random.nextInt(1),
        random.nextInt(80) + 50, random.nextInt(50) + 50);

    return GestureDetector(
      onTap: () {
        print(widget.email);
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
        child: Container(
          margin: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$name",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              Text(
                "$location",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
        height: height,
        width: double.infinity,
        margin: new EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
      ),
    );
  }
}
