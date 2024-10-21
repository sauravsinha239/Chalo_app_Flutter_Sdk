import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{

  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? vehicleDetails;
  String? driverName;
  String? ratings;

  TripHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.vehicleDetails,
    this.driverName,
    this.ratings,
  });
  TripHistoryModel.formSnapshot(DataSnapshot dataSnapShot){
    time =(dataSnapShot.value as Map)["time"];
    originAddress =(dataSnapShot.value as Map)["originAddress"];
    destinationAddress =(dataSnapShot.value as Map)["destinationAddress"];
    status=(dataSnapShot.value as Map)["status"];
    fareAmount=(dataSnapShot.value as Map)["fareAmount"];
    vehicleDetails =(dataSnapShot.value as Map)["vehicleDetails"];
    driverName=(dataSnapShot.value as Map)["driverName"];
    ratings=(dataSnapShot.value as Map)["ratings"];

  }
}