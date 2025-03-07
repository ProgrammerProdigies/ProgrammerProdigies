// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../saveSharePreferences.dart';
import 'buy_package.dart';
import 'chapters_page.dart';
import 'profile_page.dart';

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
  bool isLoading = true;

  late String studentSemester;
  bool theory = false;
  bool practical = false;
  bool papers = false;
  bool demo = false;
  var firstName = "";
  var lastname = "";
  var semesterName = "";
  var requestFor = "";

  String viewMode = "Normal";
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');

  Future<void> initializeData() async {
    studentSemester = (await getData("Semester"))!;
    var Demo = (await getData("Demo"))!;
    var Theory = (await getData("Theory"))!;
    var Practical = (await getData("Practical"))!;
    var Papers = (await getData("Papers"))!;
    firstName = (await getData("FirstName"))!;
    lastname = (await getData("LastName"))!;
    semesterName = (await getData("SemesterName"))!;
    var studentKey = (await getKey())!;

    DatabaseReference dbStudentRef = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblStudent/$studentKey');

    await dbStudentRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        requestFor = values["RequestFor"] ?? "";
      }
    });

    demo = Demo == "true";
    theory = Theory == "true";
    practical = Practical == "true";
    papers = Papers == "true";

    await getPackagesData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<List<Map>> getPackagesData() async {
    finalSubjects.clear();
    packageSubjects.clear();

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
    if (category == "Demo") {
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
        if(requestFor.isEmpty){
          // User is not subscribed, show the alert dialog once
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Premium Feature"),
                content: const Text("Please buy package"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    autofocus: true,
                    onPressed: () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const Center(child: CircularProgressIndicator());
                        },
                      );

                      // Wait for 2 seconds
                      await Future.delayed(const Duration(seconds: 1));

                      // Dismiss loading dialog
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentBuyPackage(studentSemester, semesterName),
                        ),
                      );
                    },
                    child: const Text('Buy package'),
                  ),
                ],
              );
            },
          );
        } else {
          // User is not subscribed, show the alert dialog once
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Premium Feature"),
                content: const Text("You already have selected the package. Please wait for a while our team will give you access soon.\n\nFeel free to contact us using the contact button below"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                  TextButton(
                    autofocus: true,
                    onPressed: () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const Center(child: CircularProgressIndicator());
                        },
                      );

                      // Wait for 2 seconds
                      await Future.delayed(const Duration(seconds: 1));

                      await launchWhatsApp();

                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Contact us'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: Stack(
        children: [
          // Main content with subjects
          Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Map>>(
                  future: getPackagesData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      if (finalSubjects.isNotEmpty) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Image.asset(
                                            "assets/Logo/Programmer.png",
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      finalSubjects[index]
                                                          ["Subject"],
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    child: Text(
                                                      finalSubjects[index]
                                                          ["Category"],
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
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Visibility(
                                          visible: demo &&
                                              (finalSubjects[index]
                                                          ["Category"] ==
                                                      "Practical" ||
                                                  finalSubjects[index]
                                                          ["Category"] ==
                                                      "Papers" ||
                                                  finalSubjects[index]
                                                          ["Category"] ==
                                                      "Theory"),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: Icon(
                                              Icons.star,
                                              color: Colors.yellow[700],
                                              size: 20,
                                            ),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
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
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: requestFor.isEmpty
          ? FloatingActionButton(
               tooltip: "Buy Package",
              onPressed: () async {
                buyPackage(context);
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.shopping_bag,
                color: Color(0xff2a446b),
              ),
            )
          : null,
    );
  }

  Future<void> buyPackage(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 1));

    // Dismiss loading dialog
    Navigator.of(context).pop();

    // Navigate to the next page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentBuyPackage(studentSemester, semesterName),
      ),
    );
  }
  Future<void> launchWhatsApp() async {
    String url;
    if (Platform.isIOS) {
      url =
      'https://wa.me/+918849165682?text=${Uri.encodeFull("Hello, My name is *$firstName $lastname*, I need some assistance.")}';
    } else {
      url =
      'whatsapp://send?phone=+918849165682&text=${Uri.encodeFull("Hello, My name is *$firstName $lastname*, I need some assistance.")}';
    }
    await launchUrl(Uri.parse(url));
  }
}
