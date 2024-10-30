class SubjectModel {
  late String subjectName;
  late String year;
  late String semester;



  SubjectModel(this.subjectName, this.year, this.semester);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'SubjectName': subjectName,
    'Year': year,
    'Semester': semester,
    };
}