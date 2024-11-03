import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Student/chapters_page.dart';
import 'package:programmer_prodigies/Student/profile_page.dart';
import 'package:programmer_prodigies/saveSharePreferences.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Map> subjects = [];

  List<Map> semester = [];
  List<Map> filteredSubjects = [];
  var filteredTheorySubjects = [];
  var filteredPracticalSubjects = [];
  var filteredPapersSubjects = [];
  List<Map> finalSubjects = [];

  late String studentSemester;
  late bool theory;
  late bool practical;
  late bool papers;

  String viewMode = "Normal";
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');


  Future<List<Map>> getPackagesData() async {
    finalSubjects.clear();
    studentSemester = (await getData("Semester"))!;
    var Theory = (await getData("Theory"))!;
    var Practical = (await getData("Practical"))!;
    var Papers = (await getData("Papers"))!;
    var key = await getKey();

    if(Theory == "true"){
      theory = true;
    } else {
      theory = false;
    }
    if(Practical == "true"){
      practical = true;
    } else {
      practical = false;
    }
    if(Papers == "true"){
      papers = true;
    } else {
      papers = false;
    }
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
          });
        });
      }
    });

    // First filter by semester
    filteredSubjects = subjects
        .where((subject) => subject["Semester"] == studentSemester)
        .toList();

    // Second filter by Category Theory
    filteredTheorySubjects = filteredSubjects
        .where((subject) => subject["Category"] == "Theory")
        .toList();
    print(theory);
    if(theory){
      finalSubjects = [
        ...filteredTheorySubjects
      ];
    }

    filteredPracticalSubjects = filteredSubjects
        .where((subject) => subject["Category"] == "Practical")
        .toList();

    if(practical){
      // Second filter by Category Practical
      finalSubjects = [
        ...filteredPracticalSubjects,
      ];
      print("filteredPracticalSubjects $filteredPracticalSubjects");
    }

    // Second filter by Category papers
    filteredPapersSubjects = filteredSubjects
        .where((subject) => subject["Category"] == "Papers")
        .toList();
    print(papers);
    if(papers){
      finalSubjects = [
        ...filteredPapersSubjects,
      ];
      print("filteredPapersSubjects $filteredPapersSubjects");
    }

    print("finalSubjects ${finalSubjects}");

    return finalSubjects;
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
          builder: (context) =>
              StudentChaptersPage(filteredSubjects[index]["key"]),
        ),
      );
    } else if (viewMode == "Edit") {
      // Create a TextEditingController to manage the input
      TextEditingController nameController =
          TextEditingController(text: filteredSubjects[index]["Subject"]);

      // Show an AlertDialog for editing the subject name
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Subject Name'),
            content: TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(hintText: 'Enter new subject name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                // Close the dialog
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Update the subject name
                  setState(() {
                    filteredSubjects[index]["subject"] =
                        nameController.text; // Update the name in the list
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Student Subjects page",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.person), // Profile icon
          ),
        ],
      ),
      body: FutureBuilder<List<Map>>(
        future: getPackagesData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (finalSubjects.isNotEmpty) {
              //work here
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: finalSubjects.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => handleCardTap(context, index),
                    onLongPress: () {
                      if (viewMode == "Edit") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Subject...!!'),
                              content: Text(
                                  "Are you sure you want to delete ${filteredSubjects[index]["subject"]} subject?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      filteredSubjects.removeWhere(
                                            (ch) =>
                                        ch["key"] ==
                                            filteredSubjects[index]["key"],
                                      );
                                    });
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
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
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
                              padding: const EdgeInsets.all(0),
                              child: SizedBox(
                                height:
                                MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        finalSubjects[index]["Subject"],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        finalSubjects[index]["Category"],
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
    );
  }
}
