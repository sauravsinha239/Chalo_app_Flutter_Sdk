import 'package:cab/model/activeNearbyAvailableDriver.dart';

class GeoFireAssistants{
  static List<ActiveNearByAvailableDriver> activeNearByAvailableDriverList=[];
  static void deleteOffLineDriverFromList(String driverID){
    int indexNumber = activeNearByAvailableDriverList.indexWhere((element)=> element.driverId == driverID);
    if (indexNumber != -1) {
      activeNearByAvailableDriverList.removeAt(indexNumber);
      print("Driver with ID $driverID removed successfully.");
    } else {
      print("Error: Driver with ID $driverID not found in the list.");
    }

  }
  static void updateActiveNearByAvailableDriverLocation(ActiveNearByAvailableDriver driverWhoMove){
    int indexNumber =activeNearByAvailableDriverList.indexWhere((element)=> element.driverId==driverWhoMove.driverId);
    if (indexNumber != -1) {
      activeNearByAvailableDriverList[indexNumber].locationLatitude = driverWhoMove.locationLatitude;
      activeNearByAvailableDriverList[indexNumber].locationLongitude = driverWhoMove.locationLongitude;
      print("Driver with ID ${driverWhoMove.driverId} updated successfully.");
    } else {
      print("Error: Driver with ID ${driverWhoMove.driverId} not found in the list.");
    }
  }

}