import 'package:flutter/material.dart';
import 'package:deutschliveapp/pages/loadingpage.dart';

//AdmobCode
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//AdmobCode
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding().initInstances;

  //AdmobCode
  // MobileAds.instance.initialize();
  //AdmobCode
  requestNotificationPermission();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Deutsch Live APP",
    home: Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: LoadingPage(),
      ),
    ),
  ));
}
