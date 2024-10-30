class SemModel {
  late String sem;

  SemModel(this.sem);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'Sem': sem,
      };

  @override
  String toString() {
    return 'SemModel{sem: $sem}';
  }
}
