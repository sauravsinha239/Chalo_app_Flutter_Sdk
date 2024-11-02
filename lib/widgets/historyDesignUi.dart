
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../model/tripHistoryModel.dart';

class HistoryDesignUi extends StatefulWidget{

  TripHistoryModel? tripsHistoryModel;
  HistoryDesignUi({super.key, this.tripsHistoryModel});


  @override
  State<HistoryDesignUi> createState() => _HistoryDesignUiState();
}

class _HistoryDesignUiState extends State<HistoryDesignUi> {
  String formatDataTime(String dataTimeFormDB){
    DateTime dateTime = DateTime.parse(dataTimeFormDB);
    String formattedDataTime = "${DateFormat.MMMd().format(dateTime)} ${DateFormat.y().format(dateTime)}, ${DateFormat.jm().format(dateTime)}";
    return formattedDataTime;
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDataTime(widget.tripsHistoryModel!.time!),
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold) ,
        ),
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            color: darkTheme ? Colors.pink[900]:Colors.purple[400],
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(

                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: darkTheme? Colors.black:Colors.blue[400],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.person, color: Colors.white,),
                      ),

                      const SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.tripsHistoryModel!.driverName!,
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold,color: Colors.white),
                          ),

                          const SizedBox(height: 8,),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange,),

                              const SizedBox(height: 5,),
                              Text(widget.tripsHistoryModel?.ratings ?? "0.0",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Final Cost",
                        style: GoogleFonts.lato(color:Colors.white),
                      ),

                      const SizedBox(height: 8,),

                      Text(widget.tripsHistoryModel!.fareAmount!,
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold,color:Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("status",
                        style: GoogleFonts.lato(color:Colors.white),
                      ),

                      const SizedBox(height: 8,),


                      Text(widget.tripsHistoryModel!.status!,
                        style: GoogleFonts.lato(color:Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12,),
              Row(
                children: [
                  Text("TRIP", style: GoogleFonts.lato(fontSize: 18 ,fontWeight: FontWeight.bold,
                    color:  Colors.white,
                  ),

                  ),
                ],
              ),
              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Icon(Icons.location_on_rounded,color: Colors.red, ),

                      ),
                      SizedBox(width: 15,),

                      Text("${widget.tripsHistoryModel?.originAddress!.substring(0,40)}.." ?? "Retry", style: GoogleFonts.lato(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.white),
                      ),



                    ],
                  ),

                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Icon(Icons.flag_circle, color: Colors.green, ),

                      ),
                      SizedBox(width: 15,),

                      Text("${widget.tripsHistoryModel?.destinationAddress!.substring(0,min(40, widget.tripsHistoryModel!.destinationAddress!.length))}..." ?? "Retry", style: GoogleFonts.lato(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ],
                  ),

                ],
              ),


            ],
          ),




        )
      ],
    );
  }
}