import "package:firebase_database/firebase_database.dart";

class TripsHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? userPhone;
  String? userName;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.userPhone,
    this.userName,
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot datasnapshot) {
    time = (datasnapshot.value as Map)["time"];
    originAddress = (datasnapshot.value as Map)["originAddress"];
    destinationAddress = (datasnapshot.value as Map)["destinationAddress"];
    status = (datasnapshot.value as Map)["status"];
    fareAmount = (datasnapshot.value as Map)["fareAmount"];
    userPhone = (datasnapshot.value as Map)["userPhone"];
    userName = (datasnapshot.value as Map)["userName"];
  }
}
