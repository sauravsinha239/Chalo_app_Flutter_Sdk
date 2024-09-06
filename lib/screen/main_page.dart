
import 'dart:async';
import 'dart:core';
import 'dart:developer';
import 'package:cab/global/global.dart';
import 'package:cab/global/map_key.dart';
import 'package:cab/infoHandler/app_info.dart';
import 'package:cab/screen/search_place_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../Assistants/assistant.dart';
import '../model/directions.dart';
import '../model/user_model.dart';


class main_page extends StatefulWidget {
  const main_page({super.key});

  @override
  State<main_page> createState() => _mainState();
}

class _mainState extends State<main_page> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? address;

  final Completer<GoogleMapController> _controllerGoogleMap =Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
  );
   GlobalKey<ScaffoldState> _scaffoldState =GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight =220;
  double waitResponseFromDriverContainerHeight=0;
  double assignedDriverInfoContainerHeight=0;
  Position? userCurrentPosition;
  var geoLocation =Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap=0;
  List<LatLng> pLineCoordinatedList=[];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet ={};

  String userName ="";
  String userEmail="";
  bool openNavigationDrawer =true;
  bool activeNearDriverKeysLoaded =false;
  BitmapDescriptor? activeNearbyIcon;
  //location
  locateUserPosition() async{
    Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition= cPosition;
    LatLng latlngPosition =LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
    CameraPosition cameraPosition =CameraPosition(target:latlngPosition,zoom: 15 );

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //ReverseGeoCode
    String humanReadableAddress = await Assistants.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("This is our Address = $humanReadableAddress");
    userName = UserModelCurrentInfo!.name!;
    userEmail= UserModelCurrentInfo!.email!;
   // initializeGeoFireListner();
   // Assistants.readCurrentOnlineUserInfo(context);

  }
  getAddressFromLatLng() async{
    try{
      GeoData data =await Geocoder2.getDataFromCoordinates(

      
          latitude: pickLocation!.latitude,
          longitude:pickLocation!.longitude,
          googleMapApiKey: goMapKey

      );

        setState(() {
          //address=data.address;
          Directions userPickUpAddress = Directions();
           userPickUpAddress.locationLatitude=pickLocation!.latitude;
           userPickUpAddress.locationLongitude=pickLocation!.longitude;
           userPickUpAddress.locationName=data.address;
           Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

          //log("Address"+data.address);
        });

    }catch(e){
      address = 'Error: $e';
    }
  }
  void CheckIfLocationPermissionAllowed() async{

    _locationPermission= await Geolocator.requestPermission();

    if(_locationPermission==LocationPermission.denied){
      _locationPermission=await Geolocator.requestPermission();
    }
  }
@override
  void initState() {

    super.initState();
    CheckIfLocationPermissionAllowed();
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(

          children: [

            GoogleMap(
              mapType: MapType .normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markerSet,
              circles: circleSet,

              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController =controller;
                setState(() {

                });
                locateUserPosition();

              },
              onCameraMove: (CameraPosition? position){
                if(pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },

              onCameraIdle: ()
              {
                getAddressFromLatLng();
              },

            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset("images/pick.png",height: 35, width: 35,),


              ),
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
                              color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: darkTheme ? Colors.yellowAccent :Colors.orange
                                        ,),


                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From",
                                            style: TextStyle(
                                              color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text( Provider.of<AppInfo> (context).userPickUpLocation !=null
                                              ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24)}..."
                                              : "Not Getting Address",
                                          style: TextStyle(
                                            color: Colors.grey, fontSize: 12,
                                          ),),
                                        ],
                                      )
                                    ],
                                  ),

                                ),
                                SizedBox(height: 5,),
                                Divider(
                                  height: 1,
                                    thickness: 2,
                                  color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                    padding:EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap:() async{
                                      //go to search place
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlaceScreen()));
                                      if(responseFromSearchScreen== "obtained Drop off"){
                                        openNavigationDrawer=false;
                                      }

                                    },
                                    child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, color: darkTheme ? Colors.yellowAccent :Colors.orange
                                            ,),


                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("To",
                                                style: TextStyle(
                                                  color: darkTheme ? Colors.yellowAccent : Colors.orange,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text( Provider.of<AppInfo> (context).userDropOffLocation!=null
                                                  ? "${(Provider.of<AppInfo>(context).userDropOffLocation!.locationName!).substring(0, 24)}..."
                                                  : "Where to?",
                                                style: TextStyle(
                                                  color: Colors.grey, fontSize: 12,
                                                ),),


                                            ],
                                          )

                                        ],

                                    ),
                                  ),
                                )

                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
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
           //  )
          ],
        ),

      ),

    );
  }
}
