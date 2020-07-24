import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scor/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email, _password;
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.all(20),
          child: Center(
            child: Wrap(
              runAlignment: WrapAlignment.center,
              runSpacing: 40,
              children: [
                Image.asset(
                  'images/logo.png',
                  width: 200,
                ),
                Wrap(
                  runSpacing: 10,
                  children: [
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
                      },
                      onSaved: (input) => _password = input,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Password'),
                    ),
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
                          onPressed: validateAndSave,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Wrap(
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: new OutlineButton(
                        color: new Color(0xFF003459),
                        borderSide: BorderSide(width: 1),
                        onPressed: () {
                          navigateToSubPage(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          "Sign up",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
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
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
      form.save();
      try {
        user = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: _email, password: _password))
            .user;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user, email: _email),
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
    } else {
      print('Form is invalid');
    }
  }
}

Future navigateToSubPage(context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => RegisterPage()));
}
