// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/Admin/profile_page.dart';
import 'package:programmer_prodigies/Admin/registration_request.dart';
import 'package:programmer_prodigies/Admin/semester_page.dart';

class BottomBar extends StatefulWidget {
  final int selectedIndex;
  const BottomBar(this.selectedIndex, {super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  late String username;
  late String email;
  final key = 'username';
  final key1 = 'email';
  late String firstName;
  late String userKey;
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    // _loadUserData();
    _widgetOptions = <Widget>[
      const Scaffold(
        backgroundColor: Colors.white,
        body: AdminSemesterPage(
            // firstname: firstName,
            ),
      ),
      const Scaffold(
        backgroundColor: Colors.white,
        body: AdminRegistrationRequest(),
      ),
      const Scaffold(
        backgroundColor: Colors.white,
        body: AdminProfilePageAndStudentAddPage(),
      ),
    ];
  }

  // Future<void> _loadUserData() async {
  //   String? userData = await getData(key);
  //   String? userEmail = await getData(key1);
  //   String? userFirstName = await getData("firstname");
  //   String? userKey = await getKey();
  //   setState(() {
  //     username = userData!;
  //     email = userEmail!;
  //     userKey = userKey!;
  //     firstName = userFirstName!;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: CurvedNavigationBar(
          height: MediaQuery.of(context).size.height * 0.08,
          backgroundColor: Colors.white,
          color: const Color(0xff2a446b),
          animationDuration: const Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            _buildIcon(Icons.home, 0),
            _buildIcon(Icons.watch_later_outlined, 1),
            _buildIcon(Icons.person_add_alt_1, 2),
          ],
          index: _selectedIndex, // Use 'index' instead of 'currentIndex'
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
