// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common/login/login_page.dart';

class AdminProfilePageAndStudentAddPage extends StatefulWidget {
  const AdminProfilePageAndStudentAddPage({super.key});

  @override
  State<AdminProfilePageAndStudentAddPage> createState() =>
      _AdminProfilePageAndStudentAddPageState();
}

class _AdminProfilePageAndStudentAddPageState
    extends State<AdminProfilePageAndStudentAddPage> {
  Map<String, String> profileData = {
    'name': 'Admin',
    'email': "programmerprodigies@gmail.com",
  };
  late String fileName;
  File? _image;
  final picker = ImagePicker();
  List<Map> admin = [];
  var imagePath = "";
  var dbRef = FirebaseDatabase.instance.ref().child("ProgrammerProdigies/tblAdmin");

  Future<List<Map>> getAdminData() async {
    admin.clear();
    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        values.forEach((key, value) async {
          admin.add({
            "key": key,
            "Email": value["Email"],
            "Name": value["Name"],
            "QRCode": value["QRCode"],
          });
        });
      }
    });

    // FirebaseDatabase(app: secondaryApp).reference(); // Secondary database
    // FirebaseStorage.instanceFor(app: secondaryApp); // Secondary storage
    // Reference to the PDF in Firebase Storage
    final Reference ref = FirebaseStorage.instance.ref('QRCode/QR.jpg');
    // Generate a signed URL valid for 1 hour (3600 seconds)
    imagePath = await ref.getDownloadURL();
    return admin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
      ),
      body: Center( // Center widget ensures the loading indicator is centered
        child: FutureBuilder<List<Map>>(
          future: getAdminData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (snapshot.hasData) {
                if (admin.isNotEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Color(0xff2a446b),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Name:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      admin[0]["Name"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(color: Colors.grey[300]),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Email:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      admin[0]["Email"],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    prefs.remove("AdminEmail");
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const LoginPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2a446b),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: _image != null
                                ? Image.file(_image!,
                                height: MediaQuery.of(context).size.height *
                                    0.18,
                                width: MediaQuery.of(context).size.width *
                                    0.47,
                                fit: BoxFit.cover)
                                : Image.network(
                              imagePath,
                              height: MediaQuery.of(context).size.height *
                                  0.18,
                              width: MediaQuery.of(context).size.width *
                                  0.47,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Upload Image",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2a446b)),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(), // Center the progress indicator
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
    await uploadImage();
  }

  Future uploadImage() async {
    fileName = "QR.jpg";
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child("QRCode/$fileName");
    firebaseStorageRef.putFile(_image!);
  }
}
