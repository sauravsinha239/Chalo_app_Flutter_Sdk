import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../global/global.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override

  final nameTextEditor= TextEditingController();
  final phoneTextEditor= TextEditingController();
  final addressTextEditor= TextEditingController();
  DatabaseReference UserRef = FirebaseDatabase.instance.ref().child("users");
//name
  Future<void> showUserNameDialogAlert(BuildContext context, String name){
    nameTextEditor.text =name;

    return showDialog(
        context: context,
        builder:(context){
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditor,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
              },
                  child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){

                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "name" : nameTextEditor.text.trim(),
                  }).then((value){
                    // change state
                    setState(() {
                      userModelCurrentInfo!.name = nameTextEditor.text.trim();
                    });
                    nameTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: const Text("Ok", style: TextStyle(color: Colors.green),),
              ),
            ],
          );
        }
    );
  }
  //Phone update dialog
  Future<void> showUserPhoneDialogAlert(BuildContext context, String Phone){
    phoneTextEditor.text =Phone;

    return showDialog(
        context: context,
        builder:(context){
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditor,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){

                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "phone" : phoneTextEditor.text.trim(),
                  }).then((value){
                    setState(() {
                      userModelCurrentInfo!.phone = phoneTextEditor.text.trim();
                    });
                 phoneTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: const Text("Ok", style: TextStyle(color: Colors.green),),
              ),
            ],
          );
        }
    );
  }
  //Address update dialog
  Future<void> showUserAddressDialogAlert(BuildContext context, String address){
    addressTextEditor.text =address;

    return showDialog(
        context: context,
        builder:(context){
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: addressTextEditor,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){


                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "address" : addressTextEditor.text.trim(),
                  }).then((value){
                    setState(() {
                      userModelCurrentInfo!.address = addressTextEditor.text.trim();
                    });
                    addressTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);

                  },
                child: const Text("Ok", style: TextStyle(color: Colors.green),),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
      FocusScope.of(context).unfocus();
      },
      child: Scaffold(
    backgroundColor: darkTheme ? Colors.black: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: (){
                Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red,size: 22,),
          ),
          title: const Text(
            "Profile",
            style: TextStyle(
                color: Colors.purple,
                fontWeight:
                FontWeight.bold,
                fontSize: 28
            ),
          ),centerTitle: true,

          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(50),
                  decoration: const BoxDecoration(
                    color: Colors.lightBlueAccent,shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white,),
                ),
                const SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(userModelCurrentInfo!.name!,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.red : Colors.green,
                    ),
                    ),
                    IconButton(
                        onPressed: (){
                          showUserNameDialogAlert(context, userModelCurrentInfo!.name!);
                        },
                        icon: const Icon(
                          Icons.edit, color: Colors.green,
                        ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,

                ),
                //phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(userModelCurrentInfo!.phone!,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.red : Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        showUserPhoneDialogAlert(context, userModelCurrentInfo!.phone!);
                      },
                      icon: const Icon(
                        Icons.edit, color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                //Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(userModelCurrentInfo!.address!,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.red : Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: (){

                          showUserAddressDialogAlert(context, userModelCurrentInfo!.address!);
                      },
                      icon: const Icon(
                        Icons.edit, color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                Text(userModelCurrentInfo!.email!,
                  style:  GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:  Colors.purple ,
                  ),
                ),

              ],
            ),
          ),
        ),

      ),

    );
  }
}