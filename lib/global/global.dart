import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_model.dart';

final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
User? currentuser;
UserModel? UserModelCurrentInfo;
String userDropOfAddress="";

