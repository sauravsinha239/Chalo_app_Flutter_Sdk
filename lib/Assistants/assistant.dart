
import 'dart:developer';

import 'package:cab/Assistants/request_assistant.dart';
import 'package:cab/global/global.dart';
import 'package:cab/model/directions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../model/direction_details_info.dart';
import '../model/user_model.dart';

class Assistants{
static void readCurrentOnlineUserInfo()async{
  currentuser = firebaseAuth.currentUser;

  if (currentuser != null) {

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentuser!.uid);

    try {
      // Fetch the user data from the database
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;

      // Check if the data exists
      if (snapshot.value != null) {
        // Parse the snapshot into UserModel
        UserModelCurrentInfo = UserModel.fromSnapshot(snapshot);
        log("User Info Loaded: ${UserModelCurrentInfo!.name}");
      } else {
        log("No user data found.");
      }
    } catch (error) {
      log("Error fetching user data: $error");
    }
  } else {
    log("No user is currently logged in.");
  }

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
static Future <DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{

  // log("Origin position  is = $originPosition");
  // log("Destination Position is =  $destinationPosition");


  String urlObtainOriginToDestinationDirectionDetails = "https://maps.gomaps.pro/maps/api/directions/json?destination=${destinationPosition.latitude},${destinationPosition.longitude}&origin=${originPosition.latitude},${originPosition.longitude}&key=$goMapKey";
  var responseDirectionApi= await RequestAssistant.receiveRequest(urlObtainOriginToDestinationDirectionDetails);
  print("Response Status is   = $responseDirectionApi");
  log("Check connection of direction Status is = $responseDirectionApi");
  if(responseDirectionApi=="Error Occured Failed \. No Response"){
    // log("Check connection of direction in if cond  $responseDirectionApi");
   // return null;
  }
  DirectionDetailsInfo drirectionDetailsInfo =DirectionDetailsInfo();
  
  drirectionDetailsInfo.encodePoints= responseDirectionApi["routes"][0]["overview_polyline"]["points"];

  drirectionDetailsInfo.distanceText= responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
  drirectionDetailsInfo.distanceValue= responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
  drirectionDetailsInfo.durationText= responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
  drirectionDetailsInfo.durationValue= responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
  return drirectionDetailsInfo;

}
}