import 'package:Driver/Assistants/assistant_method.dart';
import 'package:Driver/model/user_ride_request_information.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Driver/global/global.dart';
import '../../widget/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widget/fare_amount_collection_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "Could not launch $url";
  }
}

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.427961333580664, -122.08749659562),
    zoom: 16.4764,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  //Step 1: When driver accepts the user ride request
  // originLatlng = driverCurent location
  //destinationLatLng = user Pickup location

  //step 2: when driver picks up the user in his car
  //originLatLng = user current location which will be also the current location of the driver at that time
  //destinationLat Lng = user's dropoff location
  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait...."));

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
        markerId: MarkerId("destinationID"),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);

    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    //TODO: implement initState
    super.initState();

    saveAssignDriverDetailsToUserRideRequest();
  }

  getDriverLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latlngLiveDriverPosition = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latlngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "This is  your position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latlngLiveDriverPosition, zoom: 18);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");

        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latlngLiveDriverPosition;
      updateDurationTimeAtRealTime();
      //updating driver location at real time in database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails == true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        destinationLatLng = widget.userRideRequestDetails!.originLatLng;
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;
    }
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 3));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child("driverId") != "waiting") {
      databaseReference.child("driverLocation").set(driverLocationDataMap);
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("profile_url").set(onlineDriverData.profile_url);

      databaseReference.child("car_details").set(
          onlineDriverData.v_model.toString() +
              " " +
              onlineDriverData.v_number.toString() +
              " (" +
              onlineDriverData.v_color.toString() +
              ") ");

      saveRideRequestIdToDriverHistory();
    } else {
      Fluttertoast.showToast(
          msg:
              "This ride is already accepted by another driver. \n Relaoding the App");
    }
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }

  endTripNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait...."));

    //get the tripDirectionDetails = distance traveled
    var currentDriverPositionLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude);

    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng,
            widget.userRideRequestDetails!.originLatLng!);

    //fare amount
    // double totalFareAmount =
    //     AssistantMethods.calculateFareAmountFromOriginToDestination(
    //         tripDirectionDetails);

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("All Ride Requests")
    //     .child(widget.userRideRequestDetails!.rideRequestId!)
    //     .child("fareAmount")
    //     .set(totalFareAmount.toString());

    double totalFareAmount = 0.0;
    //--
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        totalFareAmount = double.parse(
            (snapData.snapshot.value as Map)["fareAmount"].toString());

        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(widget.userRideRequestDetails!.rideRequestId!)
            .child("status")
            .set("ended");

        //---
        DatabaseReference messagesRef = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(currentUser!.uid)
            .child("messages");
        messagesRef.remove();

        Navigator.pop(context);

        //display fare amount in dialog box
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                FareAmountCollectionDialog(totalFareAmount: totalFareAmount));

        //save fare amount to driver total earnings
        saveFareAmountToDriverEarnings(totalFareAmount!);
      }
    });
  }

  //save fare amount to driver total earnings
  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: mapPadding),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          markers: setOfMarkers,
          circles: setOfCircle,
          polylines: setOfPolyline,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newTripGoogleMapController = controller;

            setState(() {
              mapPadding = 350;
            });

            var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);

            var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

            drawPolylineFromOriginToDestination(
                driverCurrentLatLng, userPickUpLatLng!);

            getDriverLocationUpdatesAtRealTime();
          },
        ),

        //UI
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          blurRadius: 18,
                          spreadRadius: 0.5,
                          offset: Offset(0.6, 0.6))
                    ]),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    Text(durationFromOriginToDestination,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        IconButton(
                            onPressed: () {
                              _makePhoneCall(
                                  "tel: ${widget.userRideRequestDetails!.userPhone!}");
                            },
                            icon: Icon(
                              Icons.phone,
                              color: Colors.black,
                            ))
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          "images/pick.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Text(
                                widget.userRideRequestDetails!.originAddress!,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black)),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Text(
                                widget.userRideRequestDetails!
                                    .destinationAddress!,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black)),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                        onPressed: () async {
                          //[driver has arrived at user pickup location] - Arrived Button

                          if (rideRequestStatus == "accepted") {
                            rideRequestStatus = "arrived";

                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Requests")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "Let's Go";
                              buttonColor = Colors.lightGreen;
                            });

                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    ProgressDialog(message: "Loading..."));

                            await drawPolylineFromOriginToDestination(
                              widget.userRideRequestDetails!.originLatLng!,
                              widget.userRideRequestDetails!.destinationLatLng!,
                            );

                            Navigator.pop(context);
                          }

                          //[user has been picked from the user's current location] - Let's Go button
                          else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "ontrip";

                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Requests")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "End Trip";
                              buttonColor = Colors.red;
                            });
                          }

                          //[user/driver has reached the drop-off location]- End Trip Button

                          else if (rideRequestStatus == "ontrip") {
                            endTripNow();
                          }
                        },
                        icon: Icon(Icons.directions_car,
                            color: Colors.white, size: 25),
                        label: Text(buttonTitle!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)))
                  ]),
                ),
              ),
            ))
      ],
    ));
  }
}
