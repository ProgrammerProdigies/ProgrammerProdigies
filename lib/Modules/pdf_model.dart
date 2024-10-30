class PdfModel {
  late String PdfName;
  late String chapterName;
  late String subjectName;
  late String semester;


  PdfModel(this.PdfName,this.chapterName, this.subjectName, this.semester);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'PdfNo':PdfName,
    'ChapterName': chapterName,
    'Subject': subjectName,
    'Semester': semester,
  };
}