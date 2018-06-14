import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'photo_landing_page.dart';
import 'clan_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'login_page.dart';
import 'dart:math';




//First thing user see's
//Check if already logged into Firebase, if so, load profile data and goto landing page
//If not logged in, search for stored shared prefs, and attempt to login using those, load profile and goto landing
//If no shared prefs or login fails, goto login page


class LaunchPage extends StatefulWidget {
  

  @override
  _LaunchPageState createState() => new _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _angleAnimation;
  Animation<double> _scaleAnimation;
  bool _loadingInProgress = true;

  //User profile data
  ClanUserProfile _clanUserProfile;
  SharedPreferences prefs;

  //Colours
  final sandColor = const Color(0xFFE4DACE);
  final medallionColor = const Color(0xFFE5BB4B);
  final blueColor = const Color(0xFF4C8EB0);
  final spiceColor = const Color(0xFF631E17);

  //Loading text
  String _currentLoadingStatus = "Checking internet connection";
  //Auth instances
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    //Animation section
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _angleAnimation = new Tween(begin: 0.0, end: 360.0).animate(_controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    _scaleAnimation = new Tween(begin: 1.0, end: 6.0).animate(_controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    _angleAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_loadingInProgress) {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        if (_loadingInProgress) {
          _controller.forward();
        }
      }
    });
    _controller.forward();

    //load prefs
    _getPrefs();

    _checkNet().then((netOK) {
      if (netOK) {
        //check if already logged in
        _checkLoggedIn().then((user) {
          if (user == null) {
            String email = prefs.getString('userEmail') ?? "";
            String savedPass = prefs.getString('userPass') ?? "";
            String fbToken = prefs.getString('fbToken') ?? "";
            //Attempt login using fb token
            if(fbToken.length > 0) 
            {
              _loginFBToken(fbToken).then((user){
                if(user == null) 
                { 
                  //Login unsuccessful, push to login page
                  _setStateAndLog("Facebook login unsuccessful, try logging in again");
                  Navigator.pushAndRemoveUntil(
                    context,  new MaterialPageRoute(builder: (context) => new LoginPage()), (Route<dynamic> route) => false );
                  Scaffold
                    .of(context)
                    .showSnackBar(new SnackBar(content: new Text("Facebook login unsuccessful, try logging in again")));
                  } 
                  else {
                    //save prefs and load landing page
                    _setClanUserProfile(user);

                    _setStateAndLog("Facebook login successful");
                    Navigator.pushAndRemoveUntil(
                      context,  new MaterialPageRoute(builder: (context) => new PhotoLandingPage(clanUserProfile: _clanUserProfile)), (Route<dynamic> route) => false );
                    Scaffold
                      .of(context)
                      .showSnackBar(new SnackBar(content: new Text("Welcome back")));
                  }
              }); 
            }
            else {
              if (email.length > 0 && savedPass.length > 0) {
                _loginWithEmail(email, savedPass).then((user){
                  if (user == null) {
                    //Login unsuccessful, push to login page
                _setStateAndLog("Login unsuccessful, try logging in again");

                Navigator.pushAndRemoveUntil(
                  context,  new MaterialPageRoute(builder: (context) => new LoginPage()), (Route<dynamic> route) => false );

                Scaffold
                  .of(context)
                  .showSnackBar(new SnackBar(content: new Text("Login unsuccessful, try logging in again")));
                  }
                  else {
                    _setClanUserProfile(user);

                    _setStateAndLog("Email login successful");
                    Navigator.pushAndRemoveUntil(
                      context,  new MaterialPageRoute(builder: (context) => new PhotoLandingPage(clanUserProfile: _clanUserProfile)), (Route<dynamic> route) => false );
                    Scaffold
                      .of(context)
                      .showSnackBar(new SnackBar(content: new Text("Welcome back")));
                  }
                });
              }
              //Login unsuccessful, push to login page
                _setStateAndLog("Login unsuccessful, try logging in again");
                Navigator.pushAndRemoveUntil(
                  context,  new MaterialPageRoute(builder: (context) => new LoginPage()), (Route<dynamic> route) => false );
                Scaffold
                  .of(context)
                  .showSnackBar(new SnackBar(content: new Text("Facebook login unsuccessful, try logging in again")));
            }
          }
          else {
            //save prefs and load landing page
            _setClanUserProfile(user);

            //Login successful, push to landing page
            _setStateAndLog("Login saved from last time");
            Navigator.pushAndRemoveUntil(
              context,  new MaterialPageRoute(builder: (context) => new PhotoLandingPage(clanUserProfile: _clanUserProfile)), (Route<dynamic> route) => false );
            Scaffold
              .of(context)
              .showSnackBar(new SnackBar(content: new Text("Welcome back")));
            }
          });
        }
      else {
        _netNotOK();
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
     backgroundColor: spiceColor, 
     body: new Stack(
       fit: StackFit.expand,
       children: <Widget>[
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //_buildAnimation(),
            new Text(
              _currentLoadingStatus, style: new TextStyle(color: blueColor)
            )
          ],
        )
       ],
     ),
    );
  }

  Future<bool> _checkNet() async {
    bool check = false;
    int maxTries = 3;
    int currentTries = 0;
    
    while(currentTries < maxTries && !check ) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if(result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
          setState(() { _currentLoadingStatus = "Interet connected" ;} );  
          check = true;return check;
        } else {
          print('not connected');
          setState(() { _currentLoadingStatus = "Connectivity error" ;} ); 
          new Future.delayed(const Duration(seconds: 1)); //recommend
        } 
      }
      catch (e) {}
      currentTries++;
    }
    return check;
  }

  //
  // Login methods
  //

  Future<FirebaseUser> _checkLoggedIn() async {
    //check if already logged in
    setState(() { _currentLoadingStatus = "Checking if already logged in" ;} );  
    FirebaseUser user = await _auth.currentUser().catchError((error) => _setStateAndLog(error.toString()));
    if (user == null) { _setStateAndLog("Not logged in yet...") ; return null;  }

    return user;
  }

  _getPrefs() async {
    _setStateAndLog("Getting saved preferences");  
    prefs = await SharedPreferences.getInstance().catchError((error) => _setStateAndLog(error.toString()));
    prefs.setString('fbToken', "");
    _setStateAndLog("Locally saved preferences retrieved");
  }

  Future<FirebaseUser> _loginFBToken(String token) async {
    FirebaseUser user;
    _setStateAndLog("Attempting facebook login using previous token");
    _auth.signInWithFacebook(accessToken: token).catchError((error)  
    {
      _setStateAndLog(error.toString()); 
      return null;
      });
    return user;
  }

  Future<FirebaseUser> _loginWithEmail(String email, String pass) async {
    FirebaseUser user;
    _setStateAndLog("Attempting email login using saved details");
    _auth.signInWithEmailAndPassword(email: email, password: pass).catchError((error)  
    {
      _setStateAndLog(error.toString()); 
      return null;
      });
    return user;
  }

  _setClanUserProfile(FirebaseUser user) async {
    if (user.providerData[1].email != null) {
      //Previous fb login
      _clanUserProfile = new ClanUserProfile(user, true, false);
      _clanUserProfile.setDetailsFromFB();
    }
    else {
      _clanUserProfile = new ClanUserProfile(user, false, false);
      _clanUserProfile.setDetails();
    }
    await getProfileDataFromFirebase();
    updatePrefsOnProfile();
  }

  getProfileDataFromFirebase() {
    DocumentReference userDoc = Firestore.instance.collection("users").document(_clanUserProfile.emailAddress);
    _setStateAndLog("Downloading user profile data");
    userDoc.get().then((datasnapshot){
        if (datasnapshot.data != null) {
            ClanUserProfile updatedUser = _clanUserProfile;
            updatedUser.setClanDetails(datasnapshot['clanID']);
            updatedUser.displayName = datasnapshot['userName'];
            updatedUser.displayPhotoURL = datasnapshot["userPhotoUrl"];

            setState(() {
              _clanUserProfile = updatedUser;
            });
            _setStateAndLog("Profile of " + _clanUserProfile.displayName + " retrieved");
        }
    });
  }

  updatePrefsOnProfile() async {
    await prefs.setString('userEmail', _clanUserProfile.emailAddress);
    await prefs.setString('userDisplayName', _clanUserProfile.displayName);
  }

  _netNotOK() {
    _setStateAndLog("No internet connectivity, trying again");
    Scaffold
      .of(context)
      .showSnackBar(new SnackBar(content: new Text("No connectivity")));
      sleep(const Duration(seconds:2));
    Navigator.pushAndRemoveUntil(
      context,  new MaterialPageRoute(builder: (context) => new LaunchPage()), (Route<dynamic> route) => false );
  }

  _setStateAndLog(String message) {
    setState(() { _currentLoadingStatus = message ;} );  
    print(message);
  }

  //
  // Animation methods
  //

 
  Widget _buildAnimation() {
    double circleWidth = 10.0 * _scaleAnimation.value;
    Widget circles = new Container(
      width: circleWidth * 2.0,
      height: circleWidth * 2.0,
      child: new Column(
        children: <Widget>[
          new Row (
              children: <Widget>[
                _buildCircle(circleWidth,Colors.blue),
                _buildCircle(circleWidth,Colors.red),
              ],
          ),
          new Row (
            children: <Widget>[
              _buildCircle(circleWidth,Colors.yellow),
              _buildCircle(circleWidth,Colors.green),
            ],
          ),
        ],
      ),
    );
 
    double angleInDegrees = _angleAnimation.value;
    return new Transform.rotate(
      angle: angleInDegrees / 360 * 2 * PI,
      child: new Container(
        child: circles,
      ),
    );
  }
 
  Widget _buildCircle(double circleWidth, Color color) {
    return new Container(
      width: circleWidth,
      height: circleWidth,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
