import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/chapters_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Map> subjects = [
    {"key": "1","semester":"1", "subject": "OS"},
    {"key": "2","semester":"2", "subject": "CPPM"},
    {"key": "3","semester":"3", "subject": ".Net"},
    {"key": "4","semester":"4", "subject": "WDC"},
    {"key": "5","semester":"5", "subject": "Java"},
    {"key": "6","semester":"6", "subject": "Networking"},
  ];

  String viewMode = "Normal";

  Future<List<Map>> getPackagesData() async {
    return subjects;
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
          builder: (context) => AdminChaptersPage(subjects[index]["key"]),
        ),
      );
    } else if (viewMode == "Edit") {
      // Create a TextEditingController to manage the input
      TextEditingController nameController =
          TextEditingController(text: subjects[index]["subject"]);

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
                    subjects[index]["subject"] =
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
    final icon = viewMode == "Normal"
        ? FontAwesomeIcons.userPen
        : FontAwesomeIcons.check;

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
            if (subjects.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => handleCardTap(context, index),
                    onLongPress: () {
                      if(viewMode == "Edit") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Chapter...!!'),
                              content: Text(
                                  "Are you sure you want to delete ${subjects[index]["subject"]}?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      subjects.removeWhere(
                                            (ch) => ch["key"] == subjects[index]["key"],
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
                              title: const Text('Delete Subject...!!'),
                              content: const Text("You are not in edit mode. Please start edit mode from top right side."),
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
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        "Semester: ${subjects[index]["semester"]}",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        subjects[index]["subject"],
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
