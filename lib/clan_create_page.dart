import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClanCreatePage extends StatefulWidget {
  ClanCreatePage({this.user});
  final FirebaseUser user;
  @override
  _ClanCreatePageState createState() => new _ClanCreatePageState();
}

class _ClanCreatePageState extends State<ClanCreatePage>
  
  with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var _TextControllerID = new TextEditingController();
  var _TextControllerPass = new TextEditingController();
  _ClanCreatePageState({this.user});
  final FirebaseUser user;

  
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
                    "To create a new clan photos repo", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                    new Padding(padding: EdgeInsets.all(7.0),),
                  new Text(
                    "Think of a unique clanID and password", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                  new TextFormField(
                    decoration: new InputDecoration(
                    labelText: "Enter Clan ID",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _TextControllerID,
                    
                  ),
                  new TextFormField(
                    decoration: new InputDecoration(
                      labelText: "Enter Clan Password",
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: _TextControllerPass,

                  ),
                  new Padding(
                    padding: new EdgeInsets.only(top: 40.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new MaterialButton(
                          height: 40.0,
                          minWidth: 70.0,
                          onPressed: () => attemptCreateRepo(user, _TextControllerID.text, _TextControllerPass.text),
                          color: Colors.teal,
                          textColor: Colors.white,
                          child: new Row(children: <Widget>[
                              new Text("Create",),
                          ],) 
                        ),
                      ]
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

  bool attemptCreateRepo(FirebaseUser user, String clanID, String password) {
    bool done = false;
    //check database if clanID exists, if so return false if not create and return true

    


    return done;
  }
}