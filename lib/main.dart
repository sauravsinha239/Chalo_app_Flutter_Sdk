import 'dart:async';
import 'package:cab/Theme_provider/theme_provider.dart';
import 'package:cab/infoHandler/app_info.dart';
import 'package:cab/screen/search_place_screen.dart';
import 'package:cab/splash_screen/spalsh_screen.dart';
// ignore: unused_import
import 'package:cab/splash_screen/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

 Future <void> main() async{
 runApp(const MyApp());
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppInfo(),
      child: MaterialApp(
      title: 'Flutter Demo',
     themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Splash(
      ),
    ),
      );
  }
}
