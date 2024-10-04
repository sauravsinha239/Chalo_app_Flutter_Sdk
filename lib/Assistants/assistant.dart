
import 'dart:convert';
import 'dart:developer';
import 'package:cab/Assistants/request_assistant.dart';
import 'package:cab/global/global.dart';
import 'package:cab/model/directions.dart';
import 'package:cab/model/tripHistoryModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../model/direction_details_info.dart';
import '../model/user_model.dart';
import 'package:http/http.dart'as http;

class Assistants{
static void readCurrentOnlineUserInfo()async{
  currentUser = firebaseAuth.currentUser;

  if (currentUser != null) {

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    try {
      // Fetch the user data from the database
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;

      // Check if the data exists
      if (snapshot.value != null) {
        // Parse the snapshot into UserModel
        userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
        log("User Info Loaded: ${userModelCurrentInfo!.name}");
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
  if(responseDirectionApi=="Error Occured Failed . No Response"){
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
static double calculateFareAmount(DirectionDetailsInfo directionDetailsInfo){
  //double timeTravelledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 3.0; //  3 INR per minute
  double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.distanceValue! / 1000) * 10.0; //  15 INR per km

  double totalFareAmount =  distanceTravelledFareAmountPerKilometer;//timeTravelledFareAmountPerMinute +
  return double.parse(totalFareAmount.toStringAsFixed(1));


}
static sendNotificationToDriverNow(String deviceRegistrationToken,String userRideRequestId, context)async{
  String destinationAddress = userDropOfAddress;

  String url = 'https://fcm.googleapis.com/v1/projects/chalo-1/messages:send';

  Map<String, String> headerNotification = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $serverToken',
  };

  Map bodyNotification = {
    "body": "Destination Address:\n$destinationAddress",
    "title": "New Trip Request"
  };

  Map dataMap = {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "id": "1",
    "status": "done",
    "rideRequestId": userRideRequestId
  };

  Map officialNotificationFormat = {
    "message": {
      "token": deviceRegistrationToken,
      "notification": bodyNotification,
      "data": dataMap,
      "android": {
        "priority": "high"
      }
    }
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );


    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print("Failed to send notification. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
}
//Retrive the trip keys for online user
//trip key == ride request key

static void  readTripKeysForOnlineUser(BuildContext context){

  FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("userName").equalTo(userModelCurrentInfo!.name).once().then((snap){
    if(snap.snapshot.value!=null){
      Map keysTripId =snap.snapshot.value as Map;

      //Count total Number of trips and share it from provider

      int overAllTripCounter =keysTripId.length;
      Provider.of<AppInfo>(context ,listen: false).updateOverAllTripsCounter(overAllTripCounter);

      //Share trips Key with Provider
      List<String> tripKeyList =[];
      keysTripId.forEach((key, value){
        tripKeyList.add(key);
      });
      Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripKeyList);
      //get  trip key data -read trip Complete information
      readTripHistoryInformation(context);

    }
  });
}
  static void readTripHistoryInformation(context){

      var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeyList;

      for(String eachKey in tripsAllKeys){
        FirebaseDatabase.instance.ref()
            .child("All Ride Requests")
            .child(eachKey)
            .once()
            .then((snap){
              var eachTripHistory =TripHistoryModel.formSnapshot(snap.snapshot);

              if((snap.snapshot.value as Map)["status"] == "ended"){
                //Update or add each History to OverAllTrips Histroy data list
                Provider.of<AppInfo>(context, listen: false).updateOverAllHistoryInformation(eachTripHistory);
              }
        }).catchError((e){
          print("Error fetching trip history for key $eachKey: $e");
        });
      }
  }



}