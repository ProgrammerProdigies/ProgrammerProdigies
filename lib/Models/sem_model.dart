class SemesterModel {
  late String sem;
  late String visible;

  SemesterModel(this.sem, this.visible);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'Semester': sem,
        'Visibility': visible,
      };

  @override
  String toString() {
    return 'SemModel{sem: $sem, Visibility: $visible}';
  }
}
