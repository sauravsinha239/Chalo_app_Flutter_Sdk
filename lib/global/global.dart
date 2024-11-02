import 'package:cab/model/direction_details_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_model.dart';

final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOfAddress="";
String userPickupAddress= "";
String driverVehicleDetails="";
String driverName="";
String driverRatings="";
String driverPhone="";
double countRatingStar=0.0;
String titleStarRating= "";
String ? serverToken="";
List driversInfo= [];



