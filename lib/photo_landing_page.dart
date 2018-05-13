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
import 'dart:core';
import 'package:http/http.dart' as http;


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
  ClanData clanData;

  File _image;
  List<DocumentSnapshot> images;
  List<String> imageURLs = new List<String>();
  String currentClanID = "";

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> imageList;
  CollectionReference collectionReference;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this);
    currentClanID = clanUserProfile.clanNameList[0];
    getClanData();
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
        actions: <Widget>[
          new FlatButton(
           child: new Text("+"),
          onPressed: () => pickUpload()
          .then((File image) => upload(image)),
          )
        ]
      ),
     backgroundColor: Colors.blueGrey, 
     body: imageList != null?
     new StaggeredGridView.countBuilder(
       padding: new EdgeInsets.all(8.0),
       crossAxisCount: 4,
       itemCount: imageURLs.length,
       itemBuilder: (context, i){
         String url = imageURLs[i];
         return new Material(
          elevation: 8.0,
          borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
          child: new InkWell(
            child: new Hero(
              tag: url,
              child: new FadeInImage(
                image: new NetworkImage(url),
                fit: BoxFit.cover,
                placeholder: new AssetImage("assets/loading.jpg"),
              ),
            )
          )
         );
       },
       staggeredTileBuilder: (i) => new StaggeredTile.count(2, i.isEven?2:3),
       mainAxisSpacing: 8.0,
       crossAxisSpacing: 8.0,
     ): new Center(
       child: new CircularProgressIndicator(),
     ),
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
    
    //update database to reflect uploaded file
    updateClanDatabase(image, clanUserProfile.firebaseUser.uid.toString() + "_" + imageID.toString() + ".jpg");
    //update local clan object

  }

  updateClanDatabase(File image, String storageRef) async {
    DocumentReference imageDoc = Firestore.instance.collection(this.clanData.imageCollectionID).document(storageRef);
    var now = new DateTime.now();String formatted = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year.toString()}";
    Map<String,String> data = <String,String>{
      "fileSize" : "110",
      "localPath" : image.path,
      "storageRef" : storageRef,
      "uploadedBy" : clanUserProfile.emailAddress,
      "uploadedDate" : formatted,
      "galleryNo" : "0"
    };
    await imageDoc.setData(data);
    clanData.imageDataList.add(data);
  }

  getClanData() async {
    DocumentReference clanDoc = Firestore.instance.collection("clanData").document(currentClanID);
    clanDoc.get().then((datasnapshot){
        if (datasnapshot.data != null) {
            ClanData clanData = new ClanData();
            clanData.clanID = currentClanID;
            clanData.clanPassword = datasnapshot['clanPassword'];
            clanData.clanCreator = datasnapshot["clanCreator"];
            clanData.clanCreatorName = datasnapshot["clanCreatorName"];
            clanData.clanCreatorPhotoUrl = datasnapshot["clanCreatorPhotoUrl"];
            clanData.imageCollectionID = datasnapshot["imageCollectionID"];

            //get image library details
            clanData.imageDataList = new List<Map<String, String>>();
            CollectionReference imageCollection = Firestore.instance.collection(clanData.imageCollectionID);
            var query = imageCollection.where("fileSize", isEqualTo: "100");

            query.getDocuments()
            .then((docs) {
              if (docs.documents != null) {
                for (var doc in docs.documents) {
                  clanData.imageDataList.add(doc.data);
                }
              }
              setState(() {
                this.clanData = clanData;
                  collectionReference = imageCollection;
                });
                this.subscription = collectionReference.snapshots().listen((datasnapshot){
                setState(() {
                  imageList = datasnapshot.documents;
                });
              });
             });
        }
    });
  
  }
  updateUrls(String storageRefStr) async {
    List<String> newImageURLs = new List<String>();
    for (var doc in imageList) {
      String storageRefStr = doc['storageRef'];
      StorageReference imageRef =  FirebaseStorage.instance.ref().child(storageRefStr);
      String url = await imageRef.getDownloadURL();
      newImageURLs.add(url);
    }

    setState(() {
      imageURLs = newImageURLs;
    });
  }

}