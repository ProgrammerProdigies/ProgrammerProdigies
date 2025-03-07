// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common/login/login_page.dart';
import '../saveSharePreferences.dart';
import '../services/auth_services.dart';
import 'contact.dart';
import 'home_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  var key = "";
  var email = "";
  var name = "";
  var phone = "";
  var semesterKey = "";
  String semester = "";
  String? selectedSemester = "0";
  late Query dbRef2;
  List<Map<String, dynamic>> displaySemesterMap = [];
  bool isChecked = false;

  Future<void> loadUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      key = (await getKey())!;
      email = (await getData("Email"))!;
      dbRef2 = FirebaseDatabase.instance
          .ref()
          .child('ProgrammerProdigies/tblStudent')
          .orderByChild("Email")
          .equalTo(email);
      Map data = {};
      try {
        await dbRef2
            .once()
            .timeout(const Duration(seconds: 10))
            .then((documentSnapshot) async {
          for (var x in documentSnapshot.snapshot.children) {
            data = x.value as Map;
            name = "${data["FirstName"]} ${data["LastName"]}";
            email = data["Email"];
            phone = data["ContactNumber"];
            semesterKey = data["Semester"];
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
      }
      // Set the selectedSemester after fetching the data
      selectedSemester = semesterKey; // Set it to the semesterKey from DB
      await getSemester(semesterKey);
      getSemesterData();
    }
  }

  Future<List<Map>> getSemesterData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference dbRefSemester =
          FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSemester');
      displaySemesterMap.clear();
      displaySemesterMap.add(
          {"key": "0", "Semester": "Select Semester", "Visibility": "true"});
      await dbRefSemester.once().then((event) {
        Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
        if (values != null) {
          values.forEach((key, value) {
            if (value["Visibility"] == "true") {
              displaySemesterMap.add({
                "key": key,
                "Semester": value["Semester"],
                "Visibility": value["Visibility"],
              });
            }
          });
          displaySemesterMap
              .sort((a, b) => a["Semester"].compareTo(b["Semester"]));
        }
      });
    }
    return displaySemesterMap;
  }

  Future<void> getSemester(String semKey) async {
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblSemester/$semKey');

    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        semester = values["Semester"];
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (semester.isNotEmpty) {
              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(height: 30, color: Colors.grey),
                      ListTile(
                        title: const Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(name),
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      ListTile(
                        title: const Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(email),
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      ListTile(
                        title: const Text(
                          'Semester',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(semester),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  String? tempSelectedSemester =
                                      selectedSemester; // Temporary variable

                                  return StatefulBuilder(
                                    // Use StatefulBuilder
                                    builder: (context, setStateDialog) {
                                      // Custom setState for dialog
                                      return AlertDialog(
                                        title: const Text("Change semester"),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.13,
                                          child: Column(
                                            children: [
                                              DropdownButton<String>(
                                                value: tempSelectedSemester,
                                                // Use temporary variable
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                items: displaySemesterMap
                                                    .where((semester) => semester["Visibility"] == "true").map<DropdownMenuItem<String>>((Map<String, dynamic>semester) {
                                                    return DropdownMenuItem<String>(
                                                      value: semester["key"],
                                                      child: Text(
                                                        semester["Semester"],
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                                onChanged: (String? newValue) {
                                                  setStateDialog(() {
                                                    // Update dialog state
                                                    tempSelectedSemester =
                                                        newValue;
                                                  });
                                                },
                                                hint: const Text(
                                                  "Select a semester",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 1,
                                                  color: Colors
                                                      .grey, // Color of the underline
                                                ),
                                                itemHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.15,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                // Align text to the top
                                                children: [
                                                  Checkbox(
                                                    value: isChecked,
                                                    onChanged: (value) {
                                                      setStateDialog(() {
                                                        isChecked = value!;
                                                      });
                                                    },
                                                  ),
                                                  Expanded(
                                                    // Ensures the text wraps within the available space
                                                    child: Text(
                                                      "*Once you change the semester you will no longer be able to access the purchased document of $semester",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              if (isChecked) {
                                                // Update selectedSemester globally
                                                setState(() {
                                                  selectedSemester =
                                                      tempSelectedSemester;
                                                  semesterKey =
                                                      tempSelectedSemester!;
                                                });
                                                final updateData = {
                                                  "Demo": true,
                                                  "Theory": false,
                                                  "Papers": false,
                                                  "Practical": false,
                                                  "Visibility": false,
                                                  "Semester":
                                                      tempSelectedSemester
                                                };
                                                User? user = FirebaseAuth
                                                    .instance.currentUser;
                                                if (user != null) {
                                                  final userRef = FirebaseDatabase
                                                      .instance
                                                      .ref()
                                                      .child(
                                                          "ProgrammerProdigies/tblStudent")
                                                      .child(key);
                                                  userRef.update(updateData);
                                                }
                                                await saveData("Semester",
                                                    tempSelectedSemester);
                                                Navigator.pop(
                                                    context); // Close dialog
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const StudentHomePage(),
                                                  ),
                                                ); // Close dialog
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Semester has been changed successfully..!");
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please check the checkbox first");
                                              }
                                            },
                                            child: const Text("Update"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              isChecked = false;
                                              Navigator.pop(
                                                  context); // Close dialog without changes
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                barrierDismissible: false);
                          },
                        ),
                      ),
                      Text(
                        "*Once you change the semester you will no longer be able to access the purchased document of $semester",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      ListTile(
                        title: const Text(
                          'Contact No',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(phone),
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.remove("FirstName");
                          prefs.remove("LastName");
                          prefs.remove("Semester");
                          prefs.remove("SemesterName");
                          prefs.remove("Email");
                          prefs.remove("Theory");
                          prefs.remove("Practical");
                          prefs.remove("Papers");
                          prefs.remove("key");
                          final updatedData = {"FCMToken": ""};
                          final userRef = FirebaseDatabase.instance
                              .ref()
                              .child("ProgrammerProdigies/tblStudent")
                              .child(key);
                          await userRef.update(updatedData);
                          AuthService().signOut(context: context);
                          Navigator.pop(context);
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
                      const Divider(height: 20, color: Colors.grey),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ContactUs()),
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
                          "Contact Us",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("No data found"));
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
