import 'package:Driver/pushNotification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Driver/global/global.dart';
import 'package:Driver/Assistants/assistant_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:Driver/localNotifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with WidgetsBindingObserver {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.427961333580664, -122.08749659562),
    zoom: 16.4764,
  );

  var geolocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Now Online";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  // checkIfLocationPermissionAllowed() async {
  //   _locationPermission = await Geolocator.requestPermission();

  //   if (_locationPermission == LocationPermission.denied) {
  //     _locationPermission = await Geolocator.requestPermission();
  //   }
  // }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            driverCurrentPosition!, context);

    print(humanReadableAddress);

    AssistantMethods.readDriverRatings(context);
  }

  @override
  void initState() {
    super.initState();

    driverIsOnlineNow();
    // checkIfLocationPermissionAllowed();
    // readCurrentDriverInformation();
    AssistantMethods.driverInformation(context);
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initialzeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
    // NotificationService().init(context); //
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Run your function here when the app goes into the background or is closed.
      driverIsOfflineNow();
    }
    //  else if (state == AppLifecycleState.resumed) {
    //   driverIsOnlineNow();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 100),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);

            newGoogleMapController = controller;

            locateDriverPosition();
          },
        ),

        //ui for online/offline driver
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87)
            : Container(),

        //button for online/offline driver
        Positioned(
            top: statusText != 'Now Online'
                ? MediaQuery.of(context).size.height * 0.45
                : 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (isDriverActive != true) {
                        driverIsOnlineNow();
                        // updateDriversLocationAtRealTime();

                        // setState(() {
                        //   statusText = "Now Online";
                        //   isDriverActive = true;
                        //   buttonColor = Colors.transparent;
                        // });
                      } else {
                        driverIsOfflineNow();
                        // setState(() {
                        //   statusText = "Now Offline";
                        //   isDriverActive = false;
                        //   buttonColor = Colors.grey;
                        // });
                        Fluttertoast.showToast(msg: "You are offline now");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        )),
                    child: statusText != "Now Online"
                        ? Text(
                            'Go Online',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : Icon(Icons.phonelink_ring,
                            color: Colors.white, size: 26))
              ],
            ))
      ],
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    driverCurrentPosition = pos;

    Geofire.initialize('activeDrivers');
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid)
        .child('newRideStatus');

    ref.set("idle");
    ref.onValue.listen((event) {});

    /////////////////////////////
    updateDriversLocationAtRealTime();

    setState(() {
      statusText = "Now Online";
      isDriverActive = true;
      buttonColor = Colors.transparent;
    });
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive == true) {
        Geofire.setLocation((currentUser!.uid), driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid)
        .child('newRideStatus');

    ref.onDisconnect();
    ref.remove();
    ref = null;

/////////////////////////////////////////////
    setState(() {
      statusText = "Now Offline";
      isDriverActive = false;
      buttonColor = Colors.grey;
    });
//kill application
    // Future.delayed(Duration(milliseconds: 2000), () {
    //   SystemChannels.platform.invokeListMethod("SystemNavigator.pop");
    // });
  }
}
