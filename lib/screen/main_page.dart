import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:cab/screen/rateDriverScreen.dart';
import 'package:cab/splash_screen/splash.dart';
import 'package:cab/widgets/payFareAmountDialog.dart';
import 'dart:ui' as ui;
import 'package:cab/Assistants/geoFireAssistants.dart';
import 'package:cab/global/global.dart';
import 'package:cab/infoHandler/app_info.dart';
import 'package:cab/model/activeNearbyAvailableDriver.dart';
import 'package:cab/screen/pickup_location.dart';
import 'package:cab/screen/search_place_screen.dart';
import 'package:cab/widgets/Progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Assistants/assistant.dart';
import '../Assistants/serverToken.dart';
import 'drawer_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
final  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRidesContainerHeight=0;
  Position? userCurrentPosition;
  var geoLocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  List<LatLng> pLineCoordinatedList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";
  bool openNavigationDrawer = true;
  bool activeNearDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  String selectedVehicleType="";
  DatabaseReference ? referenceRideRequest;
  String driverRideStatus= "Driver is Coming";
  String  userRideRequestStatus= "";
  StreamSubscription<DatabaseEvent>? tripsRidesRequestInfoStreamSubscription;
  bool requestPositionInfo=true;
  double searchingForDriverContainerHeight = 0;

