import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID= FirebaseAuth.instance.currentUser!.uid;

// String googleMAPKEY = "AIzaSyA7B1zC-gUw2hJRwEqbJmrpnOUt4UieSlo";
// String serverKeyFCM = "key=AAAAenFnGus:APA91bFfsed3QVkaFEn8kbJZ18QcfvjUT0zWWH9eO8SGkwhaTRv0cUJAG708tIwrR1Qg9K2hJUJncQ7FeToRPbP9hNe0WxLo3fRDijkxw705vw-Hhbk7ZtWkr-_HQRHTX_fQkgj3te-5";

String googleMAPKEY = "AIzaSyDuDxriw8CH8NbVLiXtKFQ2Nb64AoRSdyg";
String serverKeyFCM = "key=AAAA-TlDt0c:APA91bGMHqFwSALxrMlWdBz2GPnkSk7sT5r0obbYz6ecKaXxTpHO0m6UVKJolga9JLdPW6KT1dsxIuao-oIejtysMWr3pzQmMImMHnhhzcpWhT0EbqhO_GZR5OD5NGB-RIV8FvI4SZPp";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
