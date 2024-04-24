import 'package:Driver/global/global.dart';
import 'package:Driver/model/user_ride_request_information.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './notification_dialog.dart';
import 'dart:async';
import '../localNotifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Driver/app/sub_screens/map_screen.dart';

class PushNotificationSystem {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription<DatabaseEvent>? messagesSubscription;

  DatabaseReference messagesRef = FirebaseDatabase.instance
      .ref()
      .child('drivers')
      .child(firebaseAuth.currentUser!.uid)
      .child("messages");

  Future<void> initialzeCloudMessaging(BuildContext context) async {
    // Your existing initialization code remains the same...

    try {
      // Listen for new user trip being added to the Realtime Database
      String? userRideRequestId;
      // Create a ref to the listener
      StreamSubscription<DatabaseEvent> messagesListener;

      messagesListener = messagesRef.onChildAdded.listen((event) {
        // Get the new message data from the event
        String childKey = event.snapshot.key!;

        messagesRef.once().then((snapvalue) {
          if (snapvalue.snapshot.value != null) {
            Map<dynamic, dynamic> messageData = snapvalue.snapshot.value as Map;

            userRideRequestId = messageData["rideRequest"];

            readUserRideRequestInformation(userRideRequestId, context);
            // ++count;
            // print(count);
            // if (count <= 1) {
            //   print(count);
            //   readUserRideRequestInformation(userRideRequestId, context);
            // }
          }
        });
      });

      // count = 0;
    } catch (err) {
      print(err);
    }
  }

  //CLOUD MESSAGING RECEIVING PUSH NOTIFICATION -- DO NOT DELETE
  // Future initialzeCloudMessaging(BuildContext context) async {
  //   //1. Terminated
  //   //When the app is closed and opened directly from the push Notification

  //   FirebaseMessaging.instance
  //       .getInitialMessage()
  //       .then((RemoteMessage? remoteMessage) {
  //     if (remoteMessage != null) {
  //       readUserRideRequestInformation(
  //           remoteMessage.data["rideRequestId"], context);
  //     }
  //   });

  //   //2. Foreground
  //   //When the app is open and receives a push notification
  //   FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
  //     readUserRideRequestInformation(
  //         remoteMessage!.data["rideRequestId"], context);
  //   });

  //   //3.Background
  //   //When the app is in background and opened directly from the push notification
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
  //     readUserRideRequestInformation(
  //         remoteMessage!.data["rideRequestId"], context);
  //   });
  // }

