
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

class  UserModel{
  String ? phone;
  String ? name;
  String ? id;
  String ?email;
  String? address;

  UserModel({
    this.phone,
    this.name,
    this.id,
    this.email,
    this.address

});
  UserModel.fromSnapshot( DataSnapshot snap){

    if (snap.value != null && snap.value is Map) {

      final data = snap.value as Map<dynamic, dynamic>;
      phone=(snap.value as dynamic)["phone"];
      name=(snap.value as dynamic)["name"];
      id= snap.key;
      email=(snap.value as dynamic)["email"];
      address=(snap.value as dynamic)["address"];
    }
    else{
      log("Invalid snapshot data: ${snap.value}");

    }


  }
}
