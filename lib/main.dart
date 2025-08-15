import 'package:flutter/material.dart';
import 'package:deutschliveapp/pages/loadingpage.dart';

//AdmobCode
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//AdmobCode

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding().initInstances;

  //AdmobCode
  // MobileAds.instance.initialize();
  //AdmobCode

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Hamrah TV",
    home: Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: LoadingPage(),
      ),
    ),
  ));
}
