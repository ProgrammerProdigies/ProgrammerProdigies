import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/add_new_subject.dart';
import 'package:programmer_prodigies/Admin/chapters_page.dart';

class AdminSubjectPage extends StatefulWidget {
  final String semester;

  const AdminSubjectPage(this.semester, {super.key});

  @override
  State<AdminSubjectPage> createState() => _AdminSubjectPageState();
}

class _AdminSubjectPageState extends State<AdminSubjectPage> {
  List<Map> subjects = [];

  List<Map> semester = [];
  late List<Map> filteredSubjects;

  String viewMode = "Normal";
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');

  Future<List<Map>> getPackagesData() async {
    subjects.clear();
    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        values.forEach((key, value) {
          subjects.add({
            "key": key,
            "Semester": value["Semester"],
            "Subject": value["SubjectName"],
            "Category": value["Category"],
            "Visibility": value["Visibility"],
          });
        });
        // subjects.sort((a, b) => a["Semester"].compareTo(b["Semester"]));
      }
    });
    setState(() {});
    return subjects;
  }

  void handleCardTap(BuildContext context, int index) {
    if (viewMode == "Normal") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AdminChaptersPage(filteredSubjects[index]["key"]),
        ),
      );
    }
  }

  void toggleViewMode() {
    setState(() {
      viewMode = viewMode == "Normal" ? "Edit" : "Normal";
    });
  }

  void handleDoubleTap(BuildContext context, int index) {
    if (viewMode == "Edit") {
      if (filteredSubjects[index]["Visibility"] == false) {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Un-Restrict subject'),
              content: const Text(
                  "Are you sure you want to Un-Restrict this subject..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  // Close the dialog
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedData = {"Visibility": "true"};
                    final userRef = FirebaseDatabase.instance
                        .ref()
                        .child("ProgrammerProdigies/tblSubject")
                        .child(filteredSubjects[index]["key"]);
                    await userRef.update(updatedData);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (filteredSubjects[index]["Visibility"] == true) {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Restrict semester'),
              content: const Text(
                  "Are you sure you want to Restrict this semester..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  // Close the dialog
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedData = {"Visibility": "false"};
                    final userRef = FirebaseDatabase.instance
                        .ref()
                        .child("ProgrammerProdigies/tblSubject")
                        .child(filteredSubjects[index]["key"]);
                    await userRef.update(updatedData);
                    // semester[index]["Visibility"] = "false";
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {});
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      }
    } else if (viewMode == "Normal") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Restrict subject...!!'),
            content: const Text(
                "You are not in edit mode. Please start edit mode from top right side."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  void handleLongPress(BuildContext context, int index) {
    if (viewMode == "Edit") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Subject...!!'),
            content: Text(
                "Are you sure you want to delete ${filteredSubjects[index]["Subject"]}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseDatabase.instance
                      .ref()
                      .child(
                          "ProgrammerProdigies/tblSubject/${filteredSubjects[index]["key"]}")
                      .remove();
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Subject...!!'),
            content: const Text(
                "You are not in edit mode. Please start edit mode from the top right side."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = viewMode == "Normal"
        ? FontAwesomeIcons.userPen
        : FontAwesomeIcons.check;

    // Filter chapters based on the subjectKey
    filteredSubjects = subjects
        .where((subject) => subject["Semester"] == widget.semester)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Admin Subjects page",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: toggleViewMode,
            icon: FaIcon(icon),
          ),
        ],
      ),
      body: FutureBuilder<List<Map>>(
        future: getPackagesData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (filteredSubjects.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => handleCardTap(context, index),
                    onDoubleTap: () => handleDoubleTap(context, index),
                    onLongPress: () => handleLongPress(context, index),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: const Color(0xff2a446b),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/Logo/Programmer.png",
                                  width: MediaQuery.of(context).size.width * 0.29,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SizedBox(
                                    height:
                                    MediaQuery.of(context).size.width * 0.15,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Text(
                                            filteredSubjects[index]["Subject"],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Text(
                                            filteredSubjects[index]["Category"],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (filteredSubjects[index]["Visibility"] == "false")
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Restricted",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No subjects found',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminAddNewSubject(widget.semester)));
        },
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New subject.",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
