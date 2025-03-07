// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../saveSharePreferences.dart';
import 'home_page.dart';

class StudentPaymentPage extends StatefulWidget {
  final int total;
  final Map<String, List<String>>
      selectedData; // Updated to accept selectedData

  const StudentPaymentPage(this.total, this.selectedData, {super.key});

  @override
  State<StudentPaymentPage> createState() => _StudentPaymentPageState();
}

class _StudentPaymentPageState extends State<StudentPaymentPage> {
  var imagePath = "";
  var dbRef = FirebaseDatabase.instance.ref().child("ProgrammerProdigies/tblAdmin");

  var firstName = "";
  var lastname = "";
  var semesterName = "";
  var studentKey = "";

  Future getImage() async {
    // Reference to the PDF in Firebase Storage
    final Reference ref = FirebaseStorage.instance.ref('QRCode/QR.jpg');
    // Generate a signed URL valid for 1 hour (3600 seconds)
    imagePath = await ref.getDownloadURL();
    firstName = (await getData("FirstName"))!;
    lastname = (await getData("LastName"))!;
    studentKey = (await getKey())!;
    semesterName = (await getData("SemesterName"))!;
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2a446b),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: getImage(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (imagePath.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Package summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Display Selected Subjects by Group
                  const Text(
                    "Selected Subjects:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: widget.selectedData.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Name
                            Text(
                              "${entry.key}:",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Subjects in the Group
                            ...entry.value.map((subject) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    "- $subject",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                )),
                            const SizedBox(height: 10), // Space between groups
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Display Total Amount
                  Text(
                    "Total Payable: ₹${widget.total}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: SliderButton(
                      action: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Payment QR code"),
                              content: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.37,
                                child: Column(
                                  children: [
                                    Text(
                                      "Please pay ₹${widget.total} INR on below QR code and click on next to send payment screenshot on whatsapp.",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Image.network(
                                      imagePath,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.28,
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    String requestFor = widget.selectedData.keys
                                        .toString()
                                        .replaceAll("(", "")
                                        .replaceAll(")", "")
                                        .replaceAll(",", " and");
                                    await launchWhatsApp();

                                    final updatedData = {
                                      "RequestFor": requestFor
                                    };
                                    final studentRef = FirebaseDatabase.instance
                                        .ref()
                                        .child("ProgrammerProdigies/tblStudent")
                                        .child(studentKey);
                                    await studentRef.update(updatedData);

                                    if (mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StudentHomePage(),
                                        ),
                                      );
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Thank you for paying"),
                                          content: const Text(
                                            "Our team will give you access within 3 hours.",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Ok"),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text("Next"),
                                ),
                              ],
                            );
                          },
                          barrierDismissible: false,
                        );
                        return false;
                      },
                      label: Text(
                        "Slide to Pay ₹${widget.total}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 17),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      buttonColor: const Color(0xff2a446b),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> launchWhatsApp() async {
    String url;
    if (Platform.isIOS) {
      url =
          'https://wa.me/+918849165682?text=${Uri.encodeFull("Hello, My name is *$firstName $lastname*\nI have paid *${widget.total}/-* for *$semesterName* with *${widget.selectedData.keys.toString().replaceAll("(", "").replaceAll(")", "").replaceAll(",", " and")}* here is the screenshot.")}';
    } else {
      url =
          'whatsapp://send?phone=+918849165682&text=${Uri.encodeFull("Hello, My name is *$firstName $lastname*\nI have paid *${widget.total}/-* for *$semesterName* with *${widget.selectedData.keys.toString().replaceAll("(", "").replaceAll(")", "").replaceAll(",", " and")}* here is the screenshot.")}';
    }
    await launchUrl(Uri.parse(url));
  }
}
