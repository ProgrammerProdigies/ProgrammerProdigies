import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/add_new_student.dart';
import 'package:programmer_prodigies/Admin/bottom_nav_bar.dart';
import 'package:programmer_prodigies/sendMail.dart';

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

  List<String?> selectedPackages = []; // List to store selected package per student

  Future<void> fetchSemesterData(String key, int index) async {
    DatabaseReference dbUserData = FirebaseDatabase.instance
        .ref()
        .child("ProgrammerProdigies/tblSemester")
        .child(key);
    DatabaseEvent userDataEvent = await dbUserData.once();
    DataSnapshot userDataSnapshot = userDataEvent.snapshot;
    Map<dynamic, dynamic>? userData = userDataSnapshot.value as Map?;
    semesterMap[index] = {
      "Key": userDataSnapshot.key,
      "Semester": userData?["Semester"],
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
    if (dataFetched) return student;
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblStudent');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value == null) return student;

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    student.clear();
    selectedPackages.clear();
    values.forEach((key, value) async {
      if (value["Visibility"] == false) {
        student.add({
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
        selectedPackages
            .add("Select Package"); // Default selection for each student
        await fetchSemesterData(value["Semester"], student.length - 1);
      }
    });
    dataFetched = true;
    setState(() {});
    return student;
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
        title: const Text("Student Requests",
            style: TextStyle(color: Colors.white)),
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
                if (student.isNotEmpty && semesterMap.isNotEmpty) {
                  return ListView.builder(
                    itemCount: student.length,
                    itemBuilder: (context, index) {
                      var data2 = student[index];
                      var data = semesterMap[index] ?? {};
                      return Card(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Student Name: ${data2['FirstName']}  ${data2['LastName']}",
                                      style: const TextStyle(fontSize: 17)),
                                  Text("Student Email address: ${data2["Email"]}",
                                      style: const TextStyle(fontSize: 17)),
                                  Text("Semester: ${data['Semester']}",
                                      style: const TextStyle(fontSize: 17)),
                                  Text("Contact number: ${data2['ContactNumber']}",
                                      style: const TextStyle(fontSize: 17)),
                                  DropdownButton<String>(
                                    value: selectedPackages[index],
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
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
                                        selectedPackages[index] = newValue;
                                      });
                                    },
                                    isExpanded: true,
                                    underline:
                                    Container(height: 1, color: Colors.grey),
                                  ),
                                  if (selectedPackages[index] != "Select Package")
                                    TextButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Confirm Student Registration"),
                                              content: Text(
                                                  "Are you sure you want to confirm the registration of ${data2['FirstName']} ${data2["LastName"]}?"),
                                              actions: <Widget>[
                                                OutlinedButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () {
                                                    updateUser(data2["Key"], selectedPackages[index]!);
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
                                                    sendMail(data2);
                                                    getStudentData();
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: const Color(0xff2a446b)),
                                      child: const Text("Confirm",
                                          style: TextStyle(color: Colors.white)),
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
                        Lottie.asset('assets/Animation/no_data_found.json',
                            width: MediaQuery.of(context).size.width * 0.6),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> updateUser(String key, String selectedPackage) async {
    bool theory = false, practical = false, papers = false;
    switch (selectedPackage) {
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
      "Practical": practical,
      "Papers": papers
    };
    final userRef = FirebaseDatabase.instance
        .ref()
        .child("ProgrammerProdigies/tblStudent")
        .child(key);
    await userRef.update(updatedData);
  }
}
