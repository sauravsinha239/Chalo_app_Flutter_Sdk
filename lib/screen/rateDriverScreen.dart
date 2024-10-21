
import 'package:cab/global/global.dart';
import 'package:cab/splash_screen/splash.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RateDriverScreen extends StatefulWidget{

  String? assignDriverId;
  RateDriverScreen({super.key, this.assignDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  Color getStarColor(double rating) {
    if (rating <= 1) {
      return Colors.redAccent; // Color for Very Bad
    } else if (rating == 2) {
      return Colors.deepOrangeAccent; // Color for Bad
    } else if (rating == 3) {
      return Colors.orange; // Color for Good
    } else if (rating == 4) {
      return Colors.lightGreen; // Color for Very Good
    } else if (rating == 5) {
      return Colors.green; // Color for Excellent
    }
    return Colors.grey; // Default color
  }
  @override
  Widget build(BuildContext context) {
    bool darkThemes = MediaQuery.of(context).platformBrightness == Brightness.dark;

   return Dialog(
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(14),
     ),
     backgroundColor: Colors.transparent,
     child: Container(
       margin: const EdgeInsets.all(8),
       width: double.infinity,
       decoration: BoxDecoration(
         color: darkThemes ? Colors.black45:Colors.white54,
         borderRadius: BorderRadius.circular(10),
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           const SizedBox(height: 22,),
           Text("Rate Trip Experience",
             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2,
             color: darkThemes ? Colors.yellow: Colors.blue),
           ),
           const SizedBox(height: 20,),

           Divider(height: 2,color: darkThemes? Colors.grey : Colors.blue,),
           const SizedBox(height: 20,),

           SmoothStarRating(
             rating: countRatingStar,
             allowHalfRating: false,
             starCount: 5,
             color: getStarColor(countRatingStar),
             borderColor: darkThemes? Colors.orange :Colors.grey,
             size: 50,
             onRatingChanged: (valueOfStarChoose){
               countRatingStar =valueOfStarChoose;
               setState(() {
                 if(countRatingStar==1){

                   setState(() {
                     titleStarRating= "Very Bad";
                   });
                 }
                 if(countRatingStar==2){
                   setState(() {
                     titleStarRating= "Bad";
                   });
                 }
                 if(countRatingStar==3){
                   setState(() {
                     titleStarRating= "Good";
                   });
                 }
                 if(countRatingStar==4){
                   setState(() {
                     titleStarRating= "Very Good";
                   });
                 }
                 if(countRatingStar==5){
                   setState(() {
                     titleStarRating= "Excellent";
                   });
                 }

               });
             },
           ),
           const SizedBox(height: 10,),
           Text(
             titleStarRating,
             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,
             color: darkThemes? Colors.blue: Colors.purple),
           ),
           const SizedBox(height: 20,),

           ElevatedButton(
               onPressed: (){
                DatabaseReference rateDriver = FirebaseDatabase.instance.ref()
                    .child("drivers")
                    .child(widget.assignDriverId!)
                    .child("ratings");
                rateDriver.once().then((snap){
                  if(snap.snapshot.value == null){
                    rateDriver.set(countRatingStar.toString());
                    Fluttertoast.showToast(msg: "Thank you for rating!.. \n restarting the app");

                    Future.delayed(const Duration(milliseconds: 2000),(){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const Splash()));
                    }) ;

                  }
                  else{
                    double pastRatings =double.parse(snap.snapshot.value.toString());
                    double newAverageRatings =(pastRatings + countRatingStar)/2;
                    rateDriver.set(newAverageRatings.toString());

                    Fluttertoast.showToast(msg: "Thank you for rating!.. \n restarting the app");
                    Future.delayed(const Duration(milliseconds: 2000),(){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const Splash()));
                    }) ;
                  }
                }).catchError((e){
                  print("error occurred  Updating Rating$e");
                });
               },
             style: ElevatedButton.styleFrom(
               backgroundColor: darkThemes? Colors.blue: Colors.purple,
             ),
               child: Text("Submit",
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: darkThemes ? Colors.black: Colors.white),
               ),
           ),
         ],
       ),
     ),
   );
  }
}
