// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/bottom_nav_bar.dart';
import 'package:programmerprodigies/Student/home_page.dart';
import 'package:programmerprodigies/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> signup({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "An account already exists with the email.";
      }
      if (kDebugMode) {
        print(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> signIn(
      {required String email,
      required String password,
      required BuildContext context,
      required String FcmToken}) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Query dbRef2;

      if (email == "programmerprodigies@gmail.com") {
        dbRef2 = FirebaseDatabase.instance
            .ref()
            .child('ProgrammerProdigies/tblAdmin')
            .orderByChild("Email")
            .equalTo(email);
        Map data;
        await dbRef2.once().then((documentSnapshot) async {
          for (var x in documentSnapshot.snapshot.children) {
            String? key = x.key;
            data = x.value as Map;
            if (data["Email"] == email) {
              await saveData('email', data["Email"]);
              await saveKey(key);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const BottomBar(0)));
            }
          }
        });
        await saveData("AdminEmail", email);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (scaffoldContext) => const BottomBar(0)));
      } else {
        dbRef2 = FirebaseDatabase.instance
            .ref()
            .child('ProgrammerProdigies/tblStudent')
            .orderByChild("Email")
            .equalTo(email);
        String msg = "Invalid email or Password..!";
        Map data;
        await dbRef2.once().then((documentSnapshot) async {
          for (var x in documentSnapshot.snapshot.children) {
            String? key = x.key;
            data = x.value as Map;
            String? FCMToken = data["FCMToken"];
            var firstName = data["FirstName"];
            var lastName = data["LastName"];
            var email = data["Email"];
            var semester = data["Semester"];
            var theory = data["Theory"].toString();
            var practical = data["Practical"].toString();
            var papers = data["Papers"].toString();
            var demo = data["Demo"].toString();
            Map semData = {};
            Query dbRef = FirebaseDatabase.instance
                .ref()
                .child('ProgrammerProdigies/tblSemester')
                .child(semester);
            DatabaseEvent databaseEventStudent = await dbRef.once();
            DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;
            semData = dataSnapshotStudent.value as Map;
            if (semData["Visibility"] == "true") {
              if (FCMToken == "") {
                final updatedData = {"FCMToken": FcmToken};
                final userRef = FirebaseDatabase.instance
                    .ref()
                    .child("ProgrammerProdigies/tblStudent")
                    .child(key!);
                await userRef.update(updatedData);
                if (data["Email"] == email) {
                  await saveData('FirstName', firstName);
                  await saveData('LastName', lastName);
                  await saveData('Semester', semester);
                  await saveData('SemesterName', semData["Semester"]);
                  await saveData('Email', email);
                  await saveData('Theory', theory);
                  await saveData('Practical', practical);
                  await saveData('Papers', papers);
                  await saveData('Demo', demo);
                  await saveKey(key);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentHomePage(),
                    ),
                  );
                } else {
                  msg = "Sorry..! Wrong email or Password";
                  _showSnackbar(context, msg);
                }
              } else if (FCMToken == FcmToken) {
                if (data["Email"] == email) {
                  await saveData('FirstName', firstName);
                  await saveData('LastName', lastName);
                  await saveData('SemesterName', semData["Semester"]);
                  await saveData('Semester', semester);
                  await saveData('Email', email);
                  await saveData('Theory', theory);
                  await saveData('Practical', practical);
                  await saveData('Papers', papers);
                  await saveData('Demo', demo);
                  await saveKey(key);
                  // await saveData('key', key);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StudentHomePage()));
                } else {
                  msg = "Sorry..! Wrong email or Password";
                  _showSnackbar(context, msg);
                }
              } else if (FCMToken != FcmToken) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Login..!!'),
                      content: const Text(
                          "You already have logged in some other phone, you can not login with this device."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove("FirstName");
                prefs.remove("LastName");
                prefs.remove("Semester");
                prefs.remove("SemesterName");
                prefs.remove("Email");
                prefs.remove("Theory");
                prefs.remove("Practical");
                prefs.remove("Papers");
                prefs.remove("Demo");
                prefs.remove("key");
              }
            } else if (semData["Visibility"] == "false") {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Login..!!'),
                    content: const Text(
                        "The semester you are trying to access is currently not available.\nPlease contact admin on this email address:- programmerprodigies@gmail.com for more details"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found') {
        message = "The password provided is too weak.";
      } else if (e.code == 'wrong-password') {
        message = "An account already exists with the email.";
      } else if (e.code == "invalid-credential") {
        message = "Wrong id or password.\nPlease try to change the password.";
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Alert Message"),
              content: Text(message),
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
          barrierDismissible: false);
      if (kDebugMode) {
        print(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> signOut({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
