import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/Admin/home_page.dart';
import 'package:programmer_prodigies/Student/home_page.dart';
import 'package:programmer_prodigies/Student/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController controllerUname = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16.0),
      child: Scaffold(
        key: _formKey,
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
                )),
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
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: controllerUname,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter username';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.email_outlined,
                                              color: Color(0xff2a446b)),
                                          prefixIconColor: Color(0xff2a446b),
                                          labelText: 'Username',
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Enter Username',
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
                                              _togglePasswordVisibility(
                                                  context);
                                            },
                                          ),
                                          prefixIconColor: const Color(0xff2a446b),
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: 'Password',
                                          hintText: 'Enter Password',
                                        ),
                                      ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //   MainAxisAlignment.end,
                                      //   children: [
                                      //     TextButton(
                                      //       onPressed: () {
                                      //         Navigator.push(
                                      //             context,
                                      //             MaterialPageRoute(
                                      //                 builder: (context) =>
                                      //                 const userPasswordChangeUserName()));
                                      //       },
                                      //       child: Text("Forgot Password ?",
                                      //           style: TextStyle(
                                      //               color:
                                      //               Colors.grey.shade700)),
                                      //     ),
                                      //   ],
                                      // ),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _performLogin(context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: const Text(
                                            'LOG IN',
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
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
                                                      const RegistrationPage()),
                                                );
                                              },
                                              child: const Text(
                                                "Register here",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontStyle: FontStyle.italic,
                                                    color: Color(0xff2a446b),
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
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
    final scaffoldContext = context;

    var username = controllerUname.text;
    if(username == "s"){
      Navigator.pop(scaffoldContext);
      Navigator.push(scaffoldContext, MaterialPageRoute(builder: (scaffoldContext)=>const StudentHomePage()));
    }
    if(username == "a"){
      Navigator.pop(scaffoldContext);
      Navigator.push(scaffoldContext, MaterialPageRoute(builder: (scaffoldContext)=>const AdminHomePage()));
    }
    // var password = controllerPassword.text;
    // var encPassword = encryptString(password);
    // Query dbRef2 = FirebaseDatabase.instance
    //     .ref()
    //     .child('ArogyaSair/tblUser')
    //     .orderByChild("Username")
    //     .equalTo(username);
    // String msg = "Invalid Username or Password..! Please check..!!";
    // Map data;
    // var count = 0;
    // await dbRef2.once().then((documentSnapshot) async {
    //   for (var x in documentSnapshot.snapshot.children) {
    //     String? key = x.key;
    //     data = x.value as Map;
    //     if (data["Username"] == username &&
    //         data["Password"].toString() == encPassword) {
    //       await saveData('username', data["Username"]);
    //       await saveData('firstname', data["FirstName"]);
    //       await saveData('lastname', data["LastName"]);
    //       await saveData('email', data["Email"]);
    //       await saveData('key', key);
    //       count = count + 1;
    //       Navigator.pop(context);
    //       Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => const BottomBar()));
    //     } else {
    //       msg = "Sorry..! Wrong Username or Password";
    //       _showSnackbar(scaffoldContext, msg);
    //     }
    //   }
    //   if (count == 0) {
    //     showDialog(
    //       context: context,
    //       builder: (context) {
    //         return AlertDialog(
    //           title: const Text("Alert Message"),
    //           content: Text(msg.toString()),
    //           actions: <Widget>[
    //             OutlinedButton(
    //               child: const Text('OK'),
    //               onPressed: () {
    //                 Navigator.of(context).pop();
    //               },
    //             )
    //           ],
    //         );
    //       },
    //     );
    //   }
    // });

  }
}

String encryptString(String originalString) {
  var bytes = utf8.encode(originalString); // Convert string to bytes
  var digest = sha256.convert(bytes); // Apply SHA-256 hash function
  return digest.toString();
}