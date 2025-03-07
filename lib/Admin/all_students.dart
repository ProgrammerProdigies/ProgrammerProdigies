import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdminAllStudents extends StatefulWidget {
  const AdminAllStudents({super.key});

  @override
  State<AdminAllStudents> createState() => _AdminAllStudentsState();
}

class _AdminAllStudentsState extends State<AdminAllStudents> {
  List<Map> student = [];
  List<Map> filteredStudents = []; // New list for filtered data
  bool dataFetched = false; // Flag to track if data has been fetched
  TextEditingController searchController = TextEditingController();
  String searchValue = '';

  Future<List<Map>> getStudentData() async {
    if (dataFetched) {
      return student;
    }

    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('programmerProdigies/tblStudent');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    values.forEach((key, value) async {
      bool visible = value["Visibility"] as bool;

      if (visible) {
        String semester = await fetchSemesterData(value["Semester"].toString());

        student.add({
          'Key': key,
          'FirstName': value["FirstName"],
          'LastName': value["LastName"],
          'Email': value["Email"],
          'ContactNumber': value["ContactNumber"],
          'Gender': value["Gender"],
          'Semester': value["Semester"],
          'SemesterName': semester,
          'FCMToken': value["FCMToken"],
          'Visibility': value["Visibility"],
          'isSwitchOn': value["Visibility"], // Independent switch state
        });
      }

      filteredStudents = List.from(student);
      dataFetched = true;

      setState(() {}); // Refresh UI
    });

    return filteredStudents;
  }

  void filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = List.from(student);
      } else {
        filteredStudents = student
            .where((s) => (s['Email'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<String> fetchSemesterData(String semesterKey) async {
    DatabaseReference dbSemesterRef = FirebaseDatabase.instance
        .ref()
        .child("programmerprodigies/tblSemester")
        .child(semesterKey);

    DatabaseEvent semesterDataEvent = await dbSemesterRef.once();
    DataSnapshot semesterDataSnapshot = semesterDataEvent.snapshot;

    Map<dynamic, dynamic>? semesterData = semesterDataSnapshot.value as Map?;
    return semesterData!["Semester"];
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
              height: MediaQuery.of(context).size.height * 0.69,
              color: const Color(0xfff2f6f7),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: FutureBuilder<List<Map>>(
                  future: getStudentData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      if (student.isNotEmpty) {
                        return ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            var studentData = filteredStudents[index];
                            return Card(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Student Name: ${studentData['FirstName']} ${studentData['LastName']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Student Email: ${studentData["Email"]}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Semester: ${studentData['SemesterName']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          "Contact: ${studentData['ContactNumber']}",
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 5,
                                    child: Switch(
                                      value: studentData['isSwitchOn'],
                                      onChanged: (bool value) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Alert"),
                                              content: Text(
                                                  "By doing this ${studentData['FirstName']} ${studentData['LastName']} will not be able to access any documents.\nAre you sure you want to restrict ${studentData['FirstName']} ${studentData['LastName']} ?"),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    updateStudent(
                                                        studentData["Key"]);
                                                    setState(() {
                                                      studentData[
                                                              'isSwitchOn'] =
                                                          value; // Toggle switch state
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Yes"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("No"),
                                                ),
                                              ],
                                            );
                                          },
                                          barrierDismissible: false
                                        );
                                      },
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
    );
  }

  Future<void> updateStudent(String key) async {
    bool theory = false, practical = false, papers = false;
    final updatedData = {
      "Visibility": false,
      "Theory": theory,
      "Practical": practical,
      "Papers": papers,
      "Demo": true
    };
    final userRef = FirebaseDatabase.instance
        .ref()
        .child("programmerprodigies/tblStudent")
        .child(key);
    await userRef.update(updatedData);
  }
}
