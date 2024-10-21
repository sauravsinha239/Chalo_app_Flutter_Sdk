
import 'package:cab/Assistants/request_assistant.dart';
import 'package:cab/infoHandler/app_info.dart';
import 'package:cab/model/directions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../model/predicted_place.dart';
import 'Progress_dialog.dart';

class placePredictionTileDesign extends StatefulWidget{

final predictedPlaces PredictedPlaces;
const placePredictionTileDesign({super.key,  required this.PredictedPlaces});

  @override
  State<placePredictionTileDesign> createState() => _placePredictionTileDesignState();
}

class _placePredictionTileDesignState extends State<placePredictionTileDesign> {
  LatLng? picklocation;
  getPlaceDirextionDetails( String? placeid, context) async {
    showDialog(
        context: context,
        builder: (BuildContext)=>ProgressDialog(
          message: "setting up Drop-off. please Wait...",
        )
    );
    String PlaceDirectionDetailsUrl= "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeid&key=$goMapKey";


    var responseApi =await RequestAssistant.receiveRequest(PlaceDirectionDetailsUrl);
    Navigator.pop(context);
    if(responseApi== "Error Occurred Failed. No Response"){
      return;
    }

    if(responseApi["status"]=="OK"){
      Directions directions = Directions();
      directions.locationName=responseApi["result"]["name"];
      directions.locationId=placeid;
      directions.locationLatitude=responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude=responseApi["result"]["geometry"]["location"]["lng"];
      Provider.of<AppInfo>(context, listen:false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOfAddress= directions.locationName!;


      });
    }
    Navigator.pop(context,"obtain Drop off");

  }
  @override
  Widget build(BuildContext context) {

    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){
            getPlaceDirextionDetails(widget.PredictedPlaces.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location_alt_rounded,
                color: darkTheme ? Colors.red:Colors.green,
              ),
              const SizedBox(width: 10,),
              Expanded(
                  child: Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.PredictedPlaces.main_text ??'Unknown',
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme ? Colors.green:Colors.red,
                        ),
                      ),
                      Text(
                        widget.PredictedPlaces.secondary_text ?? 'Unknown',
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme ? Colors.yellow:Colors.green,
                        ),
                      )
                    ],
                  )
              )
            ],
          ),
        )
    );



  }
}