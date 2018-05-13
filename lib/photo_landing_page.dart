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
import 'clan_user.dart';

class PhotoLandingPage extends StatefulWidget {
  PhotoLandingPage({this.clanUserProfile});
  final ClanUserProfile clanUserProfile;
  @override
  _PhotoLandingPageState createState() => new _PhotoLandingPageState(clanUserProfile: clanUserProfile);
}

class _PhotoLandingPageState extends State<PhotoLandingPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  _PhotoLandingPageState({this.clanUserProfile});
  ClanUserProfile clanUserProfile;

  List<DocumentSnapshot> images;
  String currentClanID = "";
  File _image;

  List<DocumentSnapshot> imageList;
  final CollectionReference collectionReference =
      Firestore.instance.collection("wallpapers");

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this);
    clanUserProfile.clanNameList[0];
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Your Photo Repositories"),
      ),
     backgroundColor: Colors.blueGrey, 
     //body: new StaggeredGridView(children: <Widget>[],)
     body: new Column(
       children: <Widget>[
         new Text("Staggered gridview"),
         new FlatButton(
           child: new Text("UPLOAD"),
          onPressed: () => pickUpload()
          .then((File image) => upload(image)),
          ),
       ],
     )
    );
  }


  Future<File> pickUpload() async  {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      
        setState(() {
      _image = image;
      });
    
    return image;
  }

   upload(File image) async {
  var rng = new Random(); int imageID = rng.nextInt(1000000); // TODO get unique iterative fileID
  final StorageReference ref = FirebaseStorage.instance.ref().child(currentClanID + "_" + "_" + imageID.toString() + ".jpg");
  print("Starting upload: " + currentClanID + "_" + imageID.toString() + ".jpg");
  final StorageUploadTask uploadTask = ref.putFile(image); 
  final Uri downloadUrl = (await uploadTask.future).downloadUrl;
  print("Upload complete");


}

}