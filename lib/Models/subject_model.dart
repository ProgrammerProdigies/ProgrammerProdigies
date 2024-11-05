class SubjectModel {
  late String semester;
  late String subjectName;
  late String category;
  late String visibility;

  SubjectModel(this.subjectName, this.semester, this.category, this.visibility);

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{
        'SubjectName': subjectName,
        'Semester': semester,
        'Category': category,
        'Visibility': visibility
      };

  @override
  String toString() {
    return 'SubjectModel{subjectName: $subjectName, semester: $semester, Category: $category, Visibility: $visibility}';
  }
}
