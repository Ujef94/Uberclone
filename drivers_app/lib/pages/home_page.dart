import 'dart:async';
import 'dart:convert';
import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:drivers_app/pushNotification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../global/global_var.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = Colors.green;
  String titleToShow = "GO ONLINE NOW";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng possitionOfUserInLatLng = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: possitionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow() {
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event) {});
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );

        LatLng positionLatLng = LatLng(position.latitude, position.longitude);
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newLatLng(positionLatLng));
      }
    });
  }

  goOfflineNow() {
    // stop sharing live location updates
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    // stop listening to the new trip status
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem() {
    PushNotificaionSystem notificaionSystem = PushNotificaionSystem();
    notificaionSystem.generateDeviceRegistrationToken();
    notificaionSystem.startListeningForNewNotification(context);
    // notificaionSystem.requestingPermission();
  }

  retrieveCurrentDriverInfo() async{
   await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once().then((snap)
    {
      driverName = (snap.snapshot.value as Map)["name"];
      driverPhone = (snap.snapshot.value as Map)["phone"];
      driverPhoto = (snap.snapshot.value as Map)["photo"];
      vehicleColor = (snap.snapshot.value as Map)["car_details"]["vehicleColor"];
      vehicleModel = (snap.snapshot.value as Map)["car_details"]["vehicleModel"];
      vehicleNumber = (snap.snapshot.value as Map)["car_details"]["vehicleNumber"];

    });

    initializePushNotificationSystem();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // google map
          GoogleMap(
            padding: const EdgeInsets.only(top: 136),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLiveLocationOfDriver();
            },
          ),

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),

          // go online offline button
          Positioned(
            top: 61,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        backgroundColor: Colors.black87,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: const BoxDecoration(
                                // color: Colors.black45,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black,
                                //     blurRadius: 0.0,
                                //     spreadRadius: 0.0,
                                //     offset: Offset(
                                //       0.0,
                                //       0.0
                                //     ),
                                //   ),
                                // ],
                                ),
                            height: 221,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 18),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Text(
                                    (!isDriverAvailable)
                                        ? "GO ONLINE NOW"
                                        : "GO OFFLINE NOW",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 21,
                                  ),
                                  Text(
                                    (!isDriverAvailable)
                                        ? "You are about to go online, you will become available to receive trip request from users."
                                        : "You are about to go offline, you will stop receiving new trip request from users.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white30,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: const ButtonStyle(
                                              shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.blue)),
                                          child: const Text(
                                            "BACK",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!isDriverAvailable) {
                                              //go online
                                              goOnlineNow();

                                              // get driver location updates
                                              setAndGetLocationUpdates();

                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.pink;
                                                titleToShow = "GO OFFLINE NOW";
                                                isDriverAvailable = true;
                                              });
                                            } else {
                                              // go offline
                                              goOfflineNow();

                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.green;
                                                titleToShow = "GO ONLINE NOW";
                                                isDriverAvailable = false;
                                              });
                                            }
                                          },
                                          style: ButtonStyle(
                                              shape:
                                                  const MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      (titleToShow ==
                                                              "GO ONLINE NOW")
                                                          ? Colors.green
                                                          : Colors.pink)),

                                          // style: ElevatedButton.styleFrom(
                                          //     backgroundColor: (titleToShow == "GO ONLINE NOW")
                                          //         ? Colors.green
                                          //         : Colors.pink),

                                          child: const Text(
                                            "CONFIRM",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  style: ButtonStyle(
                      shape: const MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      backgroundColor: MaterialStatePropertyAll(colorToShow)),
                  child: Text(
                    titleToShow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
