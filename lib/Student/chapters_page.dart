import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Student/view_pdf.dart';

class StudentChaptersPage extends StatefulWidget {
  final String subjectKey;

  const StudentChaptersPage(this.subjectKey, {super.key});

  @override
  State<StudentChaptersPage> createState() => _StudentChaptersPageState();
}

class _StudentChaptersPageState extends State<StudentChaptersPage> {
  List<Map> subjects = [
    {"key": "1", "semester": "1", "subject": "OS"},
    {"key": "2", "semester": "2", "subject": "CPPM"},
    {"key": "3", "semester": "3", "subject": ".Net"},
    {"key": "4", "semester": "4", "subject": "WDC"},
    {"key": "5", "semester": "5", "subject": "Java"},
    {"key": "6", "semester": "6", "subject": "Networking"},
  ];

  List<Map> chapters = [
    {
      "key": "1",
      "SubjectKey": "1",
      "ChapterName": "OS Introduction",
      "Visibility": "true"
    },
    {
      "key": "2",
      "SubjectKey": "1",
      "ChapterName": "OS Basic concepts",
      "Visibility": "false"
    },
    {
      "key": "3",
      "SubjectKey": "2",
      "ChapterName": "CPPM Introduction",
      "Visibility": "true"
    },
    {
      "key": "4",
      "SubjectKey": "2",
      "ChapterName": "CPPM Basic concepts",
      "Visibility": "false"
    },
    {
      "key": "5",
      "SubjectKey": "3",
      "ChapterName": ".Net Introduction",
      "Visibility": "true"
    },
    {
      "key": "6",
      "SubjectKey": "3",
      "ChapterName": ".Net Basic concepts",
      "Visibility": "true"
    },
    {
      "key": "7",
      "SubjectKey": "4",
      "ChapterName": "WDC Introduction",
      "Visibility": "true"
    },
    {
      "key": "8",
      "SubjectKey": "4",
      "ChapterName": "WDC Basic concepts",
      "Visibility": "true"
    },
  ];

  Future<List<Map>> getPackagesData() async {
    return chapters;
  }

  void handleCardTap(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentViewChapterPDF(chapters[index]["key"]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map> filteredChapters = chapters
        .where((chapter) =>
            chapter["SubjectKey"] == widget.subjectKey.toString() &&
            chapter["Visibility"] == "true")
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Student Chapters page",
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
                padding: const EdgeInsets.all(10),
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
                    final subject = subjects.firstWhere(
                      (sub) => sub["key"] == chapter["SubjectKey"],
                      orElse: () => {},
                    );
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
                                    width: MediaQuery.of(context).size.width * 0.27,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.width * 0.2,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  "Semester: ${subject["semester"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  "Subject: ${subject["subject"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.03,
                                                child: Text(
                                                  "Chapters: ${chapter["ChapterName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                  softWrap: true,
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
