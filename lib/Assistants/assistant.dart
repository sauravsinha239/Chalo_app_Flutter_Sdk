

import 'package:cab/Assistants/request_assistent.dart';
import 'package:cab/global/global.dart';
import 'package:cab/model/directions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import '../global/map_key.dart';
import '../model/user_model.dart';

class Assistants{
static void readCurrentOnlineUserInfo()async{
  currentuser =firebaseAuth.currentUser;
  DatabaseReference userRef = FirebaseDatabase.instance
  .ref()
  .child("users")
  .child(currentuser!.uid);
  userRef.once().then((snap){
    if(snap.snapshot.value!=null){
      UserModelCurrentInfo =UserModel.fromSnapshot(snap.snapshot);
    }
  });
}
static Future<String> searchAddressForGeographicCoordinates(Position position, context)async{
  String apiUrl="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  String humanReadableAddress="";
  var requestResponse=await RequestAssistant.receiveRequest(apiUrl);
  if(requestResponse != "error Occured : Failed. no Response"){
    humanReadableAddress =requestResponse["result"][0]["fomatted address"];
    Directions userPickAddress =Directions();
    userPickAddress.locationLatitude=position.latitude;
    userPickAddress.locationLongitude=position.longitude;
    userPickAddress.locationName=humanReadableAddress;


  }
  return humanReadableAddress;

}
}