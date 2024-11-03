// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/Admin/bottom_nav_bar.dart';
import 'package:programmer_prodigies/Common/login_page.dart';
import 'package:programmer_prodigies/Student/home_page.dart';
import 'package:programmer_prodigies/saveSharePreferences.dart';
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
  final key1 = 'StudentEmail';
  late bool adminContains;
  late bool studentContains;
  late String keyToCheck;
  var page;
  late String? fcmToken = "";
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    fcmToken = await _fcm.getToken();
    await _checkIfLoggedIn();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminContains = prefs.containsKey(key);
    studentContains = prefs.containsKey(key1);

    if (adminContains) {
      page = const BottomBar(0);
      return;
    } else if (studentContains) {
      keyToCheck = (await getKey())!;
      DatabaseReference dbHospitalRef = FirebaseDatabase.instance
          .ref()
          .child("ProgrammerProdigies/tblStudent/$keyToCheck");

      DatabaseEvent databaseEventStudent = await dbHospitalRef.once();
      DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;

      for (var x in dataSnapshotStudent.children) {
        String? key = x.key;
        var data = x.value;
        var FCMToken = data.toString();
        if (FCMToken == fcmToken) {
          page = const StudentHomePage();
          return;
        } else if (FCMToken == "") {
          final updatedData = {"FCMToken": fcmToken};
          final userRef = FirebaseDatabase.instance
              .ref()
              .child("ProgrammerProdigies/tblStudent")
              .child(key!);
          await userRef.update(updatedData);
          page = const StudentHomePage();
          return;
        }
      }
      return;
    } else {
      page = const LoginPage();
    }
  }

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
