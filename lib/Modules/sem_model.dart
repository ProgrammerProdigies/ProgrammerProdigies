class SemModel {
  late String sem;

  SemModel( this.sem);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'Sem': sem,
  };
}