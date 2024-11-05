// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common/login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  var key = "";
  var email = "";
  var name = "";
  var phone = "";
  var semesterKey = "";
  String semester = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    key = (await getKey())!;
    email = (await getData("StudentEmail"))!;
    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblStudent')
        .orderByChild("Email")
        .equalTo(email);
    Map data;
    await dbRef2.once().then((documentSnapshot) async {
      for (var x in documentSnapshot.snapshot.children) {
        data = x.value as Map;
        name = "${data["FirstName"]} ${data["LastName"]}";
        email = data["Email"];
        phone = data["ContactNumber"];
        semesterKey = data["Semester"];
      }
    });
    getSemester();
    setState(() {});
  }

  Future<void> getSemester() async {
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblSemester/$semesterKey');
    DatabaseEvent databaseEventStudent = await dbRef.once();
    DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;
    for(var x in dataSnapshotStudent.children){
      semester = x.value as String;
      if(semester.toString().contains("Semester")){
        break;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loadUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Divider(height: 30, color: Colors.grey),
                ListTile(
                  title: const Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(name),
                ),
                const Divider(height: 20, color: Colors.grey),
                ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(email),
                ),
                const Divider(height: 20, color: Colors.grey),
                ListTile(
                  title: const Text(
                    'Semester',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(semester),
                ),
                const Divider(height: 20, color: Colors.grey),
                ListTile(
                  title: const Text(
                    'Contact No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(phone),
                ),
                const Divider(height: 20, color: Colors.grey),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove("FirstName");
                    prefs.remove("LastName");
                    prefs.remove("Semester");
                    prefs.remove("StudentEmail");
                    prefs.remove("Theory");
                    prefs.remove("Practical");
                    prefs.remove("Papers");
                    prefs.remove("key");
                    final updatedData = {"FCMToken": ""};
                    final userRef = FirebaseDatabase.instance
                        .ref()
                        .child("ProgrammerProdigies/tblStudent")
                        .child(key);
                    await userRef.update(updatedData);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2a446b),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
