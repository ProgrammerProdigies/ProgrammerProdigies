// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmerprodigies/Admin/add_new_student.dart';
import 'package:programmerprodigies/Admin/bottom_nav_bar.dart';
import 'package:programmerprodigies/send_mail.dart';

class AdminRegistrationRequest extends StatefulWidget {
  const AdminRegistrationRequest({super.key});

  @override
  State<AdminRegistrationRequest> createState() =>
      _AdminRegistrationRequestState();
}

class _AdminRegistrationRequestState extends State<AdminRegistrationRequest> {
  List<Map> student = [];
  Map<int, Map> semesterMap = {};
  List<Map<String, dynamic>> displaySemesterMap = [];
  bool dataFetched = false; // Flag to track if data has been fetched
  TextEditingController searchController = TextEditingController();

  // late StreamController<List<Map>> _streamController;
  String searchValue = '';
  List<Map> filteredStudents = []; // New list for filtered data
  late Query dbRef;
  int index = 0; // Track index for lists

  Future<void> getSemesterData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference dbRefSemester =
          FirebaseDatabase.instance.ref().child('programmerprodigies/tblSemester');
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
  }

  List<String?> selectedPackages =
      []; // List to store selected package per student

  Future<String> fetchSemesterData(String semesterKey) async {
    // print("Fetching semester data...");
    // print("SemesterKey: $semesterKey, Index: $index");

    // Reference to Firebase database for semester data
    DatabaseReference dbSemesterRef = FirebaseDatabase.instance
        .ref()
        .child("programmerProdigies/tblSemester")
        .child(semesterKey);

    // Fetch data from Firebase
    DatabaseEvent semesterDataEvent = await dbSemesterRef.once();
    DataSnapshot semesterDataSnapshot = semesterDataEvent.snapshot;

    // Extract semester data
    Map<dynamic, dynamic>? semesterData = semesterDataSnapshot.value as Map?;

    // print("semesterData ${semesterData!["Semester"]}");
    return semesterData!["Semester"];
  }

  Future<List<Map>> getStudentData() async {
    // Return data if already fetched
    if (dataFetched) {
      return student;
    }

    // Reference to the database
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('programmerprodigies/tblStudent');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    // Process data
    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    values.forEach((key, value) async {
      bool visible = value["Visibility"] as bool;
      if (!visible) {
        // Add student data
        String semester = await fetchSemesterData(
            value["Semester"].toString()); // Fetch semester
        student.add({
          'Key': key,
          'FirstName': value["FirstName"],
          'LastName': value["LastName"],
          'Email': value["Email"],
          'ContactNumber': value["ContactNumber"],
          'Gender': value["Gender"],
          'Semester': value["Semester"], // Store the semester key
          'SemesterName': semester, // Store semester name
          'FCMToken': value["FCMToken"],
          'Visibility': value["Visibility"],
          'RequestFor': value["RequestFor"]
        });

        // Add default package selection
        selectedPackages.add("Select Package");
      }
      // filteredStudents.addAll(student); // Set filtered data
      filteredStudents = List.from(student);
      dataFetched = true; // Mark data as fetched

      setState(() {}); // Refresh UI
    });
    return filteredStudents;
  }

  Map<int, Map> filteredSemesterMap = {}; // Store filtered semester data

  // Filter students based on email input
  void filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents =
            List.from(student); // Show all students when search is empty
        // filteredSemesterMap = Map.from(semesterMap); // Show all semester data
      } else {
        filteredStudents = student
            .where((s) => (s['Email'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList(); // Filter by email
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    // Add margin around the search box
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // Background color for the search box
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          // Light shadow effect
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3), // Position of the shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2), // Inner padding
                      child: CupertinoSearchTextField(
                        controller: searchController,
                        autofocus: false,
                        placeholder: "Search by Email...",
                        // Custom placeholder text
                        placeholderStyle: const TextStyle(
                          color: Colors.grey, // Placeholder text color
                          fontSize: 16, // Font size
                        ),
                        style: const TextStyle(
                          color: Colors.black, // Input text color
                          fontSize: 16, // Font size
                        ),
                        prefixIcon: const Icon(
                          Icons.search, // Custom search icon
                          color: Color(0xff2a446b), // Icon color
                        ),
                        suffixIcon: const Icon(
                          Icons.clear, // Clear button icon
                          color: Colors.grey,
                        ),
                        autocorrect: true,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded border
                        ),
                        onChanged: (String value) {
                          filterStudents(value); // Call filter function
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text(
                    "${filteredStudents.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
              color: const Color(0xfff2f6f7),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: FutureBuilder<List<Map>>(
                  future: getStudentData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // print(snapshot);
                      if (student.isNotEmpty) {
                        return ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            var studentData = filteredStudents[index];
                            // var semesterData = filteredSemesterMap[index]; // Get filtered semester data for this student
                            // print("${semesterData!["Key"]} ${studentData["Semester"]}");
                            return Card(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Student Name: ${studentData['FirstName']} ${studentData['LastName']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Student Email address: ${studentData["Email"]}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Semester: ${studentData['SemesterName']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Contact number: ${studentData['ContactNumber']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Request for: ${studentData['RequestFor']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        if (studentData['RequestFor'] != "")
                                          TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Confirm Student Registration"),
                                                    content: Text(
                                                        "Are you sure you want to confirm the registration of ${studentData['FirstName']} ${studentData["LastName"]}?"),
                                                    actions: <Widget>[
                                                      OutlinedButton(
                                                        child:
                                                            const Text('Yes'),
                                                        onPressed: () {
                                                          updateUser(studentData["Key"], studentData['RequestFor']);
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const BottomBar(
                                                                      1),
                                                            ),
                                                          );
                                                          sendMail(studentData);
                                                          getStudentData();
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xff2a446b)),
                                            child: const Text("Approve",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.1,
                                    right: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xff2a446b),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Column(
                            children: [
                              Lottie.asset(
                                  'assets/Animation/no_data_found.json',
                                  width:
                                      MediaQuery.of(context).size.width * 0.6),
                              const SizedBox(height: 16),
                              const Text('No pending student requests found',
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getSemesterData();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AdminAddNewStudent(displaySemesterMap)));
        },
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New student.",
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> updateUser(String key, String selectedPackage) async {
    bool theory = false, practical = false, papers = false;
    if("Theory and Practical and Papers" == selectedPackage){
      theory = true;
      practical = true;
      papers = true;
    } else if("Theory and Practical" == selectedPackage) {
      theory = true;
      practical = true;
    } else if("Papers" == selectedPackage) {
      papers = true;
    } else if("Theory" == selectedPackage){
      theory = true;
    } else if("Practical" == selectedPackage){
      practical = true;
    }
    final updatedData = {
      "Visibility": true,
      "Theory": theory,
      "Practical": practical,
      "Papers": papers,
      "Demo": false
    };
    final userRef = FirebaseDatabase.instance
        .ref()
        .child("programmerprodigies/tblStudent")
        .child(key);
    await userRef.update(updatedData);
  }
}
