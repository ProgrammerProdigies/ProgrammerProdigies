// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/bottom_nav_bar.dart';

class AdminSemesterUpdatePage extends StatefulWidget {
  final Map semester;

  const AdminSemesterUpdatePage(this.semester, {super.key});

  @override
  State<AdminSemesterUpdatePage> createState() =>
      _AdminSemesterUpdatePageState();
}

class _AdminSemesterUpdatePageState extends State<AdminSemesterUpdatePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController semesterController =
        TextEditingController(text: widget.semester["Semester"].toString());
    TextEditingController theoryController =
        TextEditingController(text: widget.semester["TheoryPrice"].toString());
    TextEditingController practicalController = TextEditingController(
        text: widget.semester["PracticalPrice"].toString());
    TextEditingController papersController =
        TextEditingController(text: widget.semester["PapersPrice"].toString());
    TextEditingController theoryAndPracticalController = TextEditingController(
        text: widget.semester["TheoryAndPracticalPrice"].toString());
    TextEditingController allController =
        TextEditingController(text: widget.semester["AllPrice"].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update semester"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: Colors.white,
        ),
        height: double.maxFinite,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    prefixIconColor: Color(0xff2a446b),
                    labelText: 'Enter Semester',
                    hintText: 'Enter Semester',
                  ),
                  enabled: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Text("Theory price"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: TextField(
                            controller: theoryController,
                            decoration: const InputDecoration(
                              hintText: "Price for theory subjects",
                              labelText: "Price for theory subjects",
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                widget.semester["TheoryPrice"] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Text("Practical price"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: TextField(
                            controller: practicalController,
                            decoration: const InputDecoration(
                              hintText: "Price for practical subjects",
                              labelText: "Price for practical subjects",
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                widget.semester["PracticalPrice"] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text("Papers price"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: TextField(
                            controller: papersController,
                            decoration: const InputDecoration(
                              hintText: "Price for papers",
                              labelText: "Price for papers",
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                widget.semester["PapersPrice"] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Text("Theory and Practical price"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: TextField(
                            controller: theoryAndPracticalController,
                            decoration: const InputDecoration(
                              hintText: "Price for Theory and Practical",
                              labelText: "Price for Theory and Practical",
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                widget.semester["TheoryAndPracticalPrice"] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: const Text("All three"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: TextField(
                            controller: allController,
                            decoration: const InputDecoration(
                              hintText: "All three",
                              labelText: "All three",
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                widget.semester["AllPrice"] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    var paperPrice = int.parse(papersController.text);
                    var practicalPrice = int.parse(practicalController.text);
                    var theoryPrice = int.parse(theoryController.text);
                    var theoryAndPracticalPrice =
                        int.parse(theoryAndPracticalController.text);
                    var allPrice = int.parse(allController.text);
                    await updateSemester(
                      semester: semesterController.text,
                      theoryPrice: theoryPrice,
                      practicalPrice: practicalPrice,
                      papersPrice: paperPrice,
                      theoryAndPracticalPrice: theoryAndPracticalPrice,
                      allPrice: allPrice,
                      semesterKey: widget.semester["key"].toString(),
                    );
                  },
                  child: const Text("Update semester"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateSemester(
      {required String semester,
      required int theoryPrice,
      required int practicalPrice,
      required int papersPrice,
      required int theoryAndPracticalPrice,
      required int allPrice,
      required String semesterKey}) async {
    final updatedData = {
      "PapersPrice": papersPrice,
      "TheoryPrice": theoryPrice,
      "TheoryAndPracticalPrice": theoryAndPracticalPrice,
      "PracticalPrice": practicalPrice,
      "AllPrice": allPrice,
    };
    final semesterRef = FirebaseDatabase.instance
        .ref()
        .child("programmerprodigies/tblSemester")
        .child(semesterKey);
    await semesterRef.update(updatedData);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomBar(0),
      ),
    );
  }
}
