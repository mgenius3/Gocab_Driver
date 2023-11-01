import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Driver/utils/state_of_countries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../sub_screens/map_screen.dart';
import '../../../utils/helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverInformation extends StatefulWidget {
  @override
  _DriverInformationState createState() => _DriverInformationState();
}

class _DriverInformationState extends State<DriverInformation> {
  final _formkey = GlobalKey<FormState>();
  bool loading = false;

  final TextEditingController v_model = TextEditingController();
  final TextEditingController v_number = TextEditingController();
  final TextEditingController v_colour = TextEditingController();
  final TextEditingController means_of_identity = TextEditingController();

  File? selectedFile;
  String? ride = 'Taxi';
  String? selectedCountry; // Initialize with null
  String? selectedState;

  List<String> getStatesByCountry(String country) {
    switch (country) {
      case 'Nigeria':
        return nigeriaStates;
      case 'Ghana':
        return ghanaStates;
      case 'Kenya':
        return kenyaStates;
      case 'Uganda':
        return ugandaStates;
      default:
        return [];
    }
  }

  @override
  void dispose() {
    v_model.dispose();
    v_number.dispose();
    v_colour.dispose();
    means_of_identity.dispose();
    super.dispose();
  }

  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
      });
    }
  }

  Future<String> uploadFile(File? file) async {
    try {
      if (file == null) {
        Fluttertoast.showToast(msg: "no file selected yet");
        throw Error();
      }
      // Get the current timestamp to use as a unique filename
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      // Reference to Firebase storage bucket
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('drivers/$uid/document/$fileName');

      // Upload the file to Firebase storage
      await ref.putFile(file);

      // Get the download URL of the uploaded file
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return "";
    }
  }

  void _submit() async {
    try {
      setState(() {
        loading = true;
      });
      if (_formkey.currentState!.validate() && selectedFile != null) {
        // Upload the file and wait for the downloadURL to be available.
        String downloadURL = await uploadFile(selectedFile);

        Map<String, dynamic> addInformation = {
          "v_model": v_model.text.trim(),
          "v_number": v_number.text.trim(),
          "v_colour": v_colour.text.trim(),
          "means_of_identity": means_of_identity.text.trim(),
          "offers": ride,
          "documents": downloadURL,
        };

        bool? addingInfo = await Auth().addDriverInformation(addInformation);
        if (addingInfo == true)
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => MapScreen()));
        else {
          setState(() {
            loading = false;
          });
        }
      } else {
        await Fluttertoast.showToast(msg: "Fill all available field");
        setState(() {
          loading = false;
        });
      }
      // Navigator.of(context).pop();
    } catch (e) {
      await Fluttertoast.showToast(
          msg: "Failed Registration: ${formatFirebaseError(e)}");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Driver Information'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 26),
                      Container(child: Image.asset("images/logo.png")),
                      SizedBox(height: 26),
                      DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Ride Offers',
                            // prefixIcon: Icon(Icons.taxi_alert),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.local_taxi),
                                    Text("Taxi Rider")
                                  ],
                                ),
                                value: "Taxi"),
                            DropdownMenuItem(
                                child: Row(children: [
                                  Icon(Icons.motorcycle),
                                  Text("Dispatch Rider")
                                ]),
                                value: "Bike")
                          ],
                          onChanged: (String? value) {
                            setState(
                              () {
                                ride = value;
                              },
                            );
                          }),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Vehicle Model',
                          prefixIcon: Icon(Icons.model_training),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Vehicle Model can\'t be empty';
                          }
                        },
                        onChanged: (text) => setState(() {
                          v_model.text = text;
                        }),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Vehicle Number can\'t be empty';
                          }
                        },
                        onChanged: (text) => setState(() {
                          v_number.text = text;
                        }),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Vehicle Colour',
                          prefixIcon: Icon(Icons.color_lens),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Vehicle Colour can\'t be empty';
                          }
                        },
                        onChanged: (text) => setState(() {
                          v_colour.text = text;
                        }),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Means of Identity',
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Means of identity can\'t be empty';
                          }
                        },
                        onChanged: (text) => setState(() {
                          means_of_identity.text = text;
                        }),
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: InkWell(
                          onTap: _openFilePicker,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Documents',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Icon(Icons.attach_file),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(selectedFile != null
                          ? selectedFile!.path
                          : 'No file selected'),
                      SizedBox(height: 24.0),
                      ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(Size(
                                double.infinity,
                                48)), // Adjust the height as needed
                          ),
                          child: loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Submit',
                                  style: TextStyle(color: Colors.white))),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
