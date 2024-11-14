// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmerprodigies/Admin/subject_page.dart';
import 'package:programmerprodigies/Models/sem_model.dart';

class AdminSemesterPage extends StatefulWidget {
  const AdminSemesterPage({super.key});

  @override
  State<AdminSemesterPage> createState() => _AdminSemesterPageState();
}

class _AdminSemesterPageState extends State<AdminSemesterPage> {
  List<Map> semester = [];
  Future<List<Map>>? semesterFuture;

  var dbRef =
      FirebaseDatabase.instance.ref().child("ProgrammerProdigies/tblSemester");

  String viewMode = "Normal";

  Future<List<Map>> getSemesterData() async {
    semester.clear();
    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        values.forEach((key, value) {
          semester.add({
            "key": key,
            "Semester": value["Semester"],
            "Visibility": value["Visibility"],
          });
        });
        semester.sort((a, b) => a["Semester"].compareTo(b["Semester"]));
      }
    });
    return semester;
  }

  void toggleViewMode() {
    setState(() {
      viewMode = viewMode == "Normal" ? "Edit" : "Normal";
    });
  }

  void handleCardTap(BuildContext context, int index) {
    if (viewMode == "Normal") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminSubjectPage(semester[index]["key"]),
        ),
      );
    }
    // else if (viewMode == "Edit") {
    //   // Create a TextEditingController to manage the input
    //   TextEditingController nameController =
    //       TextEditingController(text: semester[index]["semester"]);
    //
    //   // Show an AlertDialog for editing the subject name
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Edit Semester Name'),
    //         content: TextField(
    //           controller: nameController,
    //           decoration:
    //               const InputDecoration(hintText: 'Enter new semester name'),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(),
    //             // Close the dialog
    //             child: const Text('Cancel'),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               // Update the subject name
    //               setState(() {
    //                 semester[index]["semester"] =
    //                     nameController.text; // Update the name in the list
    //               });
    //               Navigator.of(context).pop(); // Close the dialog
    //             },
    //             child: const Text('Save'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  handleDoubleClick(BuildContext context, int index) {
    if (viewMode == "Edit") {
      if (semester[index]["Visibility"] == "false") {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Un-Restrict semester'),
              content: const Text(
                  "Are you sure you want to Un-Restrict this semester..?"),
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
                        .child("ProgrammerProdigies/tblSemester")
                        .child(semester[index]["key"]);
                    await userRef.update(updatedData);
                    Navigator.of(context).pop();
                    setState(() {
                    });
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (semester[index]["Visibility"] == "true") {
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
                        .child("ProgrammerProdigies/tblSemester")
                        .child(semester[index]["key"]);
                    await userRef.update(updatedData);
                    // semester[index]["Visibility"] = "false";
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                    });
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
            title: const Text('Restrict Semester...!!'),
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

  @override
  Widget build(BuildContext context) {
    final icon = viewMode == "Normal"
        ? FontAwesomeIcons.userPen
        : FontAwesomeIcons.check;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Admin Semester page",
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
        future: getSemesterData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (semester.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: semester.length,
                  itemBuilder: (context, index) {
                    final chapter = semester[index];
                    return InkWell(
                      onTap: () => handleCardTap(context, index),
                      // onLongPress: () {
                      //   if (viewMode == "Edit") {
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text('Delete Semester...!!'),
                      //           content: Text(
                      //               "Are you sure you want to delete ${chapter["Semester"]}?"),
                      //           actions: [
                      //             TextButton(
                      //               onPressed: () =>
                      //                   Navigator.of(context).pop(),
                      //               child: const Text('Cancel'),
                      //             ),
                      //             TextButton(
                      //               onPressed: () {
                      //                 setState(() {
                      //                   semester.removeWhere(
                      //                     (ch) =>
                      //                         ch["key"] ==
                      //                         semester[index]["key"],
                      //                   );
                      //                 });
                      //                 Navigator.of(context).pop();
                      //               },
                      //               child: const Text('Yes'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   } else {
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text('Edit Subject...!!'),
                      //           content: const Text(
                      //               "You are not in edit mode. Please start edit mode from top right side."),
                      //           actions: [
                      //             TextButton(
                      //               onPressed: () {
                      //                 Navigator.of(context).pop();
                      //               },
                      //               child: const Text('Ok'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   }
                      // },
                      onDoubleTap: () {
                        handleDoubleClick(context, index);
                        setState(() {
                        });
                      },
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff2a446b),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/Logo/Programmer.png",
                                    width: MediaQuery.of(context).size.width *
                                        0.27,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  "Semester: ${semester[index]["Semester"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (chapter["Visibility"] == "false")
                            // Overlay for restricted access
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  // Dark overlay
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
                    );
                  },
                ),
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
                      'No Semesters found',
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
          TextEditingController semesterController = TextEditingController();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add Semester'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: semesterController,
                          decoration:
                              const InputDecoration(hintText: 'Add Semester'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          var semesterName = semesterController.text;
                          SemesterModel sModel =
                              SemesterModel(semesterName, "false");
                          dbRef.push().set(sModel.toJson());
                          setState(() {
                            semesterFuture = getSemesterData();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New Chapter.",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
