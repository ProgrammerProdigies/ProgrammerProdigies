// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Common/change_password.dart';
import 'package:programmerprodigies/Student/contact.dart';
import 'package:programmerprodigies/Student/registration/registration_page.dart';
import 'package:programmerprodigies/services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool isPasswordVisible = false;

  // final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late String? fcmToken = "";
  List<Map<String, dynamic>> displaySemesterMap = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // await _messagingService.init(context);
    fcmToken = await _fcm.getToken();
  }

  Future<List<Map>> getSemesterData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference dbRefSemester =
          FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSemester');
      displaySemesterMap.clear();
      displaySemesterMap.add(
          {"key": "0", "Semester": "Select Semester", "Visibility": "true"});
      await dbRefSemester.once().then((event) {
        Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
        if (values != null) {
          values.forEach((key, value) {
            if (value["Visibility"] == "true") {
              displaySemesterMap.add({
                "key": key,
                "Semester": value["Semester"],
                "Visibility": value["Visibility"],
              });
            }
          });
          displaySemesterMap
              .sort((a, b) => a["Semester"].compareTo(b["Semester"]));
        }
      });
    }
    return displaySemesterMap;
  }

  @override
  Widget build(BuildContext context) {
    _loadUserData();
    getSemesterData();
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16.0),
      child: Scaffold(
        // key: _formKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff2a446b), Color(0xff12d3c6)])),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 70, right: 235),
                    child: Text(
                      "Welcome, ",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 205),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                height: double.maxFinite,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 50, right: 20, left: 20),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 20),
                              child: Form(
                                  // key: _formKey,
                                  child: Column(
                                children: [
                                  TextFormField(
                                    controller: controllerEmail,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined,
                                          color: Color(0xff2a446b)),
                                      prefixIconColor: Color(0xff2a446b),
                                      labelText: 'Email',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Enter Email',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: controllerPassword,
                                    obscureText: !isPasswordVisible,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock,
                                          color: Color(0xff2a446b)),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0xff2a446b),
                                        ),
                                        onPressed: () {
                                          _togglePasswordVisibility(context);
                                        },
                                      ),
                                      prefixIconColor: const Color(0xff2a446b),
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'Password',
                                      hintText: 'Enter Password',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const StudentChangePassword()));
                                        },
                                        child: const Text(
                                          "Forgot Password ?",
                                          style: TextStyle(
                                            color: Color(0xff2a446b),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 300,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xff2a446b),
                                          Color(0xff12d3c6)
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // if (_formKey.currentState!
                                        //     .validate()) {
                                        // }
                                        _performLogin(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        'LOG IN',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Text(
                                          "Not our student yet..!?",
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistrationPage(
                                                        displaySemesterMap),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Register here",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xff2a446b),
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ContactUs(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Contact us",
                                            style: TextStyle(
                                                color: Color(0xff2a446b),
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showSnackbar(BuildContext context, String message) {
  //   final snackBar = SnackBar(
  //     content: Text(message),
  //     duration: const Duration(seconds: 2),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  void _togglePasswordVisibility(BuildContext context) {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _performLogin(BuildContext context) async {
    // final scaffoldContext = context;
    var email = controllerEmail.text;
    var password = controllerPassword.text;

    await AuthService().signIn(
        email: email,
        password: password,
        context: context,
        FcmToken: fcmToken!);
    // Query dbRef2;
    // var count = 0;
    // if (email == "programmerprodigies@gmail.com") {
    //   dbRef2 = FirebaseDatabase.instance
    //       .ref()
    //       .child('programmerprodigies/tblAdmin')
    //       .orderByChild("Email")
    //       .equalTo(email);
    //   String msg = "Invalid email or Password..! Please check..!!";
    //   Map data;
    //   await dbRef2.once().then((documentSnapshot) async {
    //     for (var x in documentSnapshot.snapshot.children) {
    //       String? key = x.key;
    //       data = x.value as Map;
    //       if (data["Email"] == email &&
    //           data["Password"].toString() == password) {
    //         await saveData('email', data["Email"]);
    //         await saveData('key', key);
    //         count = count + 1;
    //         Navigator.pop(context);
    //         Navigator.push(context,
    //             MaterialPageRoute(builder: (context) => const BottomBar(0)));
    //       } else {
    //         msg = "Sorry..! Wrong Username or Password";
    //         _showSnackbar(scaffoldContext, msg);
    //       }
    //     }
    //     if (count == 0) {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: const Text("Alert Message"),
    //             content: Text(msg.toString()),
    //             actions: <Widget>[
    //               OutlinedButton(
    //                 child: const Text('OK'),
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //               )
    //             ],
    //           );
    //         },
    //       );
    //     }
    //   });
    //   count = count + 1;
    //   await saveData("AdminEmail", email);
    //   Navigator.pop(context);
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (scaffoldContext) => const BottomBar(0)));
    // } else {
    //   dbRef2 = FirebaseDatabase.instance
    //       .ref()
    //       .child('programmerprodigies/tblStudent')
    //       .orderByChild("Email")
    //       .equalTo(email);
    //   String msg = "Invalid email or Password..!";
    //   Map data;
    //   await dbRef2.once().then((documentSnapshot) async {
    //     for (var x in documentSnapshot.snapshot.children) {
    //       String? key = x.key;
    //       data = x.value as Map;
    //       String? FCMToken = data["FCMToken"];
    //       var firstName = data["FirstName"];
    //       var lastName = data["LastName"];
    //       var email = data["Email"];
    //       var semester = data["Semester"];
    //       var theory = data["Theory"].toString();
    //       var practical = data["Practical"].toString();
    //       var papers = data["Papers"].toString();
    //       var demo = data["Demo"].toString();
    //       Map semData ={};
    //       Query dbRef = FirebaseDatabase.instance
    //           .ref()
    //           .child('programmerprodigies/tblSemester').child(semester);
    //       DatabaseEvent databaseEventStudent = await dbRef.once();
    //       DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;
    //       semData = dataSnapshotStudent.value as Map;
    //       if (semData["Visibility"] == "true") {
    //         if (FCMToken == "") {
    //           final updatedData = {"FCMToken": fcmToken};
    //           final userRef = FirebaseDatabase.instance
    //               .ref()
    //               .child("programmerprodigies/tblStudent")
    //               .child(key!);
    //           await userRef.update(updatedData);
    //           if (data["Email"] == email &&
    //               data["Password"].toString() == encryptString(password)) {
    //             await saveData('FirstName', firstName);
    //             await saveData('LastName', lastName);
    //             await saveData('Semester', semester);
    //             await saveData('SemesterName', semData["Semester"]);
    //             await saveData('StudentEmail', email);
    //             await saveData('Theory', theory);
    //             await saveData('Practical', practical);
    //             await saveData('Papers', papers);
    //             await saveData('Demo', demo);
    //             await saveData('key', key);
    //             count = count + 1;
    //             Navigator.pop(context);
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => const StudentHomePage(),
    //               ),
    //             );
    //           } else {
    //             msg = "Sorry..! Wrong email or Password";
    //             _showSnackbar(scaffoldContext, msg);
    //           }
    //         } else if (FCMToken == fcmToken) {
    //           if (data["Email"] == email &&
    //               data["Password"].toString() == encryptString(password)) {
    //             await saveData('FirstName', firstName);
    //             await saveData('LastName', lastName);
    //             await saveData('SemesterName', semData["Semester"]);
    //             await saveData('Semester', semester);
    //             await saveData('StudentEmail', email);
    //             await saveData('Theory', theory);
    //             await saveData('Practical', practical);
    //             await saveData('Papers', papers);
    //             await saveData('Demo', demo);
    //             await saveData('key', key);
    //             count = count + 1;
    //             Navigator.pop(context);
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => const StudentHomePage()));
    //           } else {
    //             msg = "Sorry..! Wrong email or Password";
    //             _showSnackbar(scaffoldContext, msg);
    //           }
    //         } else if (FCMToken != fcmToken) {
    //           msg =
    //               "You already have logged in some other phone, you can not login with this device.";
    //           SharedPreferences prefs = await SharedPreferences.getInstance();
    //           prefs.remove("FirstName");
    //           prefs.remove("LastName");
    //           prefs.remove("Semester");
    //           prefs.remove("StudentEmail");
    //           prefs.remove("Theory");
    //           prefs.remove("Practical");
    //           prefs.remove("Papers");
    //           prefs.remove("Demo");
    //           prefs.remove("key");
    //         }
    //       } else if (semData["Visibility"] == "false") {
    //         count = count + 1;
    //         showDialog(
    //           context: context,
    //           builder: (BuildContext context) {
    //             return AlertDialog(
    //               title: const Text('Login..!!'),
    //               content: const Text(
    //                   "The semester you are trying to access is currently not available.\nPlease contact admin on this email address:- programmerprodigies@gmail.com for more details"),
    //               actions: [
    //                 TextButton(
    //                   onPressed: () => Navigator.of(context).pop(),
    //                   child: const Text('Ok'),
    //                 ),
    //               ],
    //             );
    //           },
    //         );
    //       }
    //     }
    //     if (count == 0) {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: const Text("Alert Message"),
    //             content: Text(msg.toString()),
    //             actions: <Widget>[
    //               OutlinedButton(
    //                 child: const Text('OK'),
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //               )
    //             ],
    //           );
    //         },
    //       );
    //     }
    //   });
    // }
  }
}

String encryptString(String originalString) {
  var bytes = utf8.encode(originalString); // Convert string to bytes
  var digest = sha256.convert(bytes); // Apply SHA-256 hash function
  return digest.toString();
}
