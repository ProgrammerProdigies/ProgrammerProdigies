import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Common/login_page.dart';

class StudentNewPassword extends StatefulWidget {
  final String userKey;
  const StudentNewPassword(this.userKey, {super.key});

  @override
  State<StudentNewPassword> createState() => _StudentNewPasswordState();
}

class _StudentNewPasswordState extends State<StudentNewPassword> {

  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Create new Password",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                prefixIconColor: const Color(0xff2a446b),
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
                                    color: const Color(0xff2a446b),
                                  ),
                                  onPressed: () {
                                    _toggleConfirmPasswordVisibility(context);
                                  },
                                ),
                                prefixIconColor: const Color(0xff2a446b),
                                labelText: 'Confirm Password',
                                hintText: 'Re-Enter Password',
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height:
                              MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.5,
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
                                onPressed: () async {
                                  var password = controllerPassword.text;
                                  var cnfPassword = controllerConfirmPassword.text;
                                  if (_formKey.currentState!.validate()) {
                                    if(password == cnfPassword){
                                      var encryptedPassword = encryptString(password);
                                      final updatedData = {"Password": encryptedPassword};
                                      final userRef = FirebaseDatabase.instance
                                          .ref()
                                          .child("ProgrammerProdigies/tblStudent")
                                          .child(widget.userKey);
                                      await userRef.update(updatedData);
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Password changes"),
                                            content: const Text(
                                                "Password has been changed successfully..!!"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                        barrierDismissible: false
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text(
                                  'Change password',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
