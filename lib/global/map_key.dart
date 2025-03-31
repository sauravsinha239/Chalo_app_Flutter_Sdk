import 'dart:developer';

import '../Assistants/FeatchApiKey.dart';

String mapKey="AIzaSyBIMWvKx94ksy6JSwh3XaTE_TcW9XOdl7A";
String goMapKey="";


void getMapKey()async {
  goMapKey = await MapConfig.getMapsApiKey();
  log("Map Key fetched Successfully {$goMapKey}");
}