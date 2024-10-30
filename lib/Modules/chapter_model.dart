class ChapterModel {
  late String chapterName;
  late String subject;
  late String semester;
  late String sem;


  ChapterModel(this.chapterName, this.subject, this.semester, this.sem);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'ChapterName': chapterName,
    'Subject': subject,
    'Semester': semester,
    'Sem': sem
  };
}