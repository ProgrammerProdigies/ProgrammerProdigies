import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Common/login_page.dart';

class AdminProfilePageAndStudentAddPage extends StatefulWidget {
  const AdminProfilePageAndStudentAddPage({super.key});

  @override
  State<AdminProfilePageAndStudentAddPage> createState() =>
      _AdminProfilePageAndStudentAddPageState();
}

class _AdminProfilePageAndStudentAddPageState
    extends State<AdminProfilePageAndStudentAddPage> {
  late String imagePath;
  final picker = ImagePicker();
  late String fileName;
  File? _image;
  bool isUploading = false; // Flag for tracking upload status

  Map<String, String> profileData = {
    'name': 'Admin',
    'email': "programmerprodigies@gmail.com",
  };

  @override
  void initState() {
    super.initState();
    imagePath =
        "https://firebasestorage.googleapis.com/v0/b/programmer-prodigies.appspot.com/o/QRCode%2FQR.jpg?alt=media";
  }

  @override
  Widget build(BuildContext context) {
    imagePath =
        "https://firebasestorage.googleapis.com/v0/b/programmer-prodigies.appspot.com/o/QRCode%2FQR.jpg?alt=media";
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        backgroundColor: Colors.blueGrey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Name:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            profileData['name']!,
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey[300]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            profileData['email']!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
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
                                builder: (context) => const LoginPage()),
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
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: _image != null
                                    ? Image.file(
                                        _image!,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.17,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.17,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        imagePath,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.17,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.17,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                      ),
                      ElevatedButton(
                        onPressed: () {
                          uploadImage(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2a446b)),
                        child: const Text(
                          "Change the QR",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isUploading)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        fileName = basename(_image!.path);
      }
    });
  }

  Future<void> uploadImage(BuildContext context) async {
    if (_image != null) {
      setState(() {
        isUploading = true;
      });

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("QRCode/QR.jpg");
      await firebaseStorageRef.putFile(
        _image!,
        SettableMetadata(
            customMetadata: {"updated": DateTime.now().toString()}),
      );

      // Retrieve the new download URL with token and update the image path
      String updatedImageUrl = await firebaseStorageRef.getDownloadURL();
      setState(() {
        imagePath = updatedImageUrl;
        isUploading = false; // Hide progress indicator after upload completes
      });
      _showSnackbar(context, "QR Code changed...");
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
