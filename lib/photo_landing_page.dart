import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  List<DocumentSnapshot> images;
  String currentClanID = "test";
  File _image;

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
  
 upload(String clanID, FirebaseUser user, File image) async {
  var rng = new Random(); int imageID = rng.nextInt(1000000);
  final StorageReference ref = FirebaseStorage.instance.ref().child(clanID + "_"  + user.uid + "_" + imageID.toString() + ".jpg");
  final StorageUploadTask uploadTask = ref.putFile(image);
  final Uri downloadUrl = (await uploadTask.future).downloadUrl;
  return downloadUrl;
}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(actions: <Widget>[
        new RaisedButton(
          onPressed: pickUpload(user, "test"),
          child: new Text("+"))
      ],
        title: new Text("Your Photo Repositories"),
      ),
     backgroundColor: Colors.blueGrey, 
     body: new StaggeredGridView(children: <Widget>[],)
  

    );
  }


  pickUpload(FirebaseUser user,String currentClanID) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });

    await upload(currentClanID, user, image);
  }
}