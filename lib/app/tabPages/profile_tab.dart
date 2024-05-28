import 'package:Driver/Assistants/assistant_method.dart';
import 'package:Driver/splash.dart';
import 'package:flutter/material.dart';
import '../../global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './home_tab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void> uploadImageToFirebase(String userId) async {
    try {
      // Pick an image from the device's gallery
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Create a reference to the Firebase Storage bucket
        Reference storageRef = FirebaseStorage.instance.ref();

        // Generate a unique ID for the image
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload the image to Firestore
        TaskSnapshot snapshot = await storageRef
            .child('users/$userId/images/$imageName.jpg')
            .putFile(File(image.path));

        // Retrieve the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the download URL in Firestore

        userRef.child(firebaseAuth.currentUser!.uid).update({
          "profile_url": downloadUrl,
        }).then((value) {
          Fluttertoast.showToast(msg: "Updated successfully");
          AssistantMethods.driverInformation(context);
        }).catchError((errorMessage) {
          Fluttertoast.showToast(msg: "Error Occured. \n $errorMessage");
        });
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> showDriverNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
                child: Column(children: [
              TextFormField(
                controller: nameTextEditingController,
              )
            ])),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim(),
                    }).then((value) {
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated successfully");
                      AssistantMethods.driverInformation(context);
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occured. \n $errorMessage");
                    });

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          );
        });
  }

  Future<void> showDriverPhoneDialogAlert(BuildContext context, String phone) {
    phoneTextEditingController.text = phone;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
                child: Column(children: [
              TextFormField(
                controller: phoneTextEditingController,
              )
            ])),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone": nameTextEditingController.text.trim(),
                    }).then((value) {
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated successfully");
                      AssistantMethods.driverInformation(context);
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occured. \n $errorMessage");
                    });

                    Navigator.pop(context);
                  },
                  child:
                      const Text("Ok", style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  Future<void> showDriverAddressDialogAlert(
      BuildContext context, String address) {
    addressTextEditingController.text = address;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
                child: Column(children: [
              TextFormField(
                controller: addressTextEditingController,
              )
            ])),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "address": nameTextEditingController.text.trim(),
                    }).then((value) {
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated successfully");
                      AssistantMethods.driverInformation(context);
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occured. \n $errorMessage");
                    });

                    Navigator.pop(context);
                  },
                  child:
                      const Text("Ok", style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.black)),
                title: const Text("Profile Screen",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold))),
            body: ListView(
              padding: EdgeInsets.all(0),
              children: [
                Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                uploadImageToFirebase(
                                    firebaseAuth.currentUser!.uid);
                              },
                              child: onlineDriverData.profile_url != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          onlineDriverData.profile_url!),
                                      radius: 30,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors
                                          .blue, // Customize the background color as needed
                                      radius: 30,
                                      child: Text(
                                        "${onlineDriverData.name![0].toUpperCase()}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // Customize the text color as needed
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${onlineDriverData.name}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      showDriverNameDialogAlert(
                                          context, onlineDriverData.name!);
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white))
                              ],
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.white,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${onlineDriverData.phone}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                    onPressed: () {
                                      showDriverPhoneDialogAlert(
                                          context, onlineDriverData.phone!);
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white))
                              ],
                            ),
                            const Divider(thickness: 1, color: Colors.white),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${onlineDriverData.address}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      showDriverAddressDialogAlert(
                                          context, onlineDriverData.address!);
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white))
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.white,
                            ),
                            onlineDriverData.organisation != null
                                ? Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Organisations",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          Row(
                                            children: [
                                              Text(
                                                  "${onlineDriverData.organisation}",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Icon(Icons.group,
                                                  color: Colors.white)
                                            ],
                                          )
                                        ],
                                      ),
                                      const Divider(
                                          thickness: 1, color: Colors.white),
                                    ],
                                  )
                                : const SizedBox(),
                            Text("${onlineDriverData.email!}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${onlineDriverData.v_model} \n ${onlineDriverData.v_color} (${onlineDriverData.v_number})",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Image.asset(
                                  onlineDriverData.car_type == "Taxi"
                                      ? "images/car.png"
                                      : "images/bike.png",
                                  width: 40,
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () {
                                  firebaseAuth.signOut();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => Splash()));
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.redAccent),
                                child: Text("Log Out"))
                          ],
                        )))
              ],
            )));
  }
}
