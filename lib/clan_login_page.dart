import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clan_create_page.dart';
import 'clan_user.dart';

// once logged in, if no clanID, ask to create new clan photo repo or login to existing repo

class ClanLoginPage extends StatefulWidget {
  ClanLoginPage({this.clanUserProfile});
  final ClanUserProfile clanUserProfile;
    @override
  _ClanLoginPageState createState() => new _ClanLoginPageState(clanUserProfile: clanUserProfile);
}

class _ClanLoginPageState extends State<ClanLoginPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  var _TextControllerA = new TextEditingController();
  var _TextControllerB = new TextEditingController();

   ClanUserProfile clanUserProfile;
  _ClanLoginPageState({this.clanUserProfile});

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this);
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
              size: 100.0,
            ),
            new Form(
              child: new Theme(
                data: new ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.teal,
                  inputDecorationTheme: new InputDecorationTheme(
                    labelStyle: new TextStyle(color: Colors.white, fontSize: 15.0)
                  )
                ),
                child:new Container(
                  padding: new EdgeInsets.all(60.0),
                  child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[ 
                  new Text(
                    "No photo repos on this account", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                    new Padding(padding: EdgeInsets.all(7.0),),
                  new Text(
                    "Sign into existing clan photo repo?", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                  new TextFormField(
                    decoration: new InputDecoration(
                    labelText: "Enter Clan ID",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _TextControllerA,
                  ),
                  new TextFormField(
                    decoration: new InputDecoration(
                      labelText: "Enter Clan Password",
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: _TextControllerB,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(top: 40.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new MaterialButton(
                          height: 40.0,
                          minWidth: 70.0,
                          onPressed: () => addExistingClan(),
                          color: Colors.teal,
                          textColor: Colors.white,
                          child: new Row(children: <Widget>[
                              new Text("Sign in",),
                          ],) 
                        ),
                        
                      ]
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(25.0),),
                  new Text(
                    "Or create a new Clan Photos repo?", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                    new Padding(padding: EdgeInsets.all(7.0),),
                    new Container(
                      width: 110.0, 
                      child: new MaterialButton(
                          height: 40.0,
                          minWidth: 70.0,
                          onPressed: () => Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => new ClanCreatePage(clanUserProfile: clanUserProfile)),
                          ),
                          color: Colors.teal,
                          textColor: Colors.white,
                          child: new Row(children: <Widget>[
                              new Text("Create new",),
                          ],) 
                        ),
                    ),
                    ],) 
                  )
              ),
            ),
          ] 
        )
       ]
      )
     );
  }

  void addExistingClan() {

  }


}