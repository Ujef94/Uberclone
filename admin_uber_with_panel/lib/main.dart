import 'package:admin_uber_with_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDBLj4rZ6VMo6CPqigOTtaXwftw1VyxRmw",
          authDomain: "uberclone-40fa9.firebaseapp.com",
          databaseURL: "https://uberclone-40fa9-default-rtdb.firebaseio.com",
          projectId: "uberclone-40fa9",
          storageBucket: "uberclone-40fa9.appspot.com",
          messagingSenderId: "1070407595847",
          appId: "1:1070407595847:web:f7c6d5a17b64245ddafe62",
          measurementId: "G-67P2M02HPN")
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const SideNavigationDrawer(),
    );
  }
}
