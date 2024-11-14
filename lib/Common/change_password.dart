import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/send_otp.dart';

import 'student_new_password.dart';

class StudentChangePassword extends StatefulWidget {
  const StudentChangePassword({super.key});

  @override
  State<StudentChangePassword> createState() => _StudentChangePasswordState();
}

class _StudentChangePasswordState extends State<StudentChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerOTP = TextEditingController();
  bool isOTPSent = false;
  bool isEnabled = true;
  var otp;
  var userKey;

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
                              enabled: isEnabled,
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
                            if (isOTPSent)
                              TextFormField(
                                controller: controllerOTP,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter OTP';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.password,
                                      color: Color(0xff2a446b)),
                                  prefixIconColor: Color(0xff2a446b),
                                  labelText: 'OTP',
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter OTP',
                                ),
                              ),
                            if (isOTPSent)
                              const SizedBox(
                                height: 20,
                              ),
                            // Conditionally show the "Send OTP" button if isOTPSent is false
                            if (!isOTPSent)
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
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      var email = controllerEmail.text;
                                      var receivedOTP = await sendOTP(email);
                                      setState(() {
                                        isLoading = false;
                                        // Change the button state to true
                                        controllerEmail.text = email;

                                        otp = receivedOTP;
                                        isEnabled = false;
                                        isOTPSent = true;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    'Send OTP',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            if (isLoading) // Show the loading indicator when isLoading is true
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                            // Show the "Verify OTP" button if isOTPSent is true
                            if (isOTPSent)
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
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      bool user = await checkUser(context);

                                      if (user) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        // Handle OTP verification here
                                        String emailOTP = otp.toString();
                                        String enteredOTP = controllerOTP.text;
                                        if (emailOTP == enteredOTP) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentNewPassword(userKey),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    'Verify OTP',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            if (isLoading) // Show the loading indicator when isLoading is true
                              const Center(
                                child: CircularProgressIndicator(),
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

  Future<bool> checkUser(BuildContext context) async {
    final scaffoldContext = context;
    late bool res;

    var email = controllerEmail.text;
    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblStudent')
        .orderByChild("Email")
        .equalTo(email);
    String msg = "No Username found";
    Map data;
    var count = 0;
    await dbRef2.once().then((documentSnapshot) async {
      for (var x in documentSnapshot.snapshot.children) {
        userKey = x.key;
        data = x.value as Map;
        if (data["Email"] == email) {
          count = count + 1;
          res = true;
        } else {
          msg = "Sorry..! No User found";
          res = false;
        }
      }
      if (count == 0) {
        showDialog(
          context: scaffoldContext,
          builder: (scaffoldContext) {
            return AlertDialog(
              title: const Text("Alert Message"),
              content: Text(msg.toString()),
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
      }
    });
    return res;
  }
}
