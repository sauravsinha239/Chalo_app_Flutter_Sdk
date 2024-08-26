
import 'package:cab/global/global.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/user_model.dart';

class Assistants{
static void readCurrentOnlineUserInfo()async{
  currentuser =firebaseAuth.currentUser;
  DatabaseReference userRef = FirebaseDatabase.instance
  .ref()
  .child("users")
  .child(currentuser!.uid);
  userRef.once().then((snap){
    if(snap.snapshot.value!=null){
      UserModelCurrentInfo =UserModel.fromSnapshot(snap.snapshot);
    }
  });
}
}