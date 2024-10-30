class SubjectModel {
  late String semester;
  late String subjectName;

  SubjectModel(this.subjectName, this.semester);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'SubjectName': subjectName,
        'Semester': semester,
      };

  @override
  String toString() {
    return 'SubjectModel{subjectName: $subjectName, semester: $semester}';
  }
}
