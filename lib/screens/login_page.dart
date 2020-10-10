import 'package:flutter/material.dart';
import 'package:bluestacks_assignment/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _username;
  String _password;
  bool _enableBtn;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    _enableBtn = false;
  }

//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    Widget formSetup(BuildContext context) {
      return new Form(
        key: _formKey,
        autovalidate: true,
        onChanged: () =>
            setState(() => _enableBtn = _formKey.currentState.validate()),
        child: new Column(
          children: <Widget>[
            new TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Username",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0)),
              ),
              keyboardType: TextInputType.text,
              validator: (val) {
                if (val.length == 0)
                  return "Please enter username";
                else if ((val.length < 3) || (val.length > 10))
                  return 'Please enter a valid username.';
                else
                  return null;
              },
              onSaved: (val) => _username = val,
            ),
            SizedBox(
              height: 30,
            ),
            new TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0)),
              ),
              obscureText: true,
              validator: (val) {
                if (val.length == 0)
                  return "Please enter password";
                else if ((val.length < 6) || (val.length > 10))
                  return 'Please enter a valid password.';
                else {
                  return null;
                }
              },
              onSaved: (val) => _password = val,
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 70.0),
            ),
            new RaisedButton(
              child: Text("Submit"),
              onPressed: (_enableBtn == true)
                  ? () {
                      print(_formKey.currentState.validate());
                      _formKey.currentState.save();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    }
                  : null,
              color: Colors.orange.shade300,
              disabledColor: Colors.grey,
            )
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    "images/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 0.0,
                ),
                formSetup(context),
                SizedBox(
                  height: 35.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
