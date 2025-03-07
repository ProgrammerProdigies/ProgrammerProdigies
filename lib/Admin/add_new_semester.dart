import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/bottom_nav_bar.dart';
import 'package:programmerprodigies/Models/semester_model.dart';

class AdminAddNewSemester extends StatefulWidget {
  const AdminAddNewSemester({super.key});

  @override
  State<AdminAddNewSemester> createState() => _AdminAddNewSemesterState();
}

class _AdminAddNewSemesterState extends State<AdminAddNewSemester> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController semesterController = TextEditingController();
  TextEditingController theoryController = TextEditingController();
  TextEditingController practicalController = TextEditingController();
  TextEditingController papersController = TextEditingController();
  TextEditingController theoryAndPracticalController = TextEditingController();
  TextEditingController allController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new semester"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
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
                  TextFormField(
                    controller: semesterController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter semester name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIconColor: Color(0xff2a446b),
                      labelText: 'Enter Semester',
                      hintText: 'Enter Semester',
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
                            child: const Text("Theory price"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.59,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter semester name';
                                }
                                return null;
                              },
                              controller: theoryController,
                              decoration: const InputDecoration(
                                hintText: "Price for theory subjects",
                                labelText: "Price for theory subjects",
                              ),
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
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter semester name';
                                }
                                return null;
                              },
                              controller: practicalController,
                              decoration: const InputDecoration(
                                hintText: "Price for practical subjects",
                                labelText: "Price for practical subjects",
                              ),
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
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter semester name';
                                }
                                return null;
                              },
                              controller: papersController,
                              decoration: const InputDecoration(
                                hintText: "Price for papers",
                                labelText: "Price for papers",
                              ),
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
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter semester name';
                                }
                                return null;
                              },
                              controller: theoryAndPracticalController,
                              decoration: const InputDecoration(
                                hintText: "Price for Theory and Practical",
                                labelText: "Price for Theory and Practical",
                              ),
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
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter semester name';
                                }
                                return null;
                              },
                              controller: allController,
                              decoration: const InputDecoration(
                                hintText: "All three",
                                labelText: "All three",
                              ),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addSemester(
                          semester: semesterController.text,
                          theoryPrice: int.parse(theoryController.text),
                          practicalPrice: int.parse(practicalController.text),
                          papersPrice: int.parse(papersController.text),
                          theoryAndPracticalPrice:
                              int.parse(theoryAndPracticalController.text),
                          allPrice: int.parse(allController.text),
                        );
                      }
                    },
                    child: const Text("Add semester"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addSemester(
      {required String semester,
      required int theoryPrice,
      required int practicalPrice,
      required int papersPrice,
      required int theoryAndPracticalPrice,
      required int allPrice}) {
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('programmerProdigies/tblSemester');
    SemesterModel regobj = SemesterModel(semester, theoryPrice, practicalPrice,
        papersPrice, theoryAndPracticalPrice, allPrice, "true");
    dbRef.push().set(regobj.toJson());
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const BottomBar(0)));
  }
}
