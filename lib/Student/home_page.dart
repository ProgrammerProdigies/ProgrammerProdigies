// ignore_for_file: non_constant_identifier_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmerprodigies/Student/chapters_page.dart';
import 'package:programmerprodigies/Student/profile_page.dart';
import 'package:programmerprodigies/saveSharePreferences.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Map> subjects = [];
  List<Map> filteredSubjects = [];
  var filteredTheorySubjects = [];
  var filteredPracticalSubjects = [];
  var filteredPapersSubjects = [];
  List<Map> finalSubjects = [];
  List<Map> packageSubjects = [];

  late String studentSemester;
  bool theory = false;
  bool practical = false;
  bool papers = false;
  bool demo = false;

  String viewMode = "Normal";
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');

  Future<List<Map>> getPackagesData() async {
    finalSubjects.clear();
    packageSubjects.clear();
    studentSemester = (await getData("Semester"))!;
    var Demo = (await getData("Demo"))!;
    var Theory = (await getData("Theory"))!;
    var Practical = (await getData("Practical"))!;
    var Papers = (await getData("Papers"))!;

    demo = Demo == "true";
    theory = Theory == "true";
    practical = Practical == "true";
    papers = Papers == "true";

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
      }
    });

    // First filter by semester
    filteredSubjects = subjects
        .where((subject) => subject["Semester"] == studentSemester)
        .toList();

    if (demo) {
      packageSubjects.addAll(filteredSubjects);
    } else {
      packageSubjects.clear();
      // Filter subjects by each category and add to packageSubjects if the condition is true
      if (theory) {
        packageSubjects.addAll(filteredSubjects
            .where((subject) => subject["Category"] == "Theory")
            .toList());
      }

      if (practical) {
        packageSubjects.addAll(filteredSubjects
            .where((subject) => subject["Category"] == "Practical")
            .toList());
      }

      if (papers) {
        packageSubjects.addAll(filteredSubjects
            .where((subject) => subject["Category"] == "Papers")
            .toList());
      }
    }

    // Filter final subjects by visibility
    finalSubjects = packageSubjects
        .where((subject) => subject["Visibility"] == "true")
        .toList();

    // Custom sort: "Demo" category first, then by "Subject" name
    finalSubjects.sort((a, b) {
      if (a["Category"] == "Demo" && b["Category"] != "Demo") return -1;
      if (a["Category"] != "Demo" && b["Category"] == "Demo") return 1;
      return a["Subject"].compareTo(b["Subject"]);
    });

    return finalSubjects;
  }


  void handleCardTap(BuildContext context, int index) {
    String category = finalSubjects[index]["Category"];
    bool isSubscribed = (category == "Theory" && theory) ||
        (category == "Practical" && practical) ||
        (category == "Papers" && papers);
    if(category == "Demo"){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentChaptersPage(
            finalSubjects[index]["key"],
            finalSubjects[index]["Subject"],
            studentSemester,
          ),
        ),
      );
    }else{
      if (isSubscribed) {
        // User is subscribed for the selected category, proceed to the next page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentChaptersPage(
              finalSubjects[index]["key"],
              finalSubjects[index]["Subject"],
              studentSemester,
            ),
          ),
        );
      } else {
        // User is not subscribed, show the alert dialog once
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Premium Feature"),
              content: const Text(
                  "Currently you have not subscribed for this package. Please contact us for more details."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Subjects",
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
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.width * 0.2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
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
