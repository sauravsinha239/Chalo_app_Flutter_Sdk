import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
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
            title: Text("Update"),
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
                  child: Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){

                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "name" : nameTextEditor.text.trim(),
                  }).then((value){
                    // change state
                    setState(() {
                      UserModelCurrentInfo!.name = nameTextEditor.text.trim();
                    });
                    nameTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: Text("Ok", style: TextStyle(color: Colors.green),),
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
            title: Text("Update"),
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
                child: Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){

                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "phone" : phoneTextEditor.text.trim(),
                  }).then((value){
                    setState(() {
                      UserModelCurrentInfo!.phone = phoneTextEditor.text.trim();
                    });
                 phoneTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: Text("Ok", style: TextStyle(color: Colors.green),),
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
            title: Text("Update"),
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
                child: Text("Cancel", style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: (){


                  UserRef.child(firebaseAuth.currentUser!.uid).update({
                    "address" : addressTextEditor.text.trim(),
                  }).then((value){
                    setState(() {
                      UserModelCurrentInfo!.address = addressTextEditor.text.trim();
                    });
                    addressTextEditor.clear();
                    Fluttertoast.showToast(msg: "Modified Succesfully.");

                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error Occurred!. \n $errorMessage");
                  });
                  Navigator.pop(context);

                  },
                child: Text("Ok", style: TextStyle(color: Colors.green),),
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

        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: (){
                Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red,size: 22,),
          ),
          title: Text(
            "Profile",
            style: TextStyle(
                color: Colors.purple,
                fontWeight:
                FontWeight.bold,
                fontSize: 28),
          ),centerTitle: true,

          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white,),
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${UserModelCurrentInfo!.name!}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.red : Colors.green,
                    ),
                    ),
                    IconButton(
                        onPressed: (){
                          showUserNameDialogAlert(context, UserModelCurrentInfo!.name!);
                        },
                        icon: Icon(
                          Icons.edit, color: Colors.green,
                        ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,

                ),
                //phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${UserModelCurrentInfo!.phone!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.red : Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        showUserPhoneDialogAlert(context, UserModelCurrentInfo!.phone!);
                      },
                      icon: Icon(
                        Icons.edit, color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                //Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${UserModelCurrentInfo!.address!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.red : Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: (){

                          showUserAddressDialogAlert(context, UserModelCurrentInfo!.address!);
                      },
                      icon: Icon(
                        Icons.edit, color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Text("${UserModelCurrentInfo!.email!}",
                  style: TextStyle(
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