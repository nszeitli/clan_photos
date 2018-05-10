import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoLandingPage extends StatefulWidget {
  PhotoLandingPage({this.user});
  final FirebaseUser user;
  @override
  _PhotoLandingPageState createState() => new _PhotoLandingPageState(user: user);
}

class _PhotoLandingPageState extends State<PhotoLandingPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  _PhotoLandingPageState({this.user});
  final FirebaseUser user;

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
              new Text("Photo page", style: new TextStyle(fontSize: 30.0, color: Colors.blueAccent),)
            ]
          )
        ],
      )
    );
  }
}