// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:programmerprodigies/Admin/chapters_page.dart';
import 'package:programmerprodigies/Models/chapter_model.dart';

// class ChapterModel {
//   late String chapterName;
//   late String subject;
//   late bool visible;
//   String? pdfUrl; // Optional PDF URL field
//
//   ChapterModel(this.chapterName, this.subject, this.visible, {this.pdfUrl});
//
//   Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
//     'ChapterName': chapterName,
//     'SubjectKey': subject,
//     'Visibility': visible,
//     'PdfUrl': pdfUrl,
//   };
//
//   @override
//   String toString() {
//     return 'ChapterModel{chapterName: $chapterName, subject: $subject, Visibility: $visible, PdfUrl: $pdfUrl}';
//   }
// }

class AdminAddNewChapter extends StatefulWidget {
  final String subjectKey;

  const AdminAddNewChapter(this.subjectKey, {super.key});

  @override
  State<AdminAddNewChapter> createState() => _AdminAddNewChapterState();
}

class _AdminAddNewChapterState extends State<AdminAddNewChapter> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController chapterNameController = TextEditingController();
  String? pdfPath; // Store the selected PDF file path
  String? pdfName; // Store the uploaded PDF URL
  late String fileName;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('programmerProdigies/tblChapters');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Chapter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: chapterNameController,
                decoration: const InputDecoration(labelText: 'Chapter Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chapter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectPdf,
                child: const Text('Select PDF File'),
              ),
              const SizedBox(height: 10),
              Text(pdfPath != null ? pdfPath! : 'No file selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitChapter,
                child: const Text('Add Chapter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfPath = result.files.single.path;
      });
    }
  }

  Future<void> uploadPdf() async {
    if (pdfPath == null) return;

    File file = File(pdfPath!);
    try {
      fileName =
          '${chapterNameController.text.replaceAll(' ', '_')}.pdf'; // Use chapter name as filename, replace spaces with underscores
      Reference ref = FirebaseStorage.instance.ref('ChapterPDF/$fileName');

      await ref.putFile(file);
      pdfName = fileName;
    } catch (e) {
      rethrow; // Propagate the error
    }
  }

  Future<void> submitChapter() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email != 'programmerprodigies@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unauthorized access! Admin rights required.')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && pdfPath != null) {
      try {
        await uploadPdf(); // Upload the PDF first

        ChapterModel newChapter = ChapterModel(
          chapterNameController.text,
          widget.subjectKey,
          true, // Visible by default
          pdfName!,
        );

        // Add chapter to database
        await dbRef.push().set(newChapter.toJson());

        // Success Message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter added successfully!')),
        );

        // Navigate to Chapters Page
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminChaptersPage(widget.subjectKey),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a PDF.')),
      );
    }
  }
}
