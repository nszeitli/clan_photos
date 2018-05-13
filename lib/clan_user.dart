import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
class ClanUserProfile {
  
  FirebaseUser firebaseUser;
  Map<String, String> dataFromDoc;
  String displayName;
  String emailAddress;
  String displayPhotoURL;
  File displayPhoto;

  bool fbLogin;
  bool googleLogin;
  
  List<String> clanNameList = new List<String>();
  List<ClanData> clanDataList= new List<ClanData>();

  ClanUserProfile(FirebaseUser firebaseUser, bool fbLogin, bool googleLogin) 
  {
    this.firebaseUser = firebaseUser;
    this.fbLogin = fbLogin;
    this.googleLogin = googleLogin;

  }

  void setDetailsFromFB() {
    this.displayName = this.firebaseUser.providerData[1].displayName;
    this.emailAddress = this.firebaseUser.providerData[1].email;
    this.displayPhotoURL = this.firebaseUser.providerData[1].photoUrl;

  }

  void setClanDetails(String clanListFromDB, ) {
    List<String> clanList = clanListFromDB.split(";");
    this.clanNameList = clanList;
  }

  void getClanPhotos(String clanID ) {
    //Download list of photo URLs from database

  }


}

class ClanData {
  
  String clanID;
  String clanPassword;
  String clanCreator;
  String clanCreatorName;
  String clanCreatorPhotoUrl;
  String imageCollectionID;
  List<Map<String, String>> imageDataList;

  Map<String, String> imageListMap;
  Map<String, File> imageFileMap;
  
  ClanData({this.clanID, this.clanPassword});
}