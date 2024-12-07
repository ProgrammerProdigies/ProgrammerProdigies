// ignore_for_file: non_constant_identifier_names
import 'dart:io';


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:programmerprodigies/Student/chapters_page.dart';
import 'package:programmerprodigies/Student/profile_page.dart';
import 'package:programmerprodigies/saveSharePreferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var firstName = "";
  var lastname = "";
  var amount = 0;
  var semesterName = "";

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
    firstName = (await getData("FirstName"))!;
    lastname = (await getData("LastName"))!;
    semesterName = (await getData("SemesterName"))!;

    if(semesterName == "Semester 1"){
      amount = 149;
    }
    if(semesterName == "Semester 3"){
      amount = 199;
    }
    if(semesterName == "GSET"){
      amount = 999;
    }
    if(semesterName == "NEET"){
      amount = 999;
    }

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
        // User is not subscribed, show the alert dialog once
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Premium Feature"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Currently you have not subscribed for this package.\nPlease pay $amount/- on below QR code and send us the screen shot on 8849165682 whatsapp.",
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                    Image.asset(
                      "assets/QR/QR.jpg",
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                    const Text("You can find the number in contact page as well.")
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    launchWhatsApp();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Send message'),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  "assets/Logo/Programmer.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
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
                            Positioned(
                              top: 8, // Distance from the top of the card
                              right: 8, // Distance from the right of the card
                              child: Visibility(
                                visible: demo &&
                                    (finalSubjects[index]
                                                ["Category"] ==
                                            "Practical" ||
                                        finalSubjects[index]["Category"] ==
                                            "Papers" ||
                                        finalSubjects[index]["Category"] ==
                                            "Theory"),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
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

  Future<void> launchWhatsApp() async {
    String url;
    if (Platform.isIOS) {
      url = 'https://wa.me/+918849165682?text=${Uri.encodeFull("Hello,My name is $firstName $lastname\nI have paid $amount/- for $semesterName here is the screenshot.")}';
    } else {
      url = 'whatsapp://send?phone=+918849165682&text=${Uri.encodeFull("Hello,My name is $firstName $lastname\nI have paid $amount/- for $semesterName here is the screenshot.")}';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // If unable to launch email, copy the email address to clipboard
      await Clipboard.setData(const ClipboardData(text: '+91 8849165682'));
      // Show a snackbar to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number copied you can save the number and do message on that number.'),
          ),
        );
      }
      throw 'Could not launch $url';
    }
  }
}
