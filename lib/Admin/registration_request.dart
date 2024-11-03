// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/add_new_student.dart';
import 'package:programmer_prodigies/Admin/bottom_nav_bar.dart';

class AdminRegistrationRequest extends StatefulWidget {
  const AdminRegistrationRequest({super.key});

  @override
  State<AdminRegistrationRequest> createState() =>
      _AdminRegistrationRequestState();
}

class _AdminRegistrationRequestState extends State<AdminRegistrationRequest> {
  late String imagePath;
  late String date;
  late String username;
  late String userkey;
  List<Map> Students = [];
  late String packageImagePath;
  Map<dynamic, dynamic>? userData;
  Map<int, Map> semesterMap = {};
  List<Map<String, dynamic>> displaySemesterMap = [];
  late Map data2;
  late Map data;
  late var disease;
  bool visible = false;
  String? selectedPackage = "Select Package";
  bool dataFetched = false; // Flag to track if data has been fetched

  List<Map<String, dynamic>> displayPackageMap = [
    {
      "key": "Select Package",
      "PackageName": "Select Package",
      "Visibility": "true"
    },
    {"key": "1", "PackageName": "Theory", "Visibility": "true"},
    {"key": "2", "PackageName": "Practical", "Visibility": "true"},
    {"key": "3", "PackageName": "Papers", "Visibility": "true"},
    {"key": "4", "PackageName": "Theory + Practical", "Visibility": "true"},
    {
      "key": "5",
      "PackageName": "Theory + Practical + Papers",
      "Visibility": "true"
    },
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   loadUser();
  // }

  // Future<void> loadUser() async {
  //   String? Username = await getData("username");
  //   String? UserKey = await getKey();
  //   setState(() {
  //     username = Username!;
  //     userkey = UserKey!;
  //   });
  //   getPackagesData();
  // }

  // Future<void> fetchUserData(String key, int index) async {
  //   userMap.clear();
  //   DatabaseReference dbUserData = FirebaseDatabase.instance
  //       .ref()
  //       .child("ProgrammerProdigies/tblStudent")
  //       .child(key);
  //   DatabaseEvent userDataEvent = await dbUserData.once();
  //   DataSnapshot userDataSnapshot = userDataEvent.snapshot;
  //   userData = userDataSnapshot.value as Map?;
  //   userMap[index] = {
  //     "Key": userDataSnapshot.key,
  //     "StudentName": userData!["HospitalName"],
  //   };
  //   setState(() {});
  // }

  Future<void> fetchSemesterData(String key, int index) async {
    semesterMap.clear();
    DatabaseReference dbUserData = FirebaseDatabase.instance
        .ref()
        .child("ProgrammerProdigies/tblSemester")
        .child(key);
    DatabaseEvent userDataEvent = await dbUserData.once();
    DataSnapshot userDataSnapshot = userDataEvent.snapshot;
    userData = userDataSnapshot.value as Map?;
    semesterMap[index] = {
      "Key": userDataSnapshot.key,
      "Semester": userData!["Semester"],
    };
    setState(() {});
  }

  Future<void> getSemesterData() async {
    DatabaseReference dbRefSemester = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblSemester');
    displaySemesterMap.clear();
    displaySemesterMap
        .add({"key": "0", "Semester": "Select Semester", "Visibility": "true"});
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

  Future<List<Map>> getStudentData() async {
    // Students.clear();
    if (dataFetched) {
      return Students; // Return if data has already been fetched
    }
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblStudent');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value == null) {
      return Students;
    }

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    Students.clear();
    values.forEach((key, value) async {
      if (value["Visibility"] == false) {
        Students.add({
          'Key': key,
          'FirstName': value["FirstName"],
          'LastName': value["LastName"],
          'Email': value["Email"],
          'ContactNumber': value["ContactNumber"],
          'Gender': value["Gender"],
          'Semester': value["Semester"],
          'FCMToken': value["FCMToken"],
          'Visibility': value["Visibility"],
        });
        await fetchSemesterData(value["Semester"], Students.length - 1);
        dataFetched = true;
      }
    });
    setState(() {});
    return Students;
  }

  @override
  void initState() {
    super.initState();
    getStudentData();
  }

  @override
  Widget build(BuildContext context) {
    getSemesterData();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Requests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xfff2f6f7),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: FutureBuilder<List<Map>>(
            future: getStudentData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                if (Students.isNotEmpty && semesterMap.isNotEmpty) {
                  return ListView.builder(
                    itemCount: Students.length,
                    itemBuilder: (context, index) {
                      data2 = Students[index];
                      data = semesterMap[index]!;
                      return Card(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Student Name: ${data2['FirstName']}  ${data2['LastName']}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    "Student Email address: ${data2["Email"]}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    "Semester: ${data['Semester']}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    "Contact number: ${data2['ContactNumber']}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  DropdownButton<String>(
                                    value: selectedPackage,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    style: const TextStyle(color: Colors.black),
                                    items: displayPackageMap
                                        .where((package) =>
                                            package["Visibility"] == "true")
                                        .map<DropdownMenuItem<String>>(
                                      (Map<String, dynamic> package) {
                                        return DropdownMenuItem<String>(
                                          value: package["key"],
                                          child: Text(package["PackageName"],
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedPackage = newValue;
                                        if (selectedPackage !=
                                            "Select Package") {
                                          visible = true;
                                        } else {
                                          visible = false;
                                        }
                                      });
                                    },
                                    hint: const Text(
                                      "Select a package",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 1,
                                      color:
                                          Colors.grey, // Color of the underline
                                    ),
                                    itemHeight:
                                        MediaQuery.of(context).size.width *
                                            0.15,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Visibility(
                                          visible: visible,
                                          child: TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Confirm Student Registration"),
                                                    content: Text(
                                                        "Are you sure you want to confirm the registration of ${data2['FirstName']} ${data2["LastName"]}."),
                                                    actions: <Widget>[
                                                      OutlinedButton(
                                                        child:
                                                            const Text('Yes'),
                                                        onPressed: () async {
                                                          bool theory = false,
                                                              practical = false,
                                                              papers = false;
                                                          switch (
                                                              selectedPackage) {
                                                            case "1":
                                                              theory = true;
                                                              break;
                                                            case "2":
                                                              practical = true;
                                                              break;
                                                            case "3":
                                                              papers = true;
                                                              break;
                                                            case "4":
                                                              theory = true;
                                                              practical = true;
                                                              break;
                                                            case "5":
                                                              theory = true;
                                                              practical = true;
                                                              papers = true;
                                                          }
                                                          final updatedData = {
                                                            "Visibility": true,
                                                            "Theory": theory,
                                                            "Practical":
                                                                practical,
                                                            "Papers": papers
                                                          };
                                                          final userRef = FirebaseDatabase
                                                                  .instance
                                                                  .ref()
                                                                  .child("ProgrammerProdigies/tblStudent")
                                                                  .child(data2["Key"]);
                                                          await userRef.update(updatedData);
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
                                                  const Color(0xff2a446b),
                                            ),
                                            child: const Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: 5,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/Animation/no_data_found.json',
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.3,
                          // repeat: false,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending students requests found',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          //
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AdminAddNewStudent(displaySemesterMap)));
        },
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New student.",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
