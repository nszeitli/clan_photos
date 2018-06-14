import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zoomable_image/zoomable_image.dart';

class FullScreenImagePage extends StatefulWidget {
  StorageReference fullImageRef;
  FullScreenImagePage(this.fullImageRef);
  
  @override
  _FullScreenImagePageState createState() => new _FullScreenImagePageState(this.fullImageRef);
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  StorageReference fullImageRef;
  _FullScreenImagePageState(this.fullImageRef);
  Image _image = new Image.asset("assets/loading.jpg"); //load thumbnail while full res 
  String _menuSelection = "none";
  final LinearGradient backgroundGradient = new LinearGradient(
    colors: [new Color(0x10000000), new Color(0x30000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight);

  List<DropdownMenuItem<String>> menuList = new List<DropdownMenuItem<String>>();
  


  @override
  void initState() {
    super.initState();
    menuList.add(new DropdownMenuItem<String>(
      child: new Text("delete"),
    ));
    downloadImage();
    
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SizedBox.expand(
        child: new Container(
          decoration: new BoxDecoration(gradient: backgroundGradient),
          child: new Column(
            children: <Widget>[
              new Align(
                  alignment: Alignment.topCenter,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new AppBar(
                        elevation: 0.0,
                        backgroundColor: Colors.transparent,
                        leading: new IconButton(
                          icon: new Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: ()=> Navigator.of(context).pop()
                          ),
                          actions: <Widget>[
                            new PopupMenuButton(
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  child: new Text("Delete"),
                                  value: "Delete"),
                                PopupMenuItem<String>(
                                  child: new Text("Share"),
                                  value: "Share"),],
                                  icon: new Icon(Icons.more_vert, color: Colors.black),
                                  onSelected: (strResonse) {
                                    switch(strResonse) { 
                                      case "Delete": {  _menuSelection = "Delete"; } 
                                      Navigator.pop(context, _menuSelection);
                                      break; 
                                    
                                      case "Share": {   _menuSelection = "Share";} 
                                      Navigator.pop(context, _menuSelection);
                                      break; 
                                    
                                      default: { print("Invalid choice"); }
                                      break; 
                                  } 
                                  }
                              ),
                            ],
                        )
                      ],
                    )
                  ),
              
              new Align(
                alignment: Alignment.center,
                child: new ZoomableImage(new AssetImage("assets/dog.jpg"), maxScale: 2.0, placeholder: new CircularProgressIndicator(),) ,
                ),
                
                ],
              ),
            ),
          ),
        );
      }

    downloadImage() async {
      var data = await this.fullImageRef.getData(100000000);
        setState(() {
          _image = new Image.memory(data);
        });
    }
}

