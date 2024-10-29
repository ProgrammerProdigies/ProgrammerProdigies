class RegisterModel {
  late String chapterName;
  late String subject;
  late String semester;
  late String year;


  RegisterModel(this.chapterName, this.subject, this.semester, this.year);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'ChapterName': chapterName,
    'Subject': subject,
    'Semester': semester,
    'Year': year
  };
}