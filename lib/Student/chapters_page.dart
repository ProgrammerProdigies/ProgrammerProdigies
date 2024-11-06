import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Student/view_pdf.dart';

class StudentChaptersPage extends StatefulWidget {
  final String subjectKey;
  final String subjectName;
  final String studentSemester;

  const StudentChaptersPage(
      this.subjectKey, this.subjectName, this.studentSemester,
      {super.key});

  @override
  State<StudentChaptersPage> createState() => _StudentChaptersPageState();
}

class _StudentChaptersPageState extends State<StudentChaptersPage> {
  List<Map> chapters = [];
  List<Map> semester = [];

  List<Map> filteredChapters = [];
  List<Map> filteredSemester = [];

  Object? data;

  Future<List<Map>> getPackagesData() async {
    getSemester();
    chapters.clear();
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblChapters');

    await dbRef.once().then((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        values.forEach((key, value) {
          chapters.add({
            "key": key,
            "ChapterName": value["ChapterName"],
            "PDFName": value["PDFName"],
            "Visibility": value["Visibility"],
            "SubjectKey": value["SubjectKey"],
          });
        });
      }
    });
    filteredChapters = chapters
        .where((chapter) =>
            chapter["SubjectKey"] == widget.subjectKey.toString() &&
            chapter["Visibility"] == true)
        .toList();
    return chapters;
  }

  Future<void> getSemester() async {
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child('ProgrammerProdigies/tblSemester/${widget.studentSemester}');
    DatabaseEvent databaseEventStudent = await dbRef.once();
    DataSnapshot dataSnapshotStudent = databaseEventStudent.snapshot;
    for (var x in dataSnapshotStudent.children) {
      data = x.value;
      if (data.toString().contains("Semester")) {
        break;
      }
    }
  }

  void handleCardTap(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StudentViewChapterPDF(filteredChapters[index]["PDFName"]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Chapters",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map>>(
        future: getPackagesData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (filteredChapters.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(1),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: filteredChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = filteredChapters[index];
                    return InkWell(
                      onTap: () => handleCardTap(context, index),
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff2a446b),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/Logo/Programmer.png",
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(0),
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.width * 0.2,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text(
                                                          "Semester: $data",
                                                          style: const TextStyle(
                                                            fontSize: 15.5,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text(
                                                          "Subject: ${widget.subjectName}",
                                                          style: const TextStyle(
                                                            fontSize: 15.5,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          "Chapters: ${chapter["ChapterName"]}",
                                                          style: const TextStyle(
                                                            fontSize: 15.5,
                                                            color: Colors.white,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (chapter["Visibility"] == "false")
                            // Overlay for restricted access
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  // Dark overlay
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Restricted",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
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
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
