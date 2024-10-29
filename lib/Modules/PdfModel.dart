class PdfModel {
  late String PdfNo;
  late String chapterName;
  late String subject;
  late String semester;
  late String year;


  PdfModel(this.PdfNo,this.chapterName, this.subject, this.semester, this.year);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'PdfNo':PdfNo,
    'ChapterName': chapterName,
    'Subject': subject,
    'Semester': semester,
    'Year': year
  };
}