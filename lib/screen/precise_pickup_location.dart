import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import '../Assistants/assistant.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../model/directions.dart';

class precisePickup_location extends StatefulWidget{
  const precisePickup_location({super.key});

  @override
  State<precisePickup_location> createState() => _precisePickup_locationState();
}

class _precisePickup_locationState extends State<precisePickup_location> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  Set<Marker> markerSet = {};

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
   double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
    await Assistants.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
  }

  getAddressFromLatLng() async {
      try {
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: pickLocation!.latitude,
            longitude: pickLocation!.longitude,
            googleMapApiKey: goMapKey);

        setState(() {
          //address=data.address;
          Directions userPickUpAddress = Directions();
          userPickUpAddress.locationLatitude = pickLocation!.latitude;
          userPickUpAddress.locationLongitude = pickLocation!.longitude;
          userPickUpAddress.locationName = data.address;
          Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
          //log("Address"+data.address);
        });
      } catch (e) {
        _address = 'Error: $e';
      }
      Marker MarkserSet = Marker(
        markerId: MarkerId("MarkerID"),

      );
    }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 100, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,

            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            //cloudMapId: mapId,
            trafficEnabled: true,
            buildingsEnabled: true,
            markers: markerSet,
            initialCameraPosition: _kGooglePlex,

            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {

                bottomPaddingOfMap=100;
              });
              locateUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position!.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatLng();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 60, bottom: bottomPaddingOfMap),
              child: Image.asset(
                "images/pick.png",
                height: 35,
                width: 35,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Text(
                Provider.of<AppInfo> (context).userPickUpLocation !=null? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 40)}...":
                "Not Getting Address",
                overflow: TextOverflow.visible, softWrap: true,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),

              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,child: Padding(
            padding: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
           style: ElevatedButton.styleFrom(
                  backgroundColor: darkTheme ? Colors.yellow : Colors.red,
                  textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                     ),
            ),
          child: Text("Set Current Location"),
          ),
          )
          ),
        ],
      ),

    );

  }

}
