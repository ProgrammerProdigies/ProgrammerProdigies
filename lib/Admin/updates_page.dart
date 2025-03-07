import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/all_students.dart';
import 'package:programmerprodigies/Admin/registration_request.dart';

class AdminUpdatesPageWithTab extends StatefulWidget {
  const AdminUpdatesPageWithTab({super.key});

  @override
  State<AdminUpdatesPageWithTab> createState() =>
      _AdminUpdatesPageWithTabState();
}

class _AdminUpdatesPageWithTabState extends State<AdminUpdatesPageWithTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Students",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xff2a446b),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  "Pending Requests",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Tab(
                  child: Text(
                "All students",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(
              child: AdminRegistrationRequest(),
            ),
            Center(
              child: AdminAllStudents(),
            ),
          ],
        ),
      ),
    );
  }
}
