import 'package:Driver/global/map_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'request_assistant.dart';
import '../model/direction.dart';
import '../model/direction_details_info.dart';
import '../model/user_model.dart';
import '../global/global.dart';
import "package:provider/provider.dart";
import "../infoHandler/app_info.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/trips_history_model.dart';

class AssistantMethods {
  // static void readCurrentOnlineUserInfo() async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;

  //   CollectionReference usersRef =
  //       FirebaseFirestore.instance.collection('drivers');

  //   // Query the documents in the "users" collection based on ID
  //   QuerySnapshot<Object?> snapshot =
  //       await usersRef.where('id', isEqualTo: currentUser!.uid).get();

  //   // Check if there is a matching document
  //   if (snapshot.docs.isNotEmpty) {
  //     try {
  //       // Access the first matching document
  //       DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  //           snapshot.docs[0] as DocumentSnapshot<Map<String, dynamic>>;

  //       // // Access the data of the matching document
  //       // Map<String, dynamic> data = documentSnapshot.data()!;

  //       // print(data);
  //       userModelCurrentInfo = UserModel.fromSnapshot(documentSnapshot);

  //       print(userModelCurrentInfo);
  //     } catch (err) {
  //       print(err.toString());
  //     }
  //   } else {
  //     print('No matching document found');
  //   }
  // }

  static readCurrentOnlineUserInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid);

    // Query the Realtime Database based on user ID
    DataSnapshot snapshot =
        await usersRef.child(currentUser!.uid).once() as DataSnapshot;

    // Check if the snapshot contains data
    if (snapshot.value != null) {
      try {
        // Access the data from the snapshot and create a UserModel object
        UserModel userModel = UserModel.fromSnapshot(snapshot);

        // Now you can use the userModel object
      } catch (err) {
        print(err.toString());
      }
    } else {
      print('No matching document found');
    }
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured: Failed, No response.") {
      humanReadableAddress = requestResponse("results")[0]["formatted_address"];
      print(requestResponse);

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOrigintoDestinationDirectionDetails =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapkey';
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOrigintoDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occured: Failed, No response."){
    //   return null;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.distance_value! / 60) * 0.1;
    double distanceTravelledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 500;

    if (driverVehicleType == "Bike") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      return resultFareAmount;
    } else if (driverVehicleType == "Taxi") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
      return resultFareAmount;
    } else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
  }

//read driver information
  static void driverInformation(context) {
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      // Check if there is a matching document
      if (snap.snapshot.value != null) {
        onlineDriverData.id = currentUser!.uid;
        onlineDriverData.name = (snap.snapshot.value as Map)['name'];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.address = (snap.snapshot.value as Map)["address"];
        onlineDriverData.ratings = (snap.snapshot.value as Map)["ratings"];
        onlineDriverData.organisation =
            (snap.snapshot.value as Map)['organisation'];

        onlineDriverData.v_color =
            (snap.snapshot.value as Map)["information"]["v_colour"];
        onlineDriverData.v_number =
            (snap.snapshot.value as Map)["information"]["v_number"];
        onlineDriverData.v_model =
            (snap.snapshot.value as Map)["information"]["v_model"];
        onlineDriverData.car_type =
            (snap.snapshot.value as Map)["information"]["offers"];
        driverVehicleType =
            (snap.snapshot.value as Map)["information"]["offers"];
      }
    });

    readDriverEarnings(context);
    readDriverRatings(context);
  }

  //retrieve the trips keys for online user
  //trip key = ride request key
  static void readTripsKeyForOnlineDriver(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(firebaseAuth.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trip keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });

        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          Provider.of<AppInfo>(context, listen: false)
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  //readDriverEarnings
  static void readDriverEarnings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false)
            .updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripsKeyForOnlineDriver(context);
  }

  static void readDriverRatings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false)
            .updateDriverAverageRatings(driverRatings);
      }
    });
  }
}
