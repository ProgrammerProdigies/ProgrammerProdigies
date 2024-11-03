import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/view_pdf.dart';
import 'add_new_chapter.dart';

class AdminChaptersPage extends StatefulWidget {
  final String subjectKey;

  const AdminChaptersPage(this.subjectKey, {super.key});

  @override
  State<AdminChaptersPage> createState() => _AdminChaptersPageState();
}

class _AdminChaptersPageState extends State<AdminChaptersPage> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblChapters');
  DatabaseReference subjectRef = FirebaseDatabase.instance.ref().child('ProgrammerProdigies/tblSubject');

  List<Map> subjects = [];
  List<Map> chapters = [];
  String viewMode = "Normal";

  Future<List<Map>> getPackagesData() async {
    List<Map> fetchedChapters = [];

    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      for (var entry in data.entries) {
        var chapter = entry.value;
        fetchedChapters.add({
          "key": entry.key,
          "SubjectKey": chapter["SubjectKey"],
          "chapterName": chapter["ChapterName"],
          "PDFName":chapter["PDFName"],
          "Visibility": chapter["Visibility"],
        });
      }
    }

    // Fetch subjects
    List<Map> subjectsData = await getSubjectsData();
    Map<String, Map> subjectsMap = { for (var subject in subjectsData) subject['SubjectKey']: subject };

    // Combine chapters with subject data
    for (var chapter in fetchedChapters) {
      if (subjectsMap.containsKey(chapter["SubjectKey"])) {
        var subjectData = subjectsMap[chapter["SubjectKey"]];
        chapter["Semester"] = subjectData?["Semester"];
        chapter["SubjectName"] = subjectData?["SubjectName"];
      }
    }

    return fetchedChapters;
  }

  Future<List<Map>> getSubjectsData() async {
    List<Map> fetchedSubjects = [];

    DatabaseEvent event = await subjectRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        fetchedSubjects.add({
          "SubjectKey": key,
          "Semester": value["Semester"],
          "SubjectName": value["SubjectName"],
        });
      });
    }

    return fetchedSubjects;
  }

  void toggleViewMode() {
    setState(() {
      viewMode = viewMode == "Normal" ? "Edit" : "Normal";
    });
  }


  handleDoubleClick(BuildContext context, int index) {
    if (viewMode == "Edit") {
      if (chapters[index]["Visibility"] == "false") {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Un-Restrict PDF'),
              content: const Text("Are you sure you want to Un-Restrict this PDF..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      chapters[index]["Visibility"] = "true";
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (chapters[index]["Visibility"] == "true") {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Restrict PDF'),
              content: const Text("Are you sure you want to Restrict this PDF..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      chapters[index]["Visibility"] = "false";
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = viewMode == "Normal" ? FontAwesomeIcons.userPen : FontAwesomeIcons.check;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Admin Chapters page",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: toggleViewMode,
            icon: FaIcon(icon),
          ),
        ],
      ),
      body: FutureBuilder<List<Map>>(
        future: getPackagesData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            chapters = snapshot.data!; // Update chapters with fetched data
            // Filter chapters based on the subjectKey
            List<Map> filteredChapters = chapters
                .where((chapter) => chapter["SubjectKey"] == widget.subjectKey)
                .toList();

            if (filteredChapters.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: filteredChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = filteredChapters[index];
                    return InkWell(
                      onTap: () => handleCardTap(context, index),
                      onLongPress: () {
                        if (viewMode == "Edit") {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Chapter...!!'),
                                content: Text(
                                    "Are you sure you want to delete ${chapter["ChapterName"]}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        chapters.removeWhere(
                                              (ch) =>
                                          ch["key"] ==
                                              chapters[index]["key"],
                                        );
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Edit Subject...!!'),
                                content: const Text(
                                    "You are not in edit mode. Please start edit mode from top right side."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Ok'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      onDoubleTap: () {
                        setState(() {
                          handleDoubleClick(context, index);
                        });
                      },
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
                                    width: MediaQuery.of(context).size.width *
                                        0.2,
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
                                              0.25,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  "Subject: ${chapter["SubjectName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.025,
                                                child: Text(
                                                  "Chapters: ${chapter["chapterName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.025,
                                                child: Text(
                                                  "PDF Name: ${chapter["PDFName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
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
              return buildNoChaptersFound();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminAddNewChapter(widget.subjectKey)),
          );
        },
        backgroundColor: const Color(0xff2a446b),
        tooltip: "Add New Chapter.",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void handleCardTap(BuildContext context, int index) async {
    TextEditingController nameController =
    TextEditingController(text: chapters[index]["chapterName"]);
    String pdfName = '';

    if (viewMode == "Normal") {
      // Pass chapterName to AdminViewChapterPDF
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminViewChapterPDF(
              chapters[index]["PDFName"]// Pass chapterName
          ),
        ),
      );
    } else if (viewMode == "Edit") {
      // Existing code for edit mode
      File? pdfFile;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Edit Chapter Name and Upload PDF'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          hintText: 'Enter new chapter name'
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null) {
                          setState(() {
                            pdfFile = File(result.files.single.path!);
                            pdfName = result.files.single.name; // Get PDF name
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload PDF"),
                    ),
                    if (pdfFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Selected PDF: $pdfName",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        chapters[index]["chapterName"] = nameController.text;
                        // Save the PDF name or upload it to storage here as needed
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Widget buildNoChaptersFound() {
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
}
