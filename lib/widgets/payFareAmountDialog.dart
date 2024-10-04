

import 'package:cab/splash_screen/splash.dart';
import 'package:flutter/material.dart';

class PayFareAmountDialog extends StatefulWidget{
double ? fareamount;
PayFareAmountDialog({ this.fareamount});


  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme=MediaQuery.of(context).platformBrightness == Brightness.dark;
   return Dialog(

     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(15),
     ),
     backgroundColor:  Colors.transparent,
     child: Container(
       margin: const EdgeInsets.all(0),
       width: double.infinity,
       decoration: BoxDecoration(
         color: darkTheme ? Colors.purple[900] : Colors.blue[900],
         borderRadius: BorderRadius.circular(10),
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           const SizedBox(height: 30,),
           Text("Fare Amount".toUpperCase(),
           style: TextStyle(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: darkTheme ? Colors.yellow: Colors.blue,
           ),
           ),
           const SizedBox(height: 20,),
           Divider(
             thickness: 2,color: darkTheme ? Colors.blue : Colors.red,
           ),
           const SizedBox(height: 10,),
           Text("₹${widget.fareamount}",
             style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 50,
               color: darkTheme ? Colors.green : Colors.yellow,
             ),
           ),
           const SizedBox(height: 10,),
           Padding(
               padding: const EdgeInsets.all(10),
             child: Text(
               "This is the total trip fare amount. please pay it to the driver",
               textAlign: TextAlign.center,
               style: TextStyle(
                 color: darkTheme ? Colors.blue: Colors.green,
                 fontWeight: FontWeight.bold
               ),
             ),
           ),
           const SizedBox(height: 10,),
           Padding(padding: const EdgeInsets.all(20),
           child: ElevatedButton(
             style: ElevatedButton.styleFrom(
               textStyle: TextStyle(
                 color: darkTheme? Colors.yellow : Colors.green,
               ),

             ), onPressed: () {
               Future.delayed(const Duration(microseconds: 10000),(){
                 Navigator.pop(context, "Cash Paid");
                 //Navigator.push(context, MaterialPageRoute(builder: (c)=>const Splash()));
               });
           },
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pay Cash",
                  style: TextStyle(
                    fontSize: 20,
                    color: darkTheme ? Colors.yellow : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  " ₹ ${widget.fareamount}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: darkTheme? Colors.green: Colors.blue,
                  ),
                )
              ],
             ),
           ),)

         ],
       ),
     ),

   );
  }
}