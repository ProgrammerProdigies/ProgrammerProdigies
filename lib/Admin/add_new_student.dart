// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Models/register_model.dart';
import 'package:programmerprodigies/send_mail.dart';

import '../firebase_api.dart';

class AdminAddNewStudent extends StatefulWidget {
  final List<Map<String, dynamic>> displaySemesterMap;

  const AdminAddNewStudent(this.displaySemesterMap, {super.key});

  @override
  State<AdminAddNewStudent> createState() => _AdminAddNewStudentState();
}

class _AdminAddNewStudentState extends State<AdminAddNewStudent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map> semester = [];
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblStudent');

  TextEditingController controllerFirstName = TextEditingController();
  TextEditingController controllerLastname = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerContact = TextEditingController();
  var birthDate = "Select Birthdate";
  String? selectedGender;
  String? selectedSemester = "0";
  String? selectedPackage = "Select Package";
  final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late String? fcmToken;
  late List<Map<String, dynamic>> displaySemesterMap;

  List<Map<String, dynamic>> displayPackageMap = [
    {
      "key": "Select Package",
      "PackageName": "Select Package",
      "Visibility": "true"
    },
    {"key": "1", "PackageName": "Theory", "Visibility": "true"},
    {"key": "2", "PackageName": "Practical", "Visibility": "true"},
    {"key": "3", "PackageName": "Papers", "Visibility": "true"},
    {"key": "4", "PackageName": "Theory + Practical", "Visibility": "true"},
    {
      "key": "5",
      "PackageName": "Theory + Practical + Papers",
      "Visibility": "true"
    },
  ];

  @override
  void initState() {
    super.initState();
    displaySemesterMap = widget.displaySemesterMap;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _messagingService.init(context);
    fcmToken = await _fcm.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add new student",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
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
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      controller: controllerFirstName,
                                      decoration: const InputDecoration(
                                        hintText: "First Name",
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Color(0xff2a446b),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      controller: controllerLastname,
                                      decoration: const InputDecoration(
                                        hintText: "Last Name",
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Color(0xff2a446b),
                                        ),
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
                          TextFormField(
                            controller: controllerEmail,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIconColor: Color(0xff2a446b),
                              prefixIcon:
                                  Icon(Icons.email, color: Color(0xff2a446b)),
                              labelText: 'Email',
                              hintText: 'Enter Email',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: controllerContact,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Contact number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIconColor: Color(0xff2a446b),
                              prefixIcon:
                                  Icon(Icons.call, color: Color(0xff2a446b)),
                              labelText: 'Contact Number',
                              hintText: 'Enter Contact',
                            ),
                            maxLength: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Gender:',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Radio(
                                      value: "Male",
                                      groupValue: selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value!;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Male',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Radio(
                                      value: "Female",
                                      groupValue: selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value!;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Female',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<String>(
                            value: selectedSemester,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            style: const TextStyle(color: Colors.black),
                            items: displaySemesterMap
                                .where((semester) =>
                                    semester["Visibility"] == "true")
                                .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> semester) {
                                return DropdownMenuItem<String>(
                                  value: semester["key"],
                                  child: Text(semester["Semester"],
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              },
                            ).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSemester = newValue;
                              });
                            },
                            hint: const Text(
                              "Select a semester",
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
                          DropdownButton<String>(
                            value: selectedPackage,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            style: const TextStyle(color: Colors.black),
                            items: displayPackageMap
                                .where((package) =>
                                    package["Visibility"] == "true")
                                .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> package) {
                                return DropdownMenuItem<String>(
                                  value: package["key"],
                                  child: Text(package["PackageName"],
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              },
                            ).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPackage = newValue;
                              });
                            },
                            hint: const Text(
                              "Select a package",
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
                                var email = controllerEmail.text;
                                bool checkEmail =
                                    await checkEmailFromDatabase(email);
                                if (checkEmail) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Alert Message"),
                                        content: Text(
                                            "$email email address has already been used. Try another email."),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  if (_formKey.currentState!.validate()) {
                                    var firstName = controllerFirstName.text;
                                    var lastname = controllerLastname.text;
                                    var email = controllerEmail.text;
                                    var contact = controllerContact.text;
                                    String? semester;
                                    late String gender;
                                    if (selectedSemester == "0") {
                                      const snackBar = SnackBar(
                                        content:
                                            Text("Please select semester...!!"),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      semester = selectedSemester;
                                    }
                                    if (selectedGender == null) {
                                      const snackBar = SnackBar(
                                        content:
                                            Text("Please select gender...!!"),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      gender = selectedGender!;
                                    }
                                    bool theory = false,
                                        practical = false,
                                        papers = false;
                                    switch (selectedPackage) {
                                      case "1":
                                        theory = true;
                                        break;
                                      case "2":
                                        practical = true;
                                        break;
                                      case "3":
                                        papers = true;
                                        break;
                                      case "4":
                                        theory = true;
                                        practical = true;
                                        break;
                                      case "5":
                                        theory = true;
                                        practical = true;
                                        papers = true;
                                    }
                                    RegisterModel regobj = RegisterModel(
                                        firstName,
                                        lastname,
                                        email,
                                        email,
                                        contact,
                                        gender,
                                        semester!,
                                        "",
                                        true,
                                        theory,
                                        practical,
                                        papers,
                                        false);
                                    dbRef.push().set(regobj.toJson());
                                    sendMail(regobj.toJson());
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Registration complete"),
                                          content: Text(
                                              "Student can login with this email id: $email and password will be $email"),
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
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text("Add student",
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

  Future<bool> checkEmailFromDatabase(String email) async {
    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblStudent')
        .orderByChild("Email")
        .equalTo(email);
    Map data;
    bool status = false;
    await dbRef2.once().then((documentSnapshot) async {
      for (var x in documentSnapshot.snapshot.children) {
        data = x.value as Map;
        if (data["Email"] == email) {
          status = true;
        } else {
          status = false;
        }
      }
    });
    return status;
  }
}
