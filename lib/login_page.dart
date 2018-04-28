import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget{
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  import 'package:flutter_facebook_login/flutter_facebook_login.dart';
  

  //Sign in method
  Future<FirebaseUser> _signIn() async{
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
      idToken: gSA.idToken,
      accessToken: gSA.accessToken
    );

    print("User name : ${user.displayName}");
    return user;
  }

  void signOut() {
    googleSignIn.signOut();
    print("User signed out");
  }

  @override
  void initState() {
    super.initState();
    _iconAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 500),
    );

    _iconAnimation = new CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeOut,
    );
    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
     backgroundColor: Colors.blueGrey, 
     body: new Stack(
       fit: StackFit.expand,
       children: <Widget>[
        new Image(
          image: AssetImage("assets/dog.jpg"),
          fit: BoxFit.cover ,     
           color: Colors.black87,
           colorBlendMode: BlendMode.darken,
        ),
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlutterLogo(
              size: _iconAnimation.value * 100,
            ),
            new Form(
              child: new Theme(
                data: new ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.teal,
                  inputDecorationTheme: new InputDecorationTheme(
                    labelStyle: new TextStyle(color: Colors.white, fontSize: 20.0)
                  )
                ),
                child:new Container(
                  padding: new EdgeInsets.all(60.0),
                  child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[ 
                  new TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Enter Email",
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Enter Password",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 40.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new MaterialButton(
                      height: 40.0,
                      minWidth: 90.0,
                      onPressed: () => {},
                      color: Colors.teal,
                      textColor: Colors.white,
                      child: new Text("login")
                      ),
                      new Padding(padding: EdgeInsets.all(10.0),),
                      new MaterialButton(
                        height: 40.0,
                        minWidth: 90.0,
                        onPressed: () => _signIn()
                        .then((FirebaseUser user) => print(user))
                        .catchError((e) => print(e)),
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: new Text("Sign in with google")
                      ),
                    ] 
                  )
                )
                ]
              ),
                )
              )
            )
          ],
        )
       ],
     ),
    );
  }
}