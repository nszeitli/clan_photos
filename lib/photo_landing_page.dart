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
import 'package:image/image.dart' as image_util;
import 'package:path_provider/path_provider.dart';
import 'exif/read_exif.dart';
import 'exif/exif_types.dart';
import 'package:transparent_image/transparent_image.dart';
import 'fullscreen_image.dart';
import 'login_page.dart';



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
  List<Image> imageObjects = new List<Image>();
  List<File> thumbnailFiles = new List<File>();
  List<StorageReference> fullImageRefs = new List<StorageReference>();
  String currentClanID = "";

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> imageList = new List<DocumentSnapshot>();
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
    String headerString = " Clan: " + currentClanID;
    return new Scaffold(
      
      appBar: new AppBar(
        title: new Text(headerString, 
        style: new TextStyle(fontSize: 15.0),),
        
        actions: <Widget>[
        ]
      ),
     backgroundColor: Colors.blueGrey, 
     body: imageList != null?
     new StaggeredGridView.countBuilder(
       
       padding: new EdgeInsets.all(7.0),
       crossAxisCount: 4,
       itemCount: imageObjects.length,
       itemBuilder: (context, i){
         print(imageList.toString());
         return new Material(
          elevation: 8.0,
          borderRadius: new BorderRadius.all(new Radius.circular(7.0)),
          child: new InkWell(
              child: new FadeInImage(
                image: imageObjects[i].image,
                fit: BoxFit.cover,
                placeholder: new AssetImage("assets/dog.jpg"),
              ),
              onTap: () =>_navigateAndDisplaySelection(context,fullImageRefs[i]),
            ),
         );
       },
       staggeredTileBuilder: (i) => new StaggeredTile.count(2, i.isEven?2:3),
       mainAxisSpacing: 8.0,
       crossAxisSpacing: 8.0,
     ): new Center(
       child: new CircularProgressIndicator(),
     ),
     drawer: new Drawer(
       child: new ListView( 
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(clanUserProfile.displayName),
            accountEmail: new Text(clanUserProfile.emailAddress),
            currentAccountPicture: new GestureDetector(
              child: new CircleAvatar(
                backgroundImage: new NetworkImage(clanUserProfile.displayPhotoURL),
              ),
            ),
          ),
          new ListTile(
            title: new Text("Log out"),
            trailing: new Icon(Icons.arrow_upward),
            onTap: _logOut(),
          ),
          new ListTile(
            title: new Text("Second Page"),
            trailing: new Icon(Icons.arrow_upward)
          ),
          new Divider(),
          new ListTile(
            title: new Text("Close"),
            trailing: new Icon(Icons.cancel)
          )
        ],
       ),
     ),
     floatingActionButton: new FloatingActionButton(
       backgroundColor: Colors.blueAccent,
       child: new Text("+", style: new TextStyle(fontSize: 25.0, color: Colors.white,)),
       onPressed: () {
          //debugDumpApp();
          pickUpload().then((image) => upload(_image));
        }),
    );
  }

  _logOut() async {
    //Logs out of firebase account
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,  new MaterialPageRoute(builder: (context) => new LoginPage()), (Route<dynamic> route) => false );

      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Logged out")));
  }

  _navigateAndDisplaySelection(BuildContext context, StorageReference storRef) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new FullScreenImagePage(storRef)),
    );


    Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("$result")));

    switch(result) { 
        case "Delete": {
              deleteClanData(storRef.path);
            } 
        break; 
      
        case "Share": {  } 
        break; 
      
        default: { print("Invalid choice"); }
        break; 
    } 

  }

  
  


  Future<File> pickUpload() async  {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      
        setState(() {
      _image = image;
      });
      return image;
  }

  Future<File> getThumbnail(File fullsizeImage, String thumbnailPath) async {
    Map<String, IfdTag> exif = await readExifFromFile(new File(fullsizeImage.path));
    String orientation = exif["Image Orientation"].printable;

    
    File thumbnailFile;
    image_util.Image im = image_util.decodeImage(fullsizeImage.readAsBytesSync());
    image_util.Image thumbnail = image_util.copyResize(im, 800);
    if(orientation.contains('Rotated')) {
      thumbnail = image_util.copyRotate(thumbnail, 90);
    }
    
    var data = image_util.encodeJpg(thumbnail); 
    thumbnailFile = new File(thumbnailPath);
    try { thumbnailFile.writeAsBytesSync(data);} catch (error) {print(error);}
      

    return thumbnailFile;
  }

  
   upload(File imagee) async {
    //Create filename & storeage reference for new image
    var rng = new Random(); int imageID = rng.nextInt(1000000); // TODO get unique iterative fileID
    final StorageReference ref = FirebaseStorage.instance.ref().child(currentClanID + "_"  + imageID.toString() + ".jpg");

    //Thumbnail
    String extension = ((imagee.path).replaceRange(0, (imagee.path).length - 4, ""));
    StorageReference thumbRef = FirebaseStorage.instance.ref().child(currentClanID + "_"  + imageID.toString() + "_thumb" + ".jpg");
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String thumbnailPath = tempPath + "/" + currentClanID + "_"  + imageID.toString() +  "_thumbnail" + extension;

    File thumbnailFile = await getThumbnail(imagee, thumbnailPath);
    

    //Start upload talk and await completion
    print("Starting upload: " + currentClanID + "_" + imageID.toString() + ".jpg");
    final StorageUploadTask uploadTaskThumb = thumbRef.putFile(thumbnailFile); 
    final Uri downloadUrlThumb = (await uploadTaskThumb.future).downloadUrl;
    print("Upload complete");
    
    //update database to reflect uploaded file
    updateClanDatabase(imagee, currentClanID + "_"  + imageID.toString()  + ".jpg", currentClanID + "_"  + imageID.toString() + "_thumb"  + ".jpg");

    //update local clan object
    setState(() {
        imageObjects.add(new Image.file(thumbnailFile));
        thumbnailFiles.add(thumbnailFile);
    });

    //Start upload talk and await completion
    print("Starting upload: " + currentClanID + "_" + imageID.toString() + ".jpg");
    final StorageUploadTask uploadTask = ref.putFile(imagee); 
    uploadTask.future.then((done) => print("Upload complete"));
    setState(() {
        fullImageRefs.add(ref);
    });
  }

  updateClanDatabase(File image, String storageRef, String thumbRef) async {
    //New doc ref to save metadata for image
    DocumentReference imageDoc = Firestore.instance.collection(this.clanData.imageCollectionID).document(storageRef);
    var now = new DateTime.now();String formatted = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year.toString()}";
    Map<String,String> data = <String,String>{
      "fileSize" : "110",
      "localPath" : image.path,
      "storageRef" : storageRef,
      "thumbStorageRef" : thumbRef,
      "uploadedBy" : clanUserProfile.emailAddress,
      "uploadedDate" : formatted,
      "galleryNo" : "0"
    };
    await imageDoc.setData(data);
    clanData.imageDataList.add(data);
  }

  deleteClanData(String storageRef) async {
    //New doc ref to save metadata for image
    DocumentReference imageDoc = Firestore.instance.collection(this.clanData.imageCollectionID).document(storageRef);
    StorageReference storeRef = FirebaseStorage.instance.ref().child(storageRef);
    String thumb = storageRef.replaceAll(".jpg", ""); thumb = thumb + "_thumb.jpg";
    StorageReference thumbStoreRef = FirebaseStorage.instance.ref().child(thumb);
    imageDoc.delete();storeRef.delete(); thumbStoreRef.delete();
    setState(() {
      clanData.imageDataList.removeWhere((map) {
        map["storageRef"] == storageRef;
      });
    });
    setState(() {
      int iRef = 0; 
      for (var ref in fullImageRefs) {
        if(ref.path.contains(storageRef)) {imageObjects.removeAt(iRef);}
         iRef++;
      }
    fullImageRefs.removeWhere((ref) {
     ref.path.contains(storageRef);
    });
    });
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
            var query = imageCollection;

            query.getDocuments()
            .then((docs) {
              if (docs.documents != null) {
                for (var doc in docs.documents) {
                  //clanData.imageDataList.add(doc.data);
                  imageList.add(doc);
                }
              }
              setState(() {
                this.clanData = clanData;
                  collectionReference = imageCollection;
                });
                this.subscription = collectionReference.snapshots().listen((datasnapshot){
                setState(() {
                  imageList = datasnapshot.documents;
                  currentClanID = clanUserProfile.clanNameList[0];
                });
                setState(() {
                  for (var doc in imageList) {
                    String storageRefFull = doc['storageRef'];
                    StorageReference storageReference = FirebaseStorage.instance.ref().child(storageRefFull);
                    fullImageRefs.add(storageReference);
                    
                  }
                });
              });
             })
             .then((d) {
               downloadAllImages();
             });
        }
    });
  
  }

  downloadAllImages() async {
    for (var doc in imageList) {
      String storageRefStr = doc['thumbStorageRef'];
      var data = await FirebaseStorage.instance.ref().child(storageRefStr).getData(100000000);
        setState(() {
          imageObjects.add(new Image.memory(data));
        });
      }
    }

}