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
  List<Map> subjects = [
    {"key": "1", "semester": "1", "subject": "OS"},
    {"key": "2", "semester": "2", "subject": "CPPM"},
    {"key": "3", "semester": "3", "subject": ".Net"},
    {"key": "4", "semester": "4", "subject": "WDC"},
    {"key": "5", "semester": "5", "subject": "Java"},
    {"key": "6", "semester": "6", "subject": "Networking"},
  ];

  List<Map> chapters = [
    {"key": "1", "SubjectKey": "1", "ChapterName": "OS Introduction", "Visibility":true},
    {"key": "2", "SubjectKey": "1", "ChapterName": "OS Basic concepts", "Visibility":false},
    {"key": "3", "SubjectKey": "2", "ChapterName": "CPPM Introduction", "Visibility":true},
    {"key": "4", "SubjectKey": "2", "ChapterName": "CPPM Basic concepts", "Visibility":false},
    {"key": "5", "SubjectKey": "3", "ChapterName": ".Net Introduction", "Visibility":true},
    {"key": "6", "SubjectKey": "3", "ChapterName": ".Net Basic concepts", "Visibility":false},
    {"key": "7", "SubjectKey": "4", "ChapterName": "WDC Introduction", "Visibility":true},
    {"key": "8", "SubjectKey": "4", "ChapterName": "WDC Basic concepts", "Visibility":false},
  ];

  List<Map> pdfs = [
    {"key": "1", "PdfName": "Book1", "ChapterName": "1"},
    {"key": "2", "PdfName": "Book1", "ChapterName": "2"},
    {"key": "3", "PdfName": "Book1", "ChapterName": "3"},
    {"key": "4", "PdfName": "Book1", "ChapterName": "4"},
    {"key": "5", "PdfName": "Book1", "ChapterName": "5"},
    {"key": "6", "PdfName": "Book1", "ChapterName": "6"},
  ];

  String chapterName = '';
  String subjectName = '';
  String? pdfName;
  String? pdfUrl;

  @override
  void initState() {
    super.initState();
    fetchChapterAndSubjectDetails();
  }

  void fetchChapterAndSubjectDetails() {
    // Find the chapter based on chapterKey
    final chapter = chapters.firstWhere(
      (ch) => ch["key"] == widget.chapterKey
    );

    if (chapter.isNotEmpty) {
      chapterName = chapter["ChapterName"] ?? "Unknown Chapter";

      // Find the subject based on SubjectKey in the chapter
      final subject = subjects.firstWhere(
        (sub) => sub["key"] == chapter["SubjectKey"],
        orElse: () => {},
      );

      subjectName = subject["subject"] ?? "Unknown Subject";

      // Find the PDF URL based on ChapterName in the pdfs list
      final pdf = pdfs.firstWhere(
        (pdf) => pdf["ChapterName"] == widget.chapterKey,
        orElse: () => {},
      );

      pdfName = pdf["PdfName"];
      pdfUrl =
          "https://firebasestorage.googleapis.com/v0/b/programmer-prodigies.appspot.com/o/ChapterPDF%2F$pdfName.pdf?alt=media&token=bb837505-f497-4448-b835-d0eaf2ea7791";
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    return Scaffold(
      appBar: AppBar(
        title: Text(chapterName),
      ),
      body: pdfUrl != null
          ? SfPdfViewer.network(pdfUrl!)
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
                    'No Chapters found',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
