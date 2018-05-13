import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clan_user.dart';

class ClanCreatePage extends StatefulWidget {
  ClanCreatePage({this.clanUserProfile});
  final ClanUserProfile clanUserProfile;
  @override
  _ClanCreatePageState createState() => new _ClanCreatePageState(clanUserProfile: clanUserProfile);
}

class _ClanCreatePageState extends State<ClanCreatePage>
  
  with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var _TextControllerID = new TextEditingController();
  var _TextControllerPass = new TextEditingController();
  _ClanCreatePageState({this.clanUserProfile});
  ClanUserProfile clanUserProfile;

  
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
                          onPressed: () => attemptCreateRepo(_TextControllerID.text, _TextControllerPass.text)
                          .then((createdOK){
                            if(createdOK == true) 
                            {  //load photos page  
                            }  else {  //show text that clanID is taken  
                            }}
                          ),
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

  Future<bool> attemptCreateRepo (String clanID, String password) async {
    bool done = false;
    //check database if clanID exists, if so return false if not create and return true
    DocumentReference clanDoc = Firestore.instance.collection("clanData").document(clanID);
    await clanDoc.get().then((datasnapshot){
      if (datasnapshot.data == null) {
        //add new clan
        Map<String,String> data = <String,String>{
        "clanID" : clanID,
        "clanPassword" : password,
        "clanCreator" : clanUserProfile.emailAddress,
        "clanCreatorName" : clanUserProfile.displayName,
        "clanCreatorPhotoUrl" : clanUserProfile.displayPhotoURL
      };
        clanDoc.setData(data);
        DocumentReference userDoc = Firestore.instance.collection("users").document(clanUserProfile.emailAddress);
        String concatClanList = "";
        for (var s in clanUserProfile.clanNameList) {
          concatClanList = concatClanList + s + ";";
        }

        Map<String,String> userData = <String,String>{
          "clanID" : concatClanList,
        };
        userDoc.updateData(userData);
      }
      else {
        // clanID taken

        }
    });


    return done;
  }
}