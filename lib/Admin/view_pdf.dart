// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AdminViewChapterPDF extends StatefulWidget {
  final String chapterKey;

  const AdminViewChapterPDF(this.chapterKey, {super.key});

  @override
  State<AdminViewChapterPDF> createState() => _AdminViewChapterPDFState();
}

class _AdminViewChapterPDFState extends State<AdminViewChapterPDF> {
  String? pdfUrl; // Final URL to be fetched
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    fetchPDFUrl();
  }

  // Fetch Signed URL for the PDF
  Future<void> fetchPDFUrl() async {
    try {
      // Ensure user is authenticated
      User? user = FirebaseAuth.instance.currentUser;
      if (user?.email != "programmerprodigies@gmail.com") {
        throw Exception('User not authenticated');
      }
      // Reference to the PDF in Firebase Storage
      final Reference ref = FirebaseStorage.instance
          .ref('ChapterPDF/${widget.chapterKey}');

      // Generate a signed URL valid for 1 hour (3600 seconds)
      pdfUrl = await ref.getDownloadURL();

      setState(() {
        isLoading = false; // Stop loading after fetching the URL
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching PDF URL: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterKey),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : pdfUrl != null
          ? SfPdfViewer.network(pdfUrl!) // Display PDF
          : Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/Animation/no_data_found.json',
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.3,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text(
              'No PDF found',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
