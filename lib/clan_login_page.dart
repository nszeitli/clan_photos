import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// once logged in, if no clanID, ask to create new clan photo repo or login to existing repo

class ClanLoginPage extends StatelessWidget {
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
                    "Sign into existing clan photo repo?", 
                    style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                  new TextFormField(
                    decoration: new InputDecoration(
                    labelText: "Enter Clan ID",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    decoration: new InputDecoration(
                      labelText: "Enter Clan Password",
                    ),
                    keyboardType: TextInputType.text,
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
                          onPressed: () => print ("associate clan id method"),//_facebookSignIn()
                          //.then((FirebaseUser user) => loadClanPage(user))
                          //.catchError((e) => print(e)),
                          color: Colors.teal,
                          textColor: Colors.white,
                          child: new Row(children: <Widget>[
                              new Text("Sign in",),
                          ],) 
                        ),
                      ]
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(7.0),),
                    new Text(
                      "Create new clan photos repo", 
                      style: new TextStyle(color: Colors.white, fontSize: 18.0)
                    ),
                    new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "Choose a clan ID",
                        ),
                      keyboardType: TextInputType.phone,
                    ),
                    new Padding(padding: EdgeInsets.all(7.0),),
                    new MaterialButton(
                      height: 40.0,
                      minWidth: 70.0,
                      onPressed: () => print ("create new repo method"),//_facebookSignIn()
                      //.then((FirebaseUser user) => loadClanPage(user))
                      //.catchError((e) => print(e)),
                      color: Colors.teal,
                      textColor: Colors.white,
                      child: new Row( mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        new Text("Create"),
                      ],) 
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
}