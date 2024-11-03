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
    pdfName = widget.chapterKey;
    pdfUrl =
        "https://firebasestorage.googleapis.com/v0/b/programmer-prodigies.appspot.com/o/ChapterPDF%2F$pdfName?alt=media&token=bb837505-f497-4448-b835-d0eaf2ea7791";
  }

  @override
  Widget build(BuildContext context) {
    print(pdfUrl);
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterKey),
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
