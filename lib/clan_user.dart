import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
class ClanUserProfile {
  
  FirebaseUser firebaseUser;
  
  String displayName;
  String emailAddress;
  String displayPhotoURL;
  File displayPhoto;

  bool fbLogin;
  bool googleLogin;
  
  List<String> clanNameList;
  List<ClanData> clanDataList;

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
  
  String clanName;
  String clanPassword;

  Map<String, String> imageListMap;
  Map<String, File> imageFileMap;
  
  ClanData({this.clanName, this.clanPassword});
}