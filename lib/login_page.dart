import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginPage extends StatefulWidget{
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FacebookLogin facebookSignIn = new FacebookLogin();

  //Facebook sign in method
  Future<FirebaseUser> _facebookSignIn() async {
    FirebaseUser user;
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

      switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print('''
         Logged in!
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
         user = await _auth.signInWithFacebook(
      accessToken: result.accessToken.token);
      print("Firebase login:" + user.displayName);
        return user;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');return null;
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');return null;
        break;
    }
    return user;
  }


    //Facebook sign out
    Future<Null> _facebookSignOut() async {
    await facebookSignIn.logOut();
  }

  //Google sign in method
  Future<FirebaseUser> _googleSignIn() async{
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
      idToken: gSA.idToken,
      accessToken: gSA.accessToken
    );

    print("User name : ${user.displayName}");
    return user;
  }
  //Google sign out method
  void googleSignOut() {
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
                        minWidth: 70.0,
                        onPressed: () => _facebookSignIn()
                        .then((FirebaseUser user) => print(user))
                        .catchError((e) => print(e)),
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: new Row(children: <Widget>[
                            new Text("Sign in with "),
                            new Padding(padding: EdgeInsets.all(5.0),),
                            new Image(image: new AssetImage("assets/fb.png"), width: 20.0, height: 20.0, color: null, fit: BoxFit.scaleDown, alignment: Alignment.center,)
                        ],) 
                      ),
                      new Padding(padding: EdgeInsets.all(7.0),),
                      new MaterialButton(
                        height: 40.0,
                        minWidth: 70.0,
                        onPressed: () => _googleSignIn()
                        .then((FirebaseUser user) => print(user))
                        .catchError((e) => print(e)),
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: new Row(children: <Widget>[
                            new Text("Sign in with "),
                            new Padding(padding: EdgeInsets.all(5.0),),
                            new Image(image: new AssetImage("assets/google.png"), width: 20.0, height: 20.0, color: null, fit: BoxFit.scaleDown, alignment: Alignment.center,)

                        ],) 
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