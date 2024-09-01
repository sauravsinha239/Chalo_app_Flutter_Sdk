
import 'dart:async';
import 'dart:core';
import 'package:cab/global/map_key.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Assistants/assistants.dart';


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
  final GlobalKey<ScaffoldState> _scaffoldState =GlobalKey<ScaffoldState>();

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
    String humanReadableAddress = await Assistants.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("This is our Address = "+humanReadableAddress);
  }
  getAddressFromLatLng() async{
    try{
      GeoData data =await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude:pickLocation!.longitude,
          googleMapApiKey: mapKey
      );
      setState(() {
        _address =data.address;

      });
    }catch(e){
      print(e);
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
    // TODO: implement initState
    super.initState();
    CheckIfLocationPermissionAllowed();
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

            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset("images/pick.png",height: 45, width: 45,),


              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.black,
                ),
                padding: EdgeInsets.all(20),
                child: Text(_address ?? "Chose your pickup point ",
                overflow: TextOverflow.visible, softWrap: true,
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}
