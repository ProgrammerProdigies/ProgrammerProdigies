import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/services/auth_services.dart';

class StudentChangePassword extends StatefulWidget {
  const StudentChangePassword({super.key});

  @override
  State<StudentChangePassword> createState() => _StudentChangePasswordState();
}

class _StudentChangePasswordState extends State<StudentChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerOTP = TextEditingController();
  final auth = FirebaseAuth.instance;

  // State variable to track loading status
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Email verification",
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
                            // if (isOTPSent)
                            //   TextFormField(
                            //     controller: controllerOTP,
                            //     validator: (value) {
                            //       if (value!.isEmpty) {
                            //         return 'Please enter OTP';
                            //       }
                            //       return null;
                            //     },
                            //     keyboardType: TextInputType.number,
                            //     decoration: const InputDecoration(
                            //       prefixIcon: Icon(Icons.password,
                            //           color: Color(0xff2a446b)),
                            //       prefixIconColor: Color(0xff2a446b),
                            //       labelText: 'OTP',
                            //       filled: true,
                            //       fillColor: Colors.white,
                            //       hintText: 'Enter OTP',
                            //     ),
                            //   ),
                            // if (isOTPSent)
                            //   const SizedBox(
                            //     height: 20,
                            //   ),
                            // Conditionally show the "Send OTP" button if isOTPSent is false
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
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
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    var email = controllerEmail.text;
                                    await AuthService().signup(email: email, password: "ProgrammerProdigies@0987654321");
                                    await auth
                                        .sendPasswordResetEmail(email: email)
                                        .then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Password reset link has been sent successfully..!")),
                                      );
                                      Navigator.pop(context);
                                    }).onError((error, stackTrace) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(error.toString())),
                                      );
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "You are not registered with our platform. Please sign up first.")),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text(
                                  'Reset password',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
