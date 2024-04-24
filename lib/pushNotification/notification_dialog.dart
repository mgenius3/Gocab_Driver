import 'package:Driver/Assistants/assistant_method.dart';
import 'package:Driver/global/global.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:Driver/model/user_ride_request_information.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app/sub_screens/new_trip_screen.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineDriverData.car_type == "Taxi"
                  ? "images/car.png"
                  : "images/bike.png",
            ),
            const SizedBox(height: 10),
            const Text(
              "New Ride Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.blue),
            ),
            const SizedBox(
              height: 14,
            ),
            const Divider(height: 2, thickness: 2, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("images/pick.png", width: 30, height: 30),
                      SizedBox(width: 10),
                      Expanded(
                          child: Container(
                        child: Text(
                          widget.userRideRequestDetails!.originAddress!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(
              height: 2,
              thickness: 2,
              color: Colors.blue,
            ),

            //buttons for cancelling and accepting the ride request
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // audioPlayer.pause();
                        // audioPlayer.stop();
                        // audioPlayer = AssetsAudioPlayer();

                        Navigator.pop(context);
                        cancelRideRequest();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: TextStyle(fontSize: 15),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                        "Accept".toUpperCase(),
                        style: TextStyle(fontSize: 15),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  final driver = FirebaseDatabase.instance
      .ref()
      .child("drivers")
      .child(firebaseAuth.currentUser!.uid);

  final allRides = FirebaseDatabase.instance.ref().child('All Ride Requests');

  acceptRideRequest(BuildContext context) {
//change driver status to accepted
    driver.child("newRideStatus").once().then((snap) {
      if (snap.snapshot.value != "accepted") {
        driver.child("newRideStatus").set("accepted");

        // AssistantMethods.pauseLiveLocationUpdates();

        //trip started now - send driver to new tripScreen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => NewTripScreen(
                      userRideRequestDetails: widget.userRideRequestDetails,
                    )));
      } else {
        Fluttertoast.showToast(msg: "This Ride Request do not exists");

        //----
        //remove the user request message
        DatabaseReference messagesRef = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(currentUser!.uid)
            .child("messages");
        messagesRef.remove();

        //set driver to idle
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(currentUser!.uid)
            .child('newRideStatus');
        ref.set("idle");
      }
    });
  }

  cancelRideRequest() {
    //remove the user request message
    DatabaseReference messagesRef = driver.child('messages');
    messagesRef.remove();
  }
}
