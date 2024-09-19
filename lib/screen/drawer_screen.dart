import 'dart:ui';

import 'package:cab/global/global.dart';
import 'package:cab/screen/login_screen.dart';
import 'package:cab/screen/profile_screen.dart';
import 'package:cab/splash_screen/spalsh_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../model/user_model.dart';

class drawerScreen extends StatefulWidget{
  const drawerScreen({super.key});

  @override
  State<drawerScreen> createState() => _drawerScreenState();
}

class _drawerScreenState extends State<drawerScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      child: SizedBox(

        width: 220,

        child: Drawer(

          child: Padding(

            padding:  EdgeInsets.fromLTRB(10, 50, 0, 20),
            child: Column(

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(40),

                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle ,
                      ),
                      child: Icon(
                        Icons.person_2_sharp,
                        color: darkTheme ?  Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 40,),

                    GestureDetector(
                      onTap: (){

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              UserModelCurrentInfo?.name ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:20,
                                color: darkTheme ? Colors.grey : Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis, // Handle text overflow
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:40,),

                    GestureDetector(
                      onTap: () async{
                          Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                          currentuser = firebaseAuth.currentUser;
                          DatabaseReference userRef = FirebaseDatabase.instance
                              .ref()
                              .child("users")
                              .child(currentuser!.uid);
                          DatabaseEvent event = await userRef.once();
                          DataSnapshot snapshot = event.snapshot;
                          UserModelCurrentInfo = UserModel.fromSnapshot(snapshot);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mode_edit_outline_rounded,
                          size: 25,
                          color: darkTheme ?  Colors.yellow : Colors.blue,
                        ),
                        Padding(padding: EdgeInsets.all(6)),
                      Text(
                        "edit profile ",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: darkTheme ?  Colors.white : Colors.black,
                        ),
                      ),
                        ],
                      ),
                    ),
                    //
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: (){
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.trip_origin_outlined,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "your trips ",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),

                    GestureDetector(
                      onTap: (){
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "payments ",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "notification ",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: (){

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.car_rental,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "promos ",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: (){
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline_sharp,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "help",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: (){

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.tram,
                            size: 25,
                            color: darkTheme ?  Colors.yellow : Colors.blue,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          Text(
                            "Free Trips",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    //Signout

                    GestureDetector(
                      onTap: (){
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 25,
                            color:   Colors.red,
                          ),
                          Padding(padding: EdgeInsets.all(5)),
                          Text(
                            "signout",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ?  Colors.white : Colors.black,
                            ),

                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}