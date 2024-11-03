// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:programmer_prodigies/Models/chapter_model.dart';

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
  String? pdfName;  // Store the uploaded PDF URL
  late String fileName;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblChapters');

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
      fileName = '${chapterNameController.text.replaceAll(' ', '_')}.pdf'; // Use chapter name as filename, replace spaces with underscores
      Reference ref = FirebaseStorage.instance.ref('ChapterPDF/$fileName');

      await ref.putFile(file);
      pdfName = fileName;
    } catch (e) {
      rethrow; // Propagate the error
    }
  }


  Future<void> submitChapter() async {
    if (_formKey.currentState!.validate() && pdfPath != null) {
      try {
        await uploadPdf(); // Upload the PDF first

        // Create an instance of ChapterModel
        ChapterModel newChapter = ChapterModel(
          chapterNameController.text,
          widget.subjectKey,
          true, // Assuming you want the chapter to be visible by default
          pdfName!, // Include the uploaded PDF URL
        );

        // Add the chapter data to the database using the toJson method
        await dbRef.push().set(newChapter.toJson());

        // Clear the input fields
        chapterNameController.clear();
        setState(() {
          pdfPath = null;
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        // Handle errors during upload or database write
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
