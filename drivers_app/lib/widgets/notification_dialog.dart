import 'dart:async';

import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/pages/new_trip_page.dart';
import 'package:drivers_app/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatefulWidget {
  TripDetails? tripDetailsInfo;

  NotificationDialog({super.key, this.tripDetailsInfo});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = "";
  CommonMethods cmethods = CommonMethods();

  cancelNotificationDialogAfter20Sec() {
    const oneTickPerSecond = Duration(seconds: 1);
    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if (tripRequestStatus == "accepted") {

        timer.cancel();
        driverTripRequestTimeout = 20;
        audioPlayer.stop();
      }
      if (driverTripRequestTimeout == 0) {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
        audioPlayer.stop();
      }
      if(tripRequestStatus == "decline"){
        audioPlayer.stop();
        timer.cancel();
        driverTripRequestTimeout = 20;
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cancelNotificationDialogAfter20Sec();
  }

  checkAvailabilityTripRequest(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "please wait..."),
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once().then((snap) {
      // closing notification dialog
      Navigator.pop(context);

      //closing message dialog
      Navigator.pop(context);

      String newTripStatusValue = "";
      if (snap.snapshot.value != null) {
        newTripStatusValue = snap.snapshot.value.toString();
      } else {
        cmethods.displaySnackBar("Trip Request Not Found", context);
      }

      if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
        driverTripStatusRef.set("accepted");

        //disable homepage location updates
        cmethods.turnOffLocationUpdatesForHomePage();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) =>
                    NewTripPage(newTripDetailsInfo: widget.tripDetailsInfo)));
      } else if (newTripStatusValue == "cancelled") {
        cmethods.displaySnackBar(
            "Trip Request has been Cancelled by user", context);
      } else if (newTripStatusValue == "timeout") {
        cmethods.displaySnackBar("Trip Request time out", context);
      } else {
        cmethods.displaySnackBar("Trip Request Not Found", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),

            Image.asset(
              "assets/images/uberexec.png",
              width: 140,
            ),

            const SizedBox(height: 16),

            //title
            const Text(
              "NEW TRIP REQUEST",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 10),

            //pick - dropOff
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  //PickUp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickupAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  //dropOff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/final.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.dropOffAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(
              height: 8,
            ),

            //decline - accept
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tripRequestStatus = "decline";
                          audioPlayer.stop();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text(
                        "DECLINE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tripRequestStatus = "accepted";
                          audioPlayer.stop();
                        });
                        checkAvailabilityTripRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "ACCEPT",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
