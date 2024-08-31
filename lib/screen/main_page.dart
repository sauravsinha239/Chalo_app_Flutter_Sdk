
import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:cab/Assistants/assistants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class main_page extends StatefulWidget {
  const main_page({super.key});

  @override
  State<main_page> createState() => _mainState();
}

class _mainState extends State<main_page> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

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
  locateUserPosition() async{
    Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition= cPosition;
    LatLng latlngPosition =LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
    CameraPosition cameraPosition =CameraPosition(target:latlngPosition,zoom: 15 );
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await Assistants.searchAddressForGeographicCoordinates(userCurrentPosition, context)
    {
      print("This is our Address = "+humanReadableAddress);

    }
  }







  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(

          children: [

            GoogleMap(
              mapType: MapType .normal,
              myLocationButtonEnabled: true,
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
              onCameraMove: (CameraPosition? Position){
                if(pickLocation != Position!.target) {
                  setState(() {
                    pickLocation = Position.target;
                  });
                }
              },

              onCameraIdle: ()
              {
                //getAddressFromLatLing();
              },

            )
          ],
        ),
      ),

    );
  }
}
