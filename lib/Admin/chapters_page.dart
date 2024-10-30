import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:programmer_prodigies/Admin/view_pdf.dart';

class AdminChaptersPage extends StatefulWidget {
  final String subjectKey;

  const AdminChaptersPage(this.subjectKey, {super.key});

  @override
  State<AdminChaptersPage> createState() => _AdminChaptersPageState();
}

class _AdminChaptersPageState extends State<AdminChaptersPage> {
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

  List<Map> pdfs = [
    {"key": "1", "PdfName": "Book1", "ChapterName": "1"},
    {"key": "2", "PdfName": "Book1", "ChapterName": "2"},
    {"key": "3", "PdfName": "Book1", "ChapterName": "3"},
    {"key": "4", "PdfName": "Book1", "ChapterName": "4"},
    {"key": "5", "PdfName": "Book1", "ChapterName": "5"},
    {"key": "6", "PdfName": "Book1", "ChapterName": "6"},
  ];

  String viewMode = "Normal";

  Future<List<Map>> getPackagesData() async {
    return chapters;
  }

  void toggleViewMode() {
    setState(() {
      viewMode = viewMode == "Normal" ? "Edit" : "Normal";
    });
  }

  void handleCardTap(BuildContext context, int index) async {
    TextEditingController nameController =
        TextEditingController(text: chapters[index]["ChapterName"]);
    String pdfName = ''; // Variable to store the PDF file name

    if (viewMode == "Normal") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminViewChapterPDF(chapters[index]["key"]),
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
                      decoration: const InputDecoration(
                          hintText: 'Enter new chapter name'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null) {
                          setState(() {
                            pdfFile = File(result.files.single.path!);
                            pdfName = result.files.single.name; // Get PDF name
                            pdfs[index]["PdfName"] = pdfName;
                            setState((){});
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
                        chapters[index]["ChapterName"] = nameController.text;
                        // Save the PDF name or upload it to storage here as needed
                        chapters[index]["pdfName"] = pdfName;
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

  handleDoubleClick(BuildContext context, int index) {
    if (viewMode == "Edit") {
      if (chapters[index]["Visibility"] == "false") {
        // Show an AlertDialog for editing the subject name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Un-Restrict PDF'),
              content: const Text(
                  "Are you sure you want to Un-Restrict this PDF..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  // Close the dialog
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    chapters[index]["Visibility"] = "true";
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {});
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
              content:
                  const Text("Are you sure you want to Restrict this PDF..?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  // Close the dialog
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    chapters[index]["Visibility"] = "false";
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {});
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      }
    } else if (viewMode == "Normal") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Subject...!!'),
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
    final icon = viewMode == "Normal"
        ? FontAwesomeIcons.userPen
        : FontAwesomeIcons.check;

    // Filter chapters based on the subjectKey
    List<Map> filteredChapters = chapters
        .where(
            (chapter) => chapter["SubjectKey"] == widget.subjectKey.toString())
        .toList();

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
                    final subject = subjects.firstWhere(
                      (sub) => sub["key"] == chapter["SubjectKey"],
                      orElse: () => {},
                    );
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
                                title: const Text('Delete Subject...!!'),
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
                                        0.27,
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
                                              0.3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  "Semester: ${subject["semester"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  "Subject: ${subject["subject"]}",
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
                                                  "Chapters: ${chapter["ChapterName"]}",
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.025,
                                                child: Text(
                                                  "PDF Name: ${pdfs[index]["PdfName"]}",
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