List<ActiveNearByAvailableDriver>onlineNearByAvailableDriverList = [];

  //locate user current position
  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //ReverseGeoCode
    String humanReadableAddress =
        await Assistants.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    // print("This is our Address = $humanReadableAddress");
    userName = userModelCurrentInfo?.name ?? "Unknown";
    userEmail = userModelCurrentInfo?.email ?? "Unknown";
     initializeGeoFireListener();
     //
     Assistants.readTripKeysForOnlineUser(context);
  }
  initializeGeoFireListener(){
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
    .listen((map){
      print(map);
      if(map!= null){
        var callBack = map["callBack"];
        switch(callBack){
          //whenever any driver online or offline
          case Geofire.onKeyEntered:

            ActiveNearByAvailableDriver activeNearByAvailableDriver = ActiveNearByAvailableDriver();
             //print("Driver entered: ${map["key"]}, lat: ${map["Latitude"]}, lng: ${map["Longitude"]}");
            activeNearByAvailableDriver.locationLatitude=map["Latitude"];
            activeNearByAvailableDriver.locationLongitude=map["Longitude"];
            activeNearByAvailableDriver.driverId=map["key"];
            GeoFireAssistants.activeNearByAvailableDriverList.add(activeNearByAvailableDriver);
            if(activeNearDriverKeysLoaded == true){
              displayActiveDriverOnUserMap();
            }
            break;
            //Whenever any driver become non-active/online
          case Geofire.onKeyExited:

            GeoFireAssistants.deleteOffLineDriverFromList(map["key"]);
            print("Driver exited: ${map["key"]}");
            displayActiveDriverOnUserMap();
            break;
            //Whenever Driver moves  -update driver location

          case Geofire.onKeyMoved:

            ActiveNearByAvailableDriver activeNearByAvailableDriver = ActiveNearByAvailableDriver();
             print("Driver moved: ${map["key"]}, new lat: ${map["Latitude"]}, new lng: ${map["Longitude"]}");
            activeNearByAvailableDriver.locationLatitude=map["Latitude"];
            activeNearByAvailableDriver.locationLongitude=map["Longitude"];
            activeNearByAvailableDriver.driverId=map["key"];
            GeoFireAssistants.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDriver);
            displayActiveDriverOnUserMap();
            break;
            //Display those online active driver on user's map
          case Geofire.onGeoQueryReady:
            activeNearDriverKeysLoaded=true;
             print("All initial drivers loaded.");
            displayActiveDriverOnUserMap();
            break;
          default:
            print("Unknown callback received: $callBack");
        }
      }
      setState(() {
        displayActiveDriverOnUserMap();
      });
    });
  }

  displayActiveDriverOnUserMap(){
    setState(() {
      markerSet.clear();
      circleSet.clear();
      Set<Marker> driversMarkerSet = <Marker>{};
      for(ActiveNearByAvailableDriver echoDriver in GeoFireAssistants.activeNearByAvailableDriverList){
        LatLng echoDriverActivePosition =LatLng(echoDriver.locationLatitude?? 0.0, echoDriver.locationLongitude?? 0.0);
        Marker marker =Marker(
            markerId: MarkerId(echoDriver.driverId!),
        position: echoDriverActivePosition,
        icon: activeNearbyIcon!,
        rotation: 360,
        );
        driversMarkerSet.add(marker);
      }
      setState(() {
        markerSet=driversMarkerSet;
      });
    });
  }
  Future<Uint8List> getBytesFromAsset(String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);  // Load the image from assets
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);  // Resize the image
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();  // Convert to Uint8List
  }
  Future<void> createActiveNearByIconMarker() async {
    if (activeNearbyIcon == null) {
      final Uint8List markerIcon = await getBytesFromAsset('images/car.png', 250,250); // Adjust size if necessary
      activeNearbyIcon = BitmapDescriptor.bytes(markerIcon); // Create marker from the image bytes
      print("Car icon loaded successfully.");
    }
  }
  
  Future<void> drawPolylineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);

    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please Wait...",
      ),
    );
    var directionDetailedInfo = await Assistants.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailedInfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailedInfo.encodePoints!);
    pLineCoordinatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodePolyLinePointsResultList) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.green : Colors.red,
        polylineId: const PolylineId("PolyLineId"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polyLineSet.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    //Marker Set
    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.yellow,
      radius: 18,
      strokeWidth: 5,
      strokeColor: Colors.green,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 18,
      strokeWidth: 5,
      strokeColor: Colors.red,
      center: destinationLatLng,
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }
  void showSuggestedRideContainer(){
    setState(() {
      suggestedRidesContainerHeight=400;
      bottomPaddingOfMap=400;
    });
  }
  saveRideRequestInformation(String selectedVehicleType){
    //1. save ride request information
    referenceRideRequest =FirebaseDatabase.instance.ref().child("All Ride Requests").push();
    var originLocation = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;
    Map originLocationMap  ={
      //"key : "value"
      "Latitude": originLocation!.locationLatitude.toString(),
      "Longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationMap ={
      "Latitude": destinationLocation!.locationLatitude.toString(),
      "Longitude": destinationLocation.locationLongitude.toString(),
    };
    Map userInformationMap ={
      "origin":originLocationMap,
      "destination":destinationMap,
      "time":DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverID": "waiting",
    };
    referenceRideRequest!.set(userInformationMap);

    tripsRidesRequestInfoStreamSubscription =referenceRideRequest!.onValue.listen((eventSnap)async{
      if(eventSnap.snapshot.value==null){
        return;
      }
      if((eventSnap.snapshot.value as Map)["VehicleDetails"]!=null){
        setState(() {
          driverVehicleDetails = (eventSnap.snapshot.value as Map)["VehicleDetails"].toString();

        });
      }
      if((eventSnap.snapshot.value as Map)["driverName"]!=null){
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();

        });

      }
      if((eventSnap.snapshot.value as Map)["ratings"]!=null){
        setState(() {
          driverRatings = (eventSnap.snapshot.value as Map)["ratings"].toString();

        });

      }
      if((eventSnap.snapshot.value as Map)["driverPhone"]!=null){
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();

        });
      }
      if((eventSnap.snapshot.value as Map)["status"]!=null){
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();

        });
      }
      if((eventSnap.snapshot.value as Map)["driverLocation"]!= null){
      double driverCurrentPositionLat= double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["Latitude"].toString());
      double driverCurrentPositionLng= double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["Longitude"].toString());
      LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
      // status = accepted
        if(userRideRequestStatus == "accepted"){
          updateArrivalTimeToUserPickupLocation( driverCurrentPositionLatLng);
        }

        //status = arrived
        if(userRideRequestStatus =="arrived"){
          setState(() {
            driverRideStatus ="Driver has arrived";

          });
        }
        //status == ontrip
        if(userRideRequestStatus== "onTrip"){

          updateReachingTimeUserDropOffLocation(driverCurrentPositionLatLng);
        }

      if (userRideRequestStatus == "ended") {
        if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
          // Parse the fare amount
          double fareAmount = double.parse(
            (eventSnap.snapshot.value as Map)["fareAmount"].toString(),
          );

          // Show the payment dialog and await the response
          var response = await showDialog(
            context: context,
            builder: (BuildContext context) => PayFareAmountDialog(
              fareamount: fareAmount,
            ),
          );

          // Check the user's response from the payment dialog
          if (response == "Cash Paid") {
            // Allow the user to rate the driver now if the driverID is present
            if ((eventSnap.snapshot.value as Map)["driverID"] != null) {
              String assignDriverId = (eventSnap.snapshot.value as Map)["driverID"].toString();
              // Navigate to the RateDriverScreen for rating the driver
              Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen(
                    assignDriverId: assignDriverId,),),);

              referenceRideRequest!.onDisconnect();
              tripsRidesRequestInfoStreamSubscription!.cancel();

            } else {
              print("Error: driverID is missing in event snapshot.");
            }
          } else {
            print("Payment was not confirmed.");
          }
        } else {
          print("Error: fareAmount is missing in event snapshot.");
        }
      }

      }

    });
    onlineNearByAvailableDriverList =GeoFireAssistants.activeNearByAvailableDriverList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }
  void showSearchingForDriverContainer(){
    setState(() {
      searchingForDriverContainerHeight= 200;
    });
  }

  // getAddressFromLatLng() async {
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickLocation!.latitude,
  //         longitude: pickLocation!.longitude,
  //         googleMapApiKey: goMapKey);
  //
  //     setState(() {
  //       //address=data.address;
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationLatitude = pickLocation!.latitude;
  //       userPickUpAddress.locationLongitude = pickLocation!.longitude;
  //       userPickUpAddress.locationName = data.address;
  //       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //       //log("Address"+data.address);
  //     });
  //   } catch (e) {
  //     address = 'Error: $e';
  //   }
  // }

  void checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  updateArrivalTimeToUserPickupLocation( driverCurrentPositionLatLng)async{
    if(requestPositionInfo == true){
      requestPositionInfo =false;
      LatLng userPickUpPosition =LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo= await Assistants.obtainOriginToDestinationDirectionDetails(driverCurrentPositionLatLng,userPickUpPosition);
      setState(() {
        driverRideStatus = "Driver is Coming: ${directionDetailsInfo.distanceText.toString()}";
      });
      requestPositionInfo= true;
    }
  }
  updateReachingTimeUserDropOffLocation(driverCurrentPositionLatLng)async{

    if(requestPositionInfo == true){
      requestPositionInfo=false;

      var dropOffLocation = Provider.of<AppInfo>(context,listen:false).userDropOffLocation;
      LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);
      var directionDetailsInfo = await Assistants.obtainOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userDestinationPosition);
      setState(() {
        driverRideStatus = "Going Towards Destination: ${directionDetailsInfo.durationText.toString()}";

      });
      requestPositionInfo = true;
    }
  }
  searchNearestOnlineDrivers(String selectedVehicleType)  async{
    if(onlineNearByAvailableDriverList.isEmpty){
      //cancel / delete the ride request information
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatedList.clear();
      });showSearchingForDriverContainer();
      Fluttertoast.showToast(msg: "No online Nearest Driver Available");
      Fluttertoast.showToast(msg: "Search again. \n Restarting App");
      Future.delayed(const Duration(microseconds: 4000),(){

        referenceRideRequest!.remove();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const Splash()));

      });
      return;
    }
    await retrieveOnlineDriverInformation(onlineNearByAvailableDriverList);

    for(int i =0; i<driversInfo.length; i++){
      var driverInfo = driversInfo[i];
      if(driversInfo[i]["vehicleDetails"]["vehicleType"]==selectedVehicleType){

        Assistants.sendNotificationToDriverNow(driversInfo[i]["token"],referenceRideRequest!.key!, context);

      }
      else {
        print("Driver vehicle type does not match: ${driverInfo["vehicleDetails"]["vehicleType"]}");
      }
    }

    Fluttertoast.showToast(msg: "Notification sent Successfully");
    showSearchingForDriverContainer();
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(referenceRideRequest!.key!)
        .child("driverID")
        .onValue
        .listen((eventRideRequestSnapshot) {
      var driverId = eventRideRequestSnapshot.snapshot.value;

      if (driverId != null && driverId != "waiting") {
        print("Driver assigned: $driverId");
        showUIForAssignedDriverInfo();
      }
    });

  }
  //list
  Future<void> retrieveOnlineDriverInformation( List onlineNearestDriverList) async{
    driversInfo.clear();
    
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    
    for(int i = 0; i< onlineNearestDriverList.length; i++){
      
      await ref.child(onlineNearestDriverList[i].driverId.toString()).once().then((dataSnapshot){
        
        var driverKeyInfo= dataSnapshot.snapshot.value;
        
        if(driverKeyInfo != null) {
          
          driversInfo.add(driverKeyInfo);
          
          print("driver key information =  ${driversInfo.toString()}");
        }
      });
    }
  }

  showUIForAssignedDriverInfo(){
    setState(() {
      waitResponseFromDriverContainerHeight=0;
      searchLocationContainerHeight=0;
      assignedDriverInfoContainerHeight=250;
      suggestedRidesContainerHeight=0;
      bottomPaddingOfMap =200;
    });
  }
  //Make phone calll
  Future<void> _makePhoneCall(String Url)async{

    if(await canLaunch(Url )){
      await launch(Url);
    }
    else{
      throw "Could Not launch $Url";
    }
  }

  @override
 initState()  {
    super.initState();
    checkIfLocationPermissionAllowed();
  }
  
  @override
  Widget build(BuildContext context) {
    createActiveNearByIconMarker();
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () async{
        FocusScope.of(context).unfocus();

      },
      child: Scaffold(
        key: _scaffoldState ,
        drawer:  const DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 100, bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: true,
              buildingsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  bottomPaddingOfMap = 250;
                });
                locateUserPosition();
              },
              // onCameraMove: (CameraPosition? position) {
              //   if (pickLocation != position!.target) {
              //     setState(() {
              //       pickLocation = position.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   getAddressFromLatLng();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35.0),
            //     child: Image.asset(
            //       "images/pick.png",
            //       height: 35,
            //       width: 35,
            //     ),
            //   ),
            // ),
            //Coustom hamburger button for drawer
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: darkTheme ? Colors.black :Colors.white,
                    child: Icon(
                      Icons.menu_outlined,
                      color: darkTheme ? Colors.orangeAccent :Colors.purple,
                    ),
                  ),
                ),
              ) ,
            ),
            //Ui for Searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),

                             child:  Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async{
                                          var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (cd) => const PickupLocation()));
                                          if (responseFromSearchScreen =="obtained Pick up") {
                                            setState(() {
                                              openNavigationDrawer=false;
                                            });
                                          }
                                        },
                                      child :Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "From...",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.yellowAccent
                                                  : Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context).userPickUpLocation != null
                                                ? "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.substring(0, min(40, Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.length))}.."
                                                : "Not Getting Address",
                                            overflow:TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                      ),
                                  ],
                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                ),
                                const SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      //go to search place
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchPlaceScreen()));
                                      if (responseFromSearchScreen == "obtained Drop off") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      //polyline
                                      await drawPolylineFromOriginToDestination(darkTheme);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.yellowAccent : Colors.orange,
                                        ),
                                        const SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "To....",
                                              style: TextStyle(
                                                color: darkTheme
                                                    ? Colors.yellowAccent
                                                    : Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context).userDropOffLocation != null ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                                  : "Where to?",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),
                          //search palace or start points
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => const PickupLocation()));
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        darkTheme ? Colors.yellow : Colors.red,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                child: Text(
                                  "Change Pick Up Address",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.purple
                                        : Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),

                              //request ride button
                              ElevatedButton(
                                onPressed: () async{
                                  GetServerKeyToken getServerKey = GetServerKeyToken();
                                  serverToken= await getServerKey.getServerKey();
                                  print("Server key is Generated =>> $serverToken");
                                  if(Provider.of<AppInfo>( context, listen: false).userDropOffLocation != null){
                                    showSuggestedRideContainer();
                                  }
                                  else{
                                    Fluttertoast.showToast(msg: "Please Set Destination Location");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        darkTheme ? Colors.yellow : Colors.red,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                child: Text(
                                  "Show Fare",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.purple
                                        : Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

          //ui for suggested rides
            Positioned(
              left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestedRidesContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(

                              padding:const EdgeInsets.all(2),
                              decoration:BoxDecoration(
                                color: darkTheme ? Colors.yellow : Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(
                                Icons.star, color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 15,),
                            Text(

                              Provider.of<AppInfo>(context).userPickUpLocation != null
                                  ? "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.substring(0, min(34, Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.length))}.."
                                  : "Not Getting Address",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            Container(

                              padding:const EdgeInsets.all(2),
                              decoration:BoxDecoration(
                                color: darkTheme ? Colors.yellow : Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(
                                Icons.star, color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 15,),
                            Text(

                              Provider.of<AppInfo>(context).userDropOffLocation != null
                                  ? "${Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.substring(0, min(34, Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.length))}.."
                                  : "Not Getting Address",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        const Text(
                          "Suggested Rides",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedVehicleType = "car";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "car" ? (darkTheme ? Colors.blueGrey : Colors.black45): (darkTheme ?Colors.white38 : Colors.black26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Column(
                                    children: [
                                      Image.asset("images/car.png", scale: 4, height: 50, width:60,),
                                      const SizedBox(height: 8,),
                                      Text("Car", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "car" ?  (darkTheme ? Colors.black : Colors.white):(darkTheme ? Colors.black38 : Colors.black45),
                                      ),
                                      ),
                                      const SizedBox(height: 2,),

                                      Text(
                                      tripDirectionDetailsInfo!=null ? "₹ ${(Assistants.calculateFareAmount(tripDirectionDetailsInfo!)* 2).toStringAsFixed(1)}"
                                      : "null",
                                      style: const TextStyle(
                                        fontWeight:  FontWeight.bold,
                                        color: Colors.grey,

                                      ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //cng
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedVehicleType = "cng";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "cng" ? (darkTheme ? Colors.blueGrey : Colors.black45): (darkTheme ?Colors.white38 : Colors.black26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Column(
                                    children: [
                                      Image.asset("images/cng.png", scale: 4, height: 50, width:60,),
                                      const SizedBox(height: 8,),
                                      Text("Cng", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "cng" ?  (darkTheme ? Colors.black : Colors.white):(darkTheme ? Colors.black38 : Colors.black45),
                                      ),
                                      ),
                                      const SizedBox(height: 2,),
                                      Text(
                                        tripDirectionDetailsInfo!=null ? "₹ ${(Assistants.calculateFareAmount(tripDirectionDetailsInfo!)* 1.8).toStringAsFixed(1)}"
                                            : "null",
                                        style: const TextStyle(
                                          fontWeight:  FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //bike
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedVehicleType = "bike";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "bike" ? (darkTheme ? Colors.blueGrey : Colors.black45): (darkTheme ?Colors.white38 : Colors.black26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Column(
                                    children: [
                                      Image.asset("images/bike.png", scale: 4, height: 50, width:60,),
                                      const SizedBox(height: 8,),
                                      Text("Bike", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "bike" ?  (darkTheme ? Colors.black : Colors.white):(darkTheme ? Colors.black38 : Colors.black45),
                                      ),
                                      ),
                                      const SizedBox(height: 2,),
                                      Text(
                                        tripDirectionDetailsInfo!=null ? "₹ ${(Assistants.calculateFareAmount(tripDirectionDetailsInfo!)* 1.25).toStringAsFixed(1)}"
                                            : "null",
                                        style: const TextStyle(
                                          fontWeight:  FontWeight.bold,
                                          color: Colors.grey,

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),

                        Expanded(child: GestureDetector(
                          onTap: () {
                            if(selectedVehicleType!= ""){
                              saveRideRequestInformation(selectedVehicleType);
                            }
                            else{

                              Fluttertoast.showToast(msg: "please select a vehicle for \n suggested rides.");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                            color: darkTheme ? Colors.blueGrey : Colors.purpleAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child:   Text(
                                  "Request a Ride",
                                style: TextStyle(
                                  color: darkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                            ),
                            )
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
            ),
            Positioned(
              bottom: 0,
                left: 0,
                right:0,
                child: Container(
                  height: searchingForDriverContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          color: darkTheme ? Colors.purpleAccent: Colors.blue,
                        ),
                        const SizedBox(height: 10,),
                        const Center(
                          child: Text(
                            "Searching for Driver....",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                            ),

                          )
                        ),
                        const SizedBox(height: 20,),
                        GestureDetector(
                          onTap: (){
                            referenceRideRequest!.remove();
                            setState(() {
                              searchLocationContainerHeight=0;
                              suggestedRidesContainerHeight=0;
                            });

                          },
                          child: Container(
                            height: 50,
                              width: 50,

                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(width: 1, color: Colors.grey),
                              ),
                            child: const Icon(Icons.close, size: 25,),
                          ),
                        ),
                        const SizedBox(height: 15,),
                        const SizedBox(
                          width: double.infinity,
                          child:
                          Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
            ),

            //UI for Display Assigned driver Information

            Positioned(
              bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: assignedDriverInfoContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black :Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          driverRideStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                        SizedBox(height: 5,),

                        Divider(
                          thickness: 1,
                          color: darkTheme? Colors.grey:Colors.grey[300],
                        ),
                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: darkTheme ? Colors.yellow : Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.person, color: darkTheme? Colors.black:Colors.white,),
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(driverName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkTheme
                                    ? Colors.white: Colors.black),),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: darkTheme ? Colors.green: Colors.orange,),
                                        Text(double.tryParse(driverRatings)?.toStringAsFixed(2) ?? "0.0",
                                          style: TextStyle(
                                              color: Colors.grey
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],

                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                               Image.asset("images/car.png",width: 70,height: 70,),

                                Text(driverVehicleDetails,style: TextStyle(fontSize:12),),
                              ],
                            )
                          ],
                        ),

                        SizedBox(height: 5,),
                        Divider(thickness: 1, color: darkTheme? Colors.grey: Colors.grey[300],),
                        ElevatedButton.icon(
                            onPressed: (){
                              _makePhoneCall("tel: ${driverPhone}");
                              print("Call action performed ${driverPhone}");
                            },
                          style: ElevatedButton.styleFrom(
                           backgroundColor: darkTheme ? Colors.blue[100]: Colors.blue,
                          ),
                            icon: Icon(Icons.phone),
                            label: Text("Call Driver"),
                        ),
                      ],
                    ),
                  ),
                )
            )


            // Positioned(
            //    top: 40,
            //    right: 20,
            //    left: 20,
            //    child: Container(
            //      decoration: BoxDecoration(
            //        border: Border.all(color: Colors.black),
            //        color: Colors.white,
            //      ),
            //      padding: const EdgeInsets.all(20),
            //      child: Text(
            //        Provider.of<AppInfo> (context).userPickUpLocation !=null? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 40)}...":
            //        "Not Getting Address",
            //      overflow: TextOverflow.visible, softWrap: true,
            //        style: const TextStyle(
            //          color: Colors.black,
            //          fontSize: 14,
            //        ),
            //
            //      ),
            //    ),
            //  ),
          ],
        ),
      ),
    );
  }
}
