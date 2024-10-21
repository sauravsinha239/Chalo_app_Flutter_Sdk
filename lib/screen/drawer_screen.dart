
import 'package:cab/global/global.dart';
import 'package:cab/screen/login_screen.dart';
import 'package:cab/screen/profile_screen.dart';
import 'package:cab/screen/tripsHistoryScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/user_model.dart';

class DrawerScreen extends StatefulWidget{
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      width: 220,
      
      child: Drawer(

        child: Padding(

          padding:  const EdgeInsets.fromLTRB(20, 50, 10, 20),
          child: Column(

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(35),

                    decoration: const BoxDecoration(
                      color: Colors.lightBlueAccent,
                      shape: BoxShape.circle ,
                    ),
                    child: Icon(
                      Icons.person_2_sharp,
                      color: darkTheme ?  Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            userModelCurrentInfo?.name ?? 'Unknown',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize:28,
                              color: darkTheme ? Colors.grey : Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis, // Handle text overflow
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height:40,),

                  GestureDetector(
                    onTap: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (c)=>const ProfileScreen()));
                        currentUser = firebaseAuth.currentUser;
                        DatabaseReference userRef = FirebaseDatabase.instance
                            .ref()
                            .child("users")
                            .child(currentUser!.uid);
                        DatabaseEvent event = await userRef.once();
                        DataSnapshot snapshot = event.snapshot;
                        userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person,
                        size: 25,
                        color: darkTheme ?  Colors.yellow : Colors.blue,
                      ),
                      const Padding(padding: EdgeInsets.all(6)),
                    Text(
                      "Profile",
                      style: GoogleFonts.lato(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ?  Colors.white : Colors.black,
                      )
                    ),
                      ],
                    ),
                  ),
                  //
                  const SizedBox(height: 35,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const TripsHistoryScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.trip_origin_outlined,
                          size: 25,
                          color: darkTheme ?  Colors.yellow : Colors.blue,
                        ),
                        const Padding(padding: EdgeInsets.all(6)),
                        Text(
                          "your trips ",
                          style: GoogleFonts.lato(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkTheme ?  Colors.white : Colors.black,
                          )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35,),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.question_mark_rounded,
                          size: 25,
                          color: darkTheme ?  Colors.yellow : Colors.blue,
                        ),
                        const Padding(padding: EdgeInsets.all(6)),
                        Text(
                          "About",
                          style: GoogleFonts.lato(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkTheme ?  Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35,),
                  //Sign out

                  GestureDetector(
                    onTap: (){
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>const LoginScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.login_outlined,
                          size: 25,
                          color:   Colors.red,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Text(
                          "log out",
                          style: GoogleFonts.lato(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkTheme ?  Colors.red[800] : Colors.red[800],
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
    );
  }
}