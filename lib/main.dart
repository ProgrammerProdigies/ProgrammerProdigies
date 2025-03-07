// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/bottom_nav_bar.dart';
import 'package:programmerprodigies/Common/login/login_page.dart';
import 'package:programmerprodigies/Student/home_page.dart';
import 'package:programmerprodigies/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String data = "";
  final key = 'AdminEmail';
  final key1 = 'Email';
  late bool adminContains;
  late bool studentContains;
  late String keyToCheck;
  var page;
  late String? fcmToken = "";
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool i = false;
  bool loginChecked = false;

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firstTime = prefs.containsKey("firstTime");
    BuildContext Context = context;

    if (!firstTime) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Here\'s a message for you from the admin...!!'),
            content: const Text(
                "You have to make a payment before logging in. To know the details of the packages and the price, please contact the admin at this email address: programmerprodigies@gmail.com."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await saveFirstTime(true);
                  await Future.delayed(const Duration(seconds: 5));
                  fcmToken = await _fcm.getToken();
                  await _checkIfLoggedIn();
                  Navigator.pushReplacement(
                    Context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    } else {
      // If not the first time, proceed directly
      await Future.delayed(const Duration(seconds: 5));
      fcmToken = await _fcm.getToken();
      await _checkIfLoggedIn();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  bool isLoginProcessRunning = false; // Prevent multiple login checks

  Future<void> _checkIfLoggedIn() async {
    if (isLoginProcessRunning) return; // Avoid multiple calls
    isLoginProcessRunning = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminContains = prefs.containsKey(key);
    studentContains = prefs.containsKey(key1);

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (adminContains) {
        page = const BottomBar(0); // Admin Page
      } else if (studentContains) {
        var email = await getData("Email");
        Query dbRef2 = FirebaseDatabase.instance
            .ref()
            .child('programmerprodigies/tblStudent')
            .orderByChild("Email")
            .equalTo(email);

        await dbRef2.once().then((documentSnapshot) async {
          for (var x in documentSnapshot.snapshot.children) {
            String? key = x.key;
            Map data = x.value as Map;
            String? FCMToken = data["FCMToken"];
            String semester = data["Semester"];

            // Get semester data
            Query dbRef = FirebaseDatabase.instance
                .ref()
                .child('programmerprodigies/tblSemester')
                .child(semester);

            DatabaseEvent databaseEventStudent = await dbRef.once();
            Map semData = databaseEventStudent.snapshot.value as Map;

            if (semData["Visibility"] == "true") {
              if (FCMToken == fcmToken) {
                await saveStudentData(data, key, semData);
                page = const StudentHomePage(); // Student Page
              } else if (FCMToken == "") {
                await saveStudentData(data, key, semData);
                await updateFCMToken(key!, fcmToken!);
                page = const StudentHomePage();
              } else {
                await clearPreferences(); // Clear preferences
                await updateFCMToken(key!, "");
                page = const MyApp(); // Redirect to App
              }
            } else {
              page = const LoginPage(); // Login page if semester not visible
            }
          }
        });
      } else {
        page = const LoginPage(); // Default Login Page
      }
    } else {
      page = const LoginPage(); // If no user is logged in
    }

    isLoginProcessRunning = false; // Reset flag
    loginChecked = true; // Mark login check completed
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences
    await saveFirstTime(true);
  }

  Future<void> saveStudentData(Map data, String? key, Map semData) async {
    await saveData('FirstName', data["FirstName"]);
    await saveData('LastName', data["LastName"]);
    await saveData('Semester', data["Semester"]);
    await saveData('SemesterName', semData["Semester"]);
    await saveData('Email', data["Email"]);
    await saveData('Theory', data["Theory"].toString());
    await saveData('Practical', data["Practical"].toString());
    await saveData('Papers', data["Papers"].toString());
    await saveData('Demo', data["Demo"].toString());
    await saveData('key', key);
  }

  Future<void> updateFCMToken(String key, String FcmToken) async {
    final updatedData = {"FCMToken": FcmToken};
    final userRef = FirebaseDatabase.instance
        .ref()
        .child("programmerprodigies/tblStudent")
        .child(key);
    await userRef.update(updatedData);
  }



  // Future<void> _checkIfLoggedIn() async {
  //   print("Checking login");
  //   if(loginChecked){
  //     page = LoginPage();
  //     return;
  //   }
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   adminContains = prefs.containsKey(key);
  //   studentContains = prefs.containsKey(key1);
  //
  //   User? user = FirebaseAuth.instance.currentUser;
  //   print("user $user");
  //   if (user != null) {
  //     if (adminContains) {
  //       page = const BottomBar(0);
  //       return;
  //     } else if (studentContains) {
  //       print("Student is there");
  //       // keyToCheck = (await getKey())!;
  //       var email = await getData("Email");
  //       Query dbRef2;
  //       dbRef2 = FirebaseDatabase.instance
  //           .ref()
  //           .child('programmerprodigies/tblStudent')
  //           .orderByChild("Email")
  //           .equalTo(email);
  //       await dbRef2.once().then((documentSnapshot) async {
  //         for (var x in documentSnapshot.snapshot.children) {
  //           String? key = x.key;
  //           Map data = x.value as Map;
  //           String? FCMToken = data["FCMToken"];
  //           var firstName = data["FirstName"];
  //           var lastName = data["LastName"];
  //           var email = data["Email"];
  //           var semester = data["Semester"];
  //           var theory = data["Theory"].toString();
  //           var practical = data["Practical"].toString();
  //           var papers = data["Papers"].toString();
  //           var demo = data["Demo"].toString();
  //           Map semData = {};
  //           Query dbRef = FirebaseDatabase.instance
  //               .ref()
  //               .child('programmerprodigies/tblSemester')
  //               .child(semester);
  //           DatabaseEvent databaseEventStudent = await dbRef.once();
  //           DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;
  //           semData = dataSnapshotStudent.value as Map;
  //           print("Sem data received $firstName");
  //           if (semData["Visibility"] == "true") {
  //             if (FCMToken == fcmToken) {
  //               print("FCM are same");
  //               await saveData('FirstName', firstName);
  //               await saveData('LastName', lastName);
  //               await saveData('Semester', semester);
  //               await saveData('SemesterName', semData["Semester"]);
  //               await saveData('StudentEmail', email);
  //               await saveData('Theory', theory);
  //               await saveData('Practical', practical);
  //               await saveData('Papers', papers);
  //               await saveData('Demo', demo);
  //               await saveData('key', key);
  //               page = const StudentHomePage();
  //               return;
  //             } else if (FCMToken == "") {
  //               print("FCM not there");
  //               await saveData('FirstName', firstName);
  //               await saveData('LastName', lastName);
  //               await saveData('Semester', semester);
  //               await saveData('SemesterName', semData["Semester"]);
  //               await saveData('StudentEmail', email);
  //               await saveData('Theory', theory);
  //               await saveData('Practical', practical);
  //               await saveData('Papers', papers);
  //               await saveData('Demo', demo);
  //               await saveData('key', key);
  //               final updatedData = {"FCMToken": fcmToken};
  //               final userRef = FirebaseDatabase.instance
  //                   .ref()
  //                   .child("programmerprodigies/tblStudent")
  //                   .child(key!);
  //               await userRef.update(updatedData);
  //               print("FCM $fcmToken");
  //               print("FCM updated");
  //               page = const StudentHomePage();
  //               return;
  //             } else if(FCMToken != fcmToken) {
  //               print("Different FCM");
  //               SharedPreferences prefs = await SharedPreferences.getInstance();
  //               prefs.remove("FirstName");
  //               prefs.remove("LastName");
  //               prefs.remove("Semester");
  //               prefs.remove("SemesterName");
  //               prefs.remove("StudentEmail");
  //               prefs.remove("Theory");
  //               prefs.remove("Practical");
  //               prefs.remove("Papers");
  //               prefs.remove("Demo");
  //               prefs.remove("key");
  //               print("Preference removed");
  //               studentContains = false;
  //               page = const MyApp();
  //               return;
  //             }
  //           } else {
  //             print("After checking sem visibility");
  //             page = const LoginPage();
  //           }
  //         }
  //         return;
  //       });
  //     } else {
  //       print("Student is nto there");
  //       page = const LoginPage();
  //     }
  //   } else {
  //     print("User not available");
  //     page = const LoginPage();
  //   }
  //   loginChecked = true;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2a446b),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/GIF/Programmer.gif"),
          ],
        ),
      ),
    );
  }
}
