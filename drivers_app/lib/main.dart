import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/pages/home_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'authentication/login_screen.dart';

// Import the generated file
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if(valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  // await Permission.notification.isDenied.then((valueOfPermission){
  //   if(valueOfPermission) {
  //     Permission.notification.request();
  //   }
  // });

  var notificationPermissionStatus = await Permission.notification.status;
  if (notificationPermissionStatus.isDenied) {
    await Permission.notification.request();
  }

  // createNotificationChannel();

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
       home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const Dashboard(),
    );
  }
}


