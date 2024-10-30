import 'package:flutter/material.dart';

import '../Common/login_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() =>
      _AdminProfilePageState();
}

class _AdminProfilePageState
    extends State<AdminProfilePage> {
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }
}
