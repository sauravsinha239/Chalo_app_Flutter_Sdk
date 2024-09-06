import 'package:cab/model/directions.dart';
import 'package:flutter/cupertino.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips =  0;
  //List<String> historyTripsKeyList = [];
 // List<TripsHistoryModel> allTripsHistoryInformationList = [];

void updatePickUpLocationAddress(Directions userPickUpAddress){
  userPickUpLocation = userPickUpAddress;
  notifyListeners();

}
void updateDropOffLocationAddress(Directions dropOffAddress){

  userPickUpLocation = dropOffAddress;
  notifyListeners();
}


}

