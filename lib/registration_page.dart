import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef2 =
      FirebaseDatabase.instance.ref().child('ArogyaSair/tblUser');

  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLastname = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerContact = TextEditingController();
  var birthDate = "Select Birthdate";
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff2a446b), Color(0xff12d3c6)])),
          child: const Padding(
            padding: EdgeInsets.only(top: 60, left: 22),
            child: Text(
              "Register",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 200),
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
                  padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
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
                                    controller: controllerName,
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
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: controllerPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          obscureText: !isPasswordVisible,
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
                            prefixIconColor: Color(0xff2a446b),
                            labelText: 'Password',
                            hintText: 'Enter Password',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: controllerConfirmPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter re-enter password';
                            }
                            return null;
                          },
                          obscureText: !isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xff2a446b)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xff2a446b),
                              ),
                              onPressed: () {
                                _toggleConfirmPasswordVisibility(context);
                              },
                            ),
                            prefixIconColor: Color(0xff2a446b),
                            labelText: 'Confirm Password',
                            hintText: 'Re-Enter Password',
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
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                var name = controllerName.text;
                                var lastname = controllerLastname.text;
                                var password = controllerPassword.text;
                                var confirmPassword =
                                    controllerConfirmPassword.text;
                                var email = controllerEmail.text;
                                var contact = controllerContact.text;
                                var encPassword = encryptString(password);
                                if (password == confirmPassword) {
                                  // RegisterModel regobj = RegisterModel(
                                  //   username,
                                  //   encPassword,
                                  //   email,
                                  //   name,
                                  //   lastname,
                                  //   DOB,
                                  //   contact,
                                  //   "Unspecified",
                                  //   "Unspecified",
                                  // );
                                  // dbRef2.push().set(regobj.toJson());
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Alert Dialog Title'),
                                        content: const Text(
                                            'This is an alert dialog message.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()));
                                } else {
                                  const snackBar = SnackBar(
                                    content:
                                        Text("Password does not match..!!"),
                                    duration: Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text("Sign up",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Text(
                                "Already have an account..?",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginPage()),
                                  );
                                },
                                child: const Text(
                                  "Login here",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff2a446b),
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ]),
    );
  }

  void _togglePasswordVisibility(BuildContext context) {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility(BuildContext context) {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }
}

String encryptString(String originalString) {
  var bytes = utf8.encode(originalString); // Convert string to bytes
  var digest = sha256.convert(bytes); // Apply SHA-256 hash function
  return digest.toString(); // Return the hashed string
}
