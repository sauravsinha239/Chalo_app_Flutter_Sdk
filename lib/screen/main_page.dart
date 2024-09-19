import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:cab/global/global.dart';
import 'package:cab/global/map_key.dart';
import 'package:cab/infoHandler/app_info.dart';
import 'package:cab/screen/pickup_location.dart';
import 'package:cab/screen/precise_pickup_location.dart';
import 'package:cab/screen/search_place_screen.dart';
import 'package:cab/widgets/Progress_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../Assistants/assistant.dart';
import '../firebase_options.dart';
import '../model/directions.dart';
import '../model/user_model.dart';
import 'drawer_screen.dart';

class main_page extends StatefulWidget {
  const main_page({super.key});

  @override
  State<main_page> createState() => _mainState();
}

class _mainState extends State<main_page> {
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

  //location
  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latlngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //ReverseGeoCode
    String humanReadableAddress =
        await Assistants.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    // print("This is our Address = $humanReadableAddress");
    userName = UserModelCurrentInfo?.name ?? "Unknown";
    userEmail = UserModelCurrentInfo?.email ?? "Unknown";
    // initializeGeoFireListner();
    // Assistants.readCurrentOnlineUserInfo(context);
  }

  Future<void> darwPolylineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);

    var destinationLatlng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please Wait...",
      ),
    );
    var directionDetailsinfo = await Assistants.obtainOriginToDestinationDirectionDetails(originLatng, destinationLatlng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsinfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsinfo!.encodePoints!);
    pLineCoordinatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.green : Colors.red,
        polylineId: PolylineId("PolyLineId"),
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
    if (originLatng.latitude > destinationLatlng.latitude &&
        originLatng.longitude > destinationLatlng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatlng, northeast: originLatng);
    } else if (originLatng.longitude > destinationLatlng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatng.latitude, destinationLatlng.longitude),
        northeast: LatLng(destinationLatlng.latitude, originLatng.longitude),
      );
    } else if (originLatng.latitude > destinationLatlng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatlng.latitude, originLatng.longitude),
          northeast: LatLng(originLatng.latitude, destinationLatlng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatng, northeast: destinationLatlng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    //Marker Set
    Marker originaMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "origin"),
      position: originLatng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.yellow,
      radius: 18,
      strokeWidth: 5,
      strokeColor: Colors.green,
      center: originLatng,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 18,
      strokeWidth: 5,
      strokeColor: Colors.red,
      center: destinationLatlng,
    );

    setState(() {
      markerSet.add(originaMarker);
      markerSet.add(destinationMarker);
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
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

  void CheckIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
 initState()  {
    super.initState();
    CheckIfLocationPermissionAllowed();

  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () async{
        FocusScope.of(context).unfocus();

      },
      child: Scaffold(
        key: _scaffoldState ,
        drawer:  drawerScreen(),
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
              //cloudMapId: mapId,
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
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
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
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async{
                                          var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (cd) => PickupLocation()));
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
                                            "From",
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
                                                ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.substring(0, min(40, Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.length)) + ".."
                                                : "Not Getting Address",
                                            overflow:TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
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
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      //go to search place
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlaceScreen()));
                                      if (responseFromSearchScreen == "obtained Drop off") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      //polyline
                                      await darwPolylineFromOriginToDestination(darkTheme);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.yellowAccent
                                              : Colors.orange,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "To",
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
                                              style: TextStyle(
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
                          SizedBox(
                            height: 5,
                          ),
                          //search palace or start points
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => PickupLocation()));
                                },
                                child: Text(
                                  "Change Pick Up Point",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.purple
                                        : Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        darkTheme ? Colors.yellow : Colors.red,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              //request ride button
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(
                                  "Request a ride..",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.purple
                                        : Colors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        darkTheme ? Colors.yellow : Colors.red,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
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
