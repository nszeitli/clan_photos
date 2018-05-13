import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './clan_login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'photo_landing_page.dart';
import 'clan_user.dart';



class LoginPage extends StatefulWidget{
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  
  // Logo animation
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;
  
  //Authorisation vars
  
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = new GoogleSignIn();
  FacebookLogin facebookSignIn = new FacebookLogin();
  ClanUserProfile clanUserProfile;

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
                        .then((String loginState) => loadClanPage(loginState))
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

  void loadClanPage (String loginState)  async {
    if (loginState == "OK") {
      //check if user exists in database, if not write it
      DocumentReference userDoc = Firestore.instance.collection("users").document(clanUserProfile.emailAddress);
      
      await userDoc.get().then((datasnapshot){
              if ( datasnapshot.data == null ) {
              addUser(clanUserProfile, userDoc);
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new ClanLoginPage(clanUserProfile: clanUserProfile)),
                );
            }
            else {
              String clanID = datasnapshot['clanID'];
              if (clanID == null || clanID.length == 0) {
                // load clan login page
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new ClanLoginPage(clanUserProfile: clanUserProfile)),
                );
              }
              else {
                //get clan data
                clanUserProfile.setClanDetails(datasnapshot['clanID']);
                clanUserProfile.getClanPhotos(clanUserProfile.clanNameList[0]);
                //load photo page
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new PhotoLandingPage(clanUserProfile: clanUserProfile)),
                );
              }
            }
          }).catchError((e) => print(e.toString()));
      }
    }

  void addUser(ClanUserProfile clanUserProfile, DocumentReference docRef) {
  Map<String,String> data = <String,String>{
      "clanID" : "",
      "userEmail" : clanUserProfile.emailAddress,
      "userName" : clanUserProfile.displayName,
      "userPhotoUrl" : clanUserProfile.displayPhotoURL
    };
    _add(data, docRef);
    clanUserProfile.dataFromDoc = data;
  }

  void _add(Map<String,String> data, DocumentReference doc){
    doc.setData(data).whenComplete((){
      print("New user added");
    }).catchError((e) => print(e));
  }
  
  // void _delete(){
  //   userInfo.delete().whenComplete(() {
  //     print("deleted");
  //   });
  // }
  // void _update(Map<String,String> data){
  //   userInfo.updateData(data).whenComplete((){
  //     print("Data updated");
  //   }).catchError((e) => print(e));
  // }
  // void _fetch(){
  //   userInfo.get().then((datasnapshot){
  //     if (datasnapshot.exists) {
  //       String myText = datasnapshot.data['desc'];
  //     }
      
  //   });
  // }
  
  //Facebook sign in method
  Future<String> _facebookSignIn() async {
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
        clanUserProfile = new ClanUserProfile(user, true, false);
        clanUserProfile.setDetailsFromFB();
        return "OK";
        break;
      case FacebookLoginStatus.cancelledByUser:
        return ('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        return ('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
    return "login error";  
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

}