class SubjectModel {
  late String semester;
  late String subjectName;
  late String category;

  SubjectModel(this.subjectName, this.semester, this.category);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'SubjectName': subjectName,
        'Semester': semester,
        'Category': category
      };

  @override
  String toString() {
    return 'SubjectModel{subjectName: $subjectName, semester: $semester, Category: $category}';
  }
}
