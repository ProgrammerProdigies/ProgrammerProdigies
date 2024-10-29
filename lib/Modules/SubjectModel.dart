class RegisterModel {
  late String subjectName;
  late String year;
  late String semester;



  RegisterModel(this.subjectName, this.year, this.semester);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'SubjectName': subjectName,
    'Year': year,
    'Semester': semester,
    };
}