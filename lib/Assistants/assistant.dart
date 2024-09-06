
import 'package:cab/Assistants/request_assistant.dart';
import 'package:cab/global/global.dart';
import 'package:cab/model/directions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
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
static Future<String> searchAddressForGeographicCoordinates(Position position, BuildContext context)async {
  String humanReadableAddress = "";
  String apiUrl = "https://maps.gomaps.pro/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$goMapKey";


  var requestResponse = await RequestAssistant.receiveRequest(apiUrl);


  if(requestResponse != "failed"  ) {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;
      // ignore: use_build_context_synchronously
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

  }


  return humanReadableAddress;

}
}