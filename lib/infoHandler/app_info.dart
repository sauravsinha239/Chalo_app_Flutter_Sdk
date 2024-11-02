import 'package:cab/model/directions.dart';
import 'package:cab/model/tripHistoryModel.dart';
import 'package:flutter/material.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips =  0;
  List<String> historyTripsKeyList = [];
 List<TripHistoryModel> allTripsHistoryInformationList = [];

void updatePickUpLocationAddress(Directions userPickUpAddress){
  userPickUpLocation = userPickUpAddress;
  notifyListeners();

}
void updateDropOffLocationAddress(Directions userDropOffAddress){

  userDropOffLocation = userDropOffAddress;
  notifyListeners();
}

updateOverAllTripsCounter(int overAllTripsCounter){
  countTotalTrips = overAllTripsCounter;
  notifyListeners();

}
updateOverAllTripsKeys(List<String> tripsKeysList){
  historyTripsKeyList =tripsKeysList;
  notifyListeners();
}

updateOverAllHistoryInformation(TripHistoryModel eachTripHistory){
  allTripsHistoryInformationList.add(eachTripHistory);
  notifyListeners();
}

}

