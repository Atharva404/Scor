import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CreateGoal extends StatefulWidget {
  @override
  _CreateGoalState createState() => new _CreateGoalState();
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class _CreateGoalState extends State<CreateGoal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final firestoreInstance = Firestore.instance;

  double score = 1.0;
  String _name, _location, _target, _purpose;

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
                  "Create a goal",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
                ),
                Wrap(
                  runSpacing: 10,
                  children: [
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Provide the name of the goal';
                        }
                      },
                      onSaved: (input) => _name = input,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Goal Name'),
                    ),
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Provide the purpose of the goal';
                        }
                      },
                      onSaved: (input) => _purpose = input,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Purpose'),
                    ),
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Provide the target of the goal';
                        }
                      },
                      onSaved: (input) => _target = input,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Target'),
                    ),
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Provide the location';
                        }
                      },
                      onSaved: (input) => _location = input,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Location'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0)),
                      width: double.infinity,
                      height: 60,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Goal score"),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              valueIndicatorColor: Colors.white,
                              inactiveTrackColor: Color(0xFF8D8E98),
                              activeTrackColor: Colors.white,
                              thumbColor: Colors.grey[700],
                              overlayColor: Colors.grey[400],
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 12.0),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 20.0),
                            ),
                            child: Slider(
                              value: score,
                              onChanged: (input) {
                                setState(() => score = input);
                              },
                              min: 1.0,
                              max: 10.0,
                              divisions: 9,
                              label: "$score",
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: new OutlineButton(
                        borderSide: BorderSide(width: 1),
                        onPressed: validateAndSave,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          "Create",
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
                      child: Text("Back to Home page"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> validateAndSave() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        var firebaseUser = await FirebaseAuth.instance.currentUser();
        firestoreInstance
            .collection("users")
            .document(firebaseUser.uid)
            .updateData({
          "points":  FieldValue.increment(5),
        }).then((_) {
          print("success!");
        });


        firestoreInstance.collection("goals").document().setData({
          "score": score,
          "name": capitalize(_name),
          "location": capitalize(_location),
          "purpose": _purpose,
          "target": _target,
          "creator": firebaseUser.email,
          "followers": [firebaseUser.email],
        }).then((_) {
          print("success!");
        });
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
