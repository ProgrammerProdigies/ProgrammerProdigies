// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:programmerprodigies/Student/payment_page.dart';
import 'package:pretty_animated_buttons/widgets/pretty_capsule_button.dart';

class StudentBuyPackage extends StatefulWidget {
  final String studentSemester;
  final String semesterName;

  const StudentBuyPackage(this.studentSemester, this.semesterName, {super.key});

  @override
  State<StudentBuyPackage> createState() => _StudentBuyPackageState();
}

class _StudentBuyPackageState extends State<StudentBuyPackage> {
  // Data structure to store categories and their subjects
  Map<String, List<String>> data = {};
  int total = 0;

  // Tracks the switch state for each group
  Map<String, bool> switchState = {};

  // Tracks prices for each group
  Map<String, int> groupPrices = {};

  late Future<void> _fetchDataFuture; // Single future to cache results

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData(); // Fetch all data at once
  }

  Map<String, List<String>> getSelectedData() {
    Map<String, List<String>> selectedData = {};

    switchState.forEach((group, isSelected) {
      if (isSelected) {
        // For 'TheoryAndPractical', combine Theory and Practical subjects
        if (group == "TheoryAndPractical") {
          selectedData['Theory'] = data['Theory'] ?? [];
          selectedData['Practical'] = data['Practical'] ?? [];
        }
        // For 'All', include everything
        else if (group == "All") {
          selectedData['Theory'] = data['Theory'] ?? [];
          selectedData['Practical'] = data['Practical'] ?? [];
          selectedData['Papers'] = data['Papers'] ?? [];
        }
        // Add the selected group and its subjects
        else {
          selectedData[group] = data[group] ?? [];
        }
      }
    });

    return selectedData;
  }


  Future<void> getPrices() async {
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child("ProgrammerProdigies/tblSemester/${widget.studentSemester}");

    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;

      if (values != null) {
        setState(() {
          groupPrices['Theory'] = values['TheoryPrice'] ?? 0;
          groupPrices['Practical'] = values['PracticalPrice'] ?? 0;
          groupPrices['TheoryAndPractical'] =
              values['TheoryAndPracticalPrice'] ?? 0;
          groupPrices['Papers'] = values['PapersPrice'] ?? 0;
          groupPrices['All'] = values['AllPrice'] ?? 0;
        });
      }
    });
  }

  Future<Map<String, List<String>>> getSubjectData() async {
    Query dbRef =
        FirebaseDatabase.instance.ref().child("ProgrammerProdigies/tblSubject");

    await dbRef
        .orderByChild("Semester")
        .equalTo(widget.studentSemester)
        .once()
        .then((event) async {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;

      if (values != null) {
        Map<String, List<String>> tempData = {};

        List<String> theoryAndPracticalSubjects = [];
        List<String> allSubjects = [];

        values.forEach((key, value) {
          String category = value['Category'];
          String subjectName = value['SubjectName'];
          String visibility = value['Visibility'];

          if (visibility == "true" && category != "Demo") {
            if (!tempData.containsKey(category)) {
              tempData[category] = [];
            }
            tempData[category]?.add(subjectName);

            if (category == "Theory" || category == "Practical") {
              theoryAndPracticalSubjects.add(subjectName);
            }

            allSubjects.add(subjectName);
          }
        });

        tempData["TheoryAndPractical"] = theoryAndPracticalSubjects;
        tempData["All"] = allSubjects;

        setState(() {
          data = tempData;

          for (var key in data.keys) {
            switchState[key] = false;
            groupPrices[key] = 0;
          }
        });

        await getPrices();
      }
    });

    return data;
  }

  Future<void> fetchData() async {
    getSubjectData();
    getPrices();
  }

  void handleSwitchChange(String group, bool value) {
    setState(() {
      // Handle Theory and Practical logic
      if (group == "TheoryAndPractical" && value) {
        switchState["Theory"] = false;
        switchState["Practical"] = false;
        // switchState["Papers"] = false;
        switchState["All"] = false;
      }

      if (group == "Papers" && value) {
        switchState["All"] = false;
      }

      // Handle All package logic
      if (group == "All" && value) {
        switchState["Theory"] = false;
        switchState["Practical"] = false;
        switchState["Papers"] = false;
        switchState["TheoryAndPractical"] = false;
      }

      // Handle individual category switches
      if ((group == "Theory" || group == "Practical") && value) {
        switchState["TheoryAndPractical"] = false;
        switchState["All"] = false;
      }

      // Toggle the switch state for the selected group
      switchState[group] = value;

      // Update total price
      total = 0;
      switchState.forEach((key, isSelected) {
        if (isSelected) {
          total += groupPrices[key] ?? 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buy package',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _fetchDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (data.isNotEmpty && groupPrices.isNotEmpty) {
                    return ListView.builder(
                      itemCount: data.keys.length,
                      itemBuilder: (context, groupIndex) {
                        String group = data.keys.elementAt(groupIndex);
                        List<String> items = data[group]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                "$group - ₹${groupPrices[group] ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              trailing: Switch(
                                value: switchState[group] ?? false,
                                onChanged: (value) {
                                  handleSwitchChange(group, value);
                                },
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: switchState[group] ?? false
                                  ? Column(
                                      children: items.map((item) {
                                        return ListTile(
                                          title: Text(item),
                                          leading: const Icon(Icons.subject),
                                        );
                                      }).toList(),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrettyCapsuleButton(
              label: '  Total Payable ₹$total'.toUpperCase(),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
              bgColor: Colors.teal,
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

                  // Collect selected data
                  Map<String, List<String>> selectedData = getSelectedData();

                  if (selectedData.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentPaymentPage(
                          total,
                          selectedData, // Pass the selected data here
                        ),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please select any package.",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      timeInSecForIosWeb: 2,
                      fontSize: 16,
                    );
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}

// List<String> selectedGroups = [];
// switchState.forEach(
// (key, value) {
// if (value) {
// if ("TheoryAndPractical" == key) {
// selectedGroups.add("Theory");
// selectedGroups.add("Practical");
// } else if ("All" == key) {
// selectedGroups.add("Theory");
// selectedGroups.add("Practical");
// selectedGroups.add("Papers");
// } else {
// selectedGroups.add(key);
// }
// }
// },
// );
//
// if (selectedGroups.isNotEmpty) {
// Navigator.pop(context);
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) =>
// StudentPaymentPage(total, selectedGroups),
// ),
// );
// return true;
// } else {
// Fluttertoast.showToast(
// msg: "Please select any package.",
// toastLength: Toast.LENGTH_LONG,
// gravity: ToastGravity.CENTER,
// backgroundColor: Colors.red,
// textColor: Colors.white,
// timeInSecForIosWeb: 2,
// fontSize: 16,
// );
// return false;
// }
// SliderButton(
// action: () async {
// return false;
// },
// label: Text(
// "Slide to Pay ₹$total",
// style: const TextStyle(
// color: Colors.white,
// fontWeight: FontWeight.w500,
// fontSize: 17),
// ),
// icon: const Icon(
// Icons.arrow_forward_ios,
// color: Colors.white,
// ),
// buttonColor: const Color(0xff2a446b),
// )