  readUserRideRequestInformation(
      String? userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(userRideRequestId!)
        .child("driverId")
        .onValue
        .listen((event) {
      if (event.snapshot.value == 'waiting' ||
          event.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(userRideRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            try {
              audioPlayer.open(Audio('audio/notification.mp3'));
              audioPlayer.play();

              double originLat = double.parse(
                  (snapData.snapshot.value! as Map)["origin"]["latitude"]);
              double originLng = double.parse(
                  (snapData.snapshot.value! as Map)["origin"]["longitude"]);
              String originAddress =
                  (snapData.snapshot.value! as Map)["originAddress"];

              double destinationLat = double.parse(
                  (snapData.snapshot.value! as Map)["destination"]["latitude"]);
              double destinationLng = double.parse((snapData.snapshot.value!
                  as Map)["destination"]["longitude"]);
              String destinationAddress =
                  (snapData.snapshot.value! as Map)["destinationAddress"];

              String userName = (snapData.snapshot.value! as Map)["userName"];
              String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

              String? rideRequestId = snapData.snapshot.key;

              UserRideRequestInformation userRideRequestDetails =
                  UserRideRequestInformation();
              userRideRequestDetails.originLatLng =
                  LatLng(originLat, originLng);
              userRideRequestDetails.originAddress = originAddress;
              userRideRequestDetails.destinationLatLng =
                  LatLng(destinationLat, destinationLng);
              userRideRequestDetails.destinationAddress = destinationAddress;
              userRideRequestDetails.userName = userName;
              userRideRequestDetails.userPhone = userPhone;

              userRideRequestDetails.rideRequestId = rideRequestId;

              print(event.snapshot.value);
              if (event.snapshot.value == 'waiting') {
                //send local notification
                LocalNotificationService.showRequestNotification(
                    title: "New Ride Request",
                    body: "Tap to Accept",
                    payload: userRideRequestDetails.destinationAddress,
                    fln: flutterLocalNotificationsPlugin);

                showDialog(
                    context: context,
                    builder: (BuildContext context) => NotificationDialogBox(
                          userRideRequestDetails: userRideRequestDetails,
                        ));
              }
            } catch (err) {
              print(err);
            }
          } else {
            messagesRef.remove();
            DatabaseReference ref = FirebaseDatabase.instance
                .ref()
                .child('drivers')
                .child(currentUser!.uid)
                .child('newRideStatus');

            ref.set("idle");
            Fluttertoast.showToast(msg: "This Ride Request Id do not match.");
          }
        });
      } else {
        messagesRef.remove();
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(currentUser!.uid)
            .child('newRideStatus');

        ref.set("idle");
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled");
        // Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const MapScreen()));
      }
    });
  }

  //--
  // readUserRideRequestInformation(
  //     String? userRideRequestId, BuildContext context) {
  //   DatabaseReference requestRef = FirebaseDatabase.instance
  //       .ref()
  //       .child('All Ride Requests')
  //       .child(userRideRequestId!);

  //   requestRef.child("driverId").once().then((event) {
  //     if (event.snapshot.value == 'waiting' ||
  //         event.snapshot.value == firebaseAuth.currentUser!.uid) {
  //       FirebaseDatabase.instance
  //           .ref()
  //           .child("All Ride Requests")
  //           .child(userRideRequestId)
  //           .once()
  //           .then((snapData) {
  //         if (snapData.snapshot.value != null) {
  //           try {
  //             audioPlayer.open(Audio('audio/notification.mp3'));
  //             audioPlayer.play();

  //             double originLat = double.parse(
  //                 (snapData.snapshot.value! as Map)["origin"]["latitude"]);
  //             double originLng = double.parse(
  //                 (snapData.snapshot.value! as Map)["origin"]["longitude"]);
  //             String originAddress =
  //                 (snapData.snapshot.value! as Map)["originAddress"];

  //             double destinationLat = double.parse(
  //                 (snapData.snapshot.value! as Map)["destination"]["latitude"]);
  //             double destinationLng = double.parse((snapData.snapshot.value!
  //                 as Map)["destination"]["longitude"]);
  //             String destinationAddress =
  //                 (snapData.snapshot.value! as Map)["destinationAddress"];

  //             String userName = (snapData.snapshot.value! as Map)["userName"];
  //             String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

  //             String? rideRequestId = snapData.snapshot.key;

  //             UserRideRequestInformation userRideRequestDetails =
  //                 UserRideRequestInformation();
  //             userRideRequestDetails.originLatLng =
  //                 LatLng(originLat, originLng);
  //             userRideRequestDetails.originAddress = originAddress;
  //             userRideRequestDetails.destinationLatLng =
  //                 LatLng(destinationLat, destinationLng);
  //             userRideRequestDetails.destinationAddress = destinationAddress;
  //             userRideRequestDetails.userName = userName;
  //             userRideRequestDetails.userPhone = userPhone;

  //             userRideRequestDetails.rideRequestId = rideRequestId;

  //             print("hello");

  //             showDialog(
  //                 context: context,
  //                 builder: (BuildContext context) => NotificationDialogBox(
  //                       userRideRequestDetails: userRideRequestDetails,
  //                     ));
  //           } catch (err) {
  //             print(err);
  //           }
  //         } else {
  //           messagesRef.remove();
  //           DatabaseReference ref = FirebaseDatabase.instance
  //               .ref()
  //               .child('drivers')
  //               .child(currentUser!.uid)
  //               .child('newRideStatus');

  //           ref.set("idle");
  //           Fluttertoast.showToast(msg: "This Ride Request Id do not match.");
  //         }
  //       });
  //     } else {
  //       messagesRef.remove();
  //       DatabaseReference ref = FirebaseDatabase.instance
  //           .ref()
  //           .child('drivers')
  //           .child(currentUser!.uid)
  //           .child('newRideStatus');

  //       ref.set("idle");
  //       Fluttertoast.showToast(msg: "This Ride Request has been cancelled");

  //       Navigator.pop(context);
  //     }
  //   });
  // }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registration Token: ${registrationToken}");

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child('token')
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
