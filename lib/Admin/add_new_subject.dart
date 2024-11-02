import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/Models/subject_model.dart';

class AdminAddNewSubject extends StatefulWidget {
  final String semester;

  const AdminAddNewSubject(this.semester, {super.key});

  @override
  State<AdminAddNewSubject> createState() => _AdminAddNewSubjectState();
}

class _AdminAddNewSubjectState extends State<AdminAddNewSubject> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController subjectController = TextEditingController();
  String? selectedCategory = "Select Category";
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');
  late String? fcmToken;
  List<Map<String, dynamic>> displaySemesterMap = [];
  List<Map<String, dynamic>> displayCategoryMap = [
    {
      "key": "Select Category",
      "Category": "Select Category",
      "Visibility": "true"
    },
    {"key": "Theory", "Category": "Theory", "Visibility": "true"},
    {"key": "Practical", "Category": "Practical", "Visibility": "true"},
    {"key": "Papers", "Category": "Papers", "Visibility": "true"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new subject ${widget.semester}"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Colors.white,
                  ),
                  height: double.maxFinite,
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 40, right: 20, left: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: subjectController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Subject',
                              hintText: 'Enter Subject name',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<String>(
                            value: selectedCategory,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            style: const TextStyle(color: Colors.black),
                            items: displayCategoryMap
                                .where((package) =>
                                    package["Visibility"] == "true")
                                .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> package) {
                                return DropdownMenuItem<String>(
                                  value: package["key"],
                                  child: Text(package["Category"],
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              },
                            ).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                            hint: const Text(
                              "Select a subject category",
                              style: TextStyle(color: Colors.black),
                            ),
                            isExpanded: true,
                            underline: Container(
                              height: 1,
                              color: Colors.grey, // Color of the underline
                            ),
                            itemHeight:
                                MediaQuery.of(context).size.width * 0.15,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            width: 300,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff2a446b), Color(0xff12d3c6)],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  var subject = subjectController.text;
                                  String? category;
                                  if (selectedCategory == "Select Category") {
                                    const snackBar = SnackBar(
                                      content:
                                          Text("Please select semester...!!"),
                                      duration: Duration(seconds: 2),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    category = selectedCategory;
                                  }
                                  SubjectModel regobj = SubjectModel(
                                      subject, widget.semester, category!);
                                  dbRef.push().set(regobj.toJson());
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Subject Added"),
                                        content: const Text("Subject added successfully..!!"),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text("Add subject",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
