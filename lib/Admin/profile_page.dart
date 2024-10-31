import 'package:flutter/material.dart';

import '../Common/login_page.dart';

class AdminProfilePageAndStudentAddPage extends StatefulWidget {
  const AdminProfilePageAndStudentAddPage({super.key});

  @override
  State<AdminProfilePageAndStudentAddPage> createState() =>
      _AdminProfilePageAndStudentAddPageState();
}

class _AdminProfilePageAndStudentAddPageState
    extends State<AdminProfilePageAndStudentAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text("Logout"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New Student.",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
