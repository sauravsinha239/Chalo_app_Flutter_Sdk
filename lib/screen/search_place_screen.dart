
import 'package:cab/Assistants/request_assistant.dart';
import 'package:cab/model/predicted_place.dart';

import 'package:flutter/material.dart';

import '../global/map_key.dart';
import '../widgets/place_prediction_tile.dart';

class SearchPlaceScreen extends StatefulWidget{
  const SearchPlaceScreen({super.key});

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  List< predictedPlaces > placesPredictedList = [];
  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch = "https://maps.gomaps.pro/maps/api/place/autocomplete/json?input=$inputText&key=$goMapKey&components=country:IN";
      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      //log("Response auto complete debug code$responseAutoCompleteSearch");
      if (responseAutoCompleteSearch == "Error Occurred. No Response") {
        return;
      }
      if (responseAutoCompleteSearch["status"] == "OK") {
        //log("Response auto complete debug code status =  $responseAutoCompleteSearch");
        var placePredictions = responseAutoCompleteSearch["predictions"];

        if(placePredictions != null && placePredictions is List<dynamic>){

          List<predictedPlaces> placePredictionList = placePredictions.map((jsonData) => predictedPlaces.fromJson(jsonData)).toList();
          setState(() {
            placesPredictedList = placePredictionList;
          });
        }

        else {
          print("Error: placePredictions is not a list.");
        }

      }
    }
  }




  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: (){

      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors. white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
          leading: GestureDetector(
            onTap:(){
              Navigator.pop(context);
            },
            child:Icon(Icons.arrow_back_ios_new_rounded, color: darkTheme ? Colors.white: Colors.red ,),
          ),
          title:  Text(
            "Search & Set drop off location",
            style: TextStyle(
                color: darkTheme ? Colors.white : Colors.black,
            ),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.black:Colors.white,
                boxShadow: const [
                  BoxShadow(

                    color: Colors.purple,
                    blurRadius: 2,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7
                    )
                  )
                ]
              ),

              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(

                          Icons.adjust_sharp,
                          color: darkTheme ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 18.0,),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            style: TextStyle(
                              color: darkTheme ?Colors.red:Colors.green,
                            ),
                            onChanged: (value){
                              findPlaceAutoCompleteSearch(value);

                            },
                            decoration: InputDecoration(
                              hintText: "Search Location here...",
                                hintStyle: TextStyle(color: darkTheme ? Colors.red : Colors.green),
                              fillColor: darkTheme ? Colors.black : Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding:const EdgeInsets.only(
                                left: 11,
                                top: 8,

                                bottom: 8,
                              )
                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            //display place prediction

            (placesPredictedList.isNotEmpty)
            ? Expanded(
                child: ListView.separated(
                    itemCount: placesPredictedList.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index){
                      return placePredictionTileDesign(
                          PredictedPlaces: placesPredictedList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index){
                      return Divider(
                      height: 0,
                      color: darkTheme? Colors.red: Colors.yellowAccent,
                      thickness: 0,
                      );
            },

                )
            ) :Container(

            ),
          ],
        ),
      ),

    );
  }
}