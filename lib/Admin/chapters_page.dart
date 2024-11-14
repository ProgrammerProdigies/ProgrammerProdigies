// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmerprodigies/Admin/view_pdf.dart';
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
  final FirebaseStorage storage = FirebaseStorage.instance;

  List<Map> subjects = [];
  List<Map> chapters = [];
  List<Map> filteredChapters = [];
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
          "PDFName": chapter["PDFName"],
          "Visibility": chapter["Visibility"],
        });
      }
    }

    // Fetch subjects
    List<Map> subjectsData = await getSubjectsData();
    Map<String, Map> subjectsMap = {for (var subject in subjectsData) subject['SubjectKey']: subject};

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

  void handleDoubleClick(BuildContext context, int index) {
    String chapterKey = chapters[index]["key"];
    if (viewMode == "Edit") {
      String newVisibility = chapters[index]["Visibility"] == "false" ? "true" : "false";

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(newVisibility == "true" ? 'Un-Restrict PDF' : 'Restrict PDF'),
            content: Text("Are you sure you want to ${newVisibility == "true" ? 'Un-Restrict' : 'Restrict'} this PDF?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  // Update local state
                  setState(() {
                    chapters[index]["Visibility"] = newVisibility;
                  });
                  // Update in the database
                  await dbRef.child(chapterKey).update({"Visibility": newVisibility});
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    } else if (viewMode == "Normal") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Restrict subject...!!'),
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
  }

  @override
  Widget build(BuildContext context) {
    final icon = viewMode == "Normal" ? FontAwesomeIcons.userPen : FontAwesomeIcons.check;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          "Admin Chapters Page",
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
            filteredChapters = chapters
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
                                content: Text("Are you sure you want to delete ${chapter["chapterName"]} and its PDF?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Construct the path to the PDF in Firebase Storage
                                      String pdfPath = 'ChapterPDF/${chapter["PDFName"]}';

                                      try {
                                        // Delete the PDF from Firebase Storage
                                        await storage.ref(pdfPath).delete();

                                        // Remove the chapter from the database
                                        await dbRef.child(chapter["key"]).remove();

                                        // Update local state
                                        setState(() {
                                          chapters.removeWhere((ch) => ch["key"] == chapter["key"]);
                                        });

                                        // Show a success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${chapter["chapterName"]} deleted successfully.')),
                                        );
                                      } catch (e) {
                                        // Handle any errors here
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error deleting chapter: $e')),
                                        );
                                      }

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Handle the case when not in edit mode
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Edit Subject...!!'),
                                content: const Text("You are not in edit mode. Please start edit mode from the top right side."),
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
                          handleDoubleClick(context, index);
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
                                    width: MediaQuery.of(context).size.width * 0.2,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.width * 0.25,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  "Subject: ${chapter["SubjectName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.025,
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
                                                height: MediaQuery.of(context).size.height * 0.025,
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
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminAddNewChapter(widget.subjectKey)),
          );
        },
        backgroundColor: const Color(0xff2a446b),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
  // work here
  void handleCardTap(BuildContext context, int index) async {
    TextEditingController nameController = TextEditingController(text: chapters[index]["chapterName"]);
    String pdfName = '';

    if (viewMode == "Normal") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminViewChapterPDF(filteredChapters[index]["PDFName"]),
        ),
      );
    } else if (viewMode == "Edit") {
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
                      decoration: const InputDecoration(hintText: 'Enter new chapter name'),
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
                    onPressed: () async {
                      // Update local state
                      setState(() {
                        chapters[index]["chapterName"] = nameController.text;
                        if (pdfFile != null) {
                          chapters[index]["PDFName"] = pdfName; // Update the local state with new PDF name
                        }
                      });
                      // Update in the database
                      await dbRef.child(chapters[index]["key"]).update({
                        "ChapterName": nameController.text,
                        if (pdfFile != null) "PDFName": pdfName, // Only update if a new file is selected
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
}
