class SemesterModel {
  late String sem;
  late int theoryPrice;
  late int practicalPrice;
  late int papersPrice;
  late int theoryAndPracticalPrice;
  late int allPrice;
  late String visible;

  SemesterModel(
      this.sem,
      this.theoryPrice,
      this.practicalPrice,
      this.papersPrice,
      this.theoryAndPracticalPrice,
      this.allPrice,
      this.visible);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'Semester': sem,
        'TheoryPrice': theoryPrice,
        'PracticalPrice': practicalPrice,
        'PapersPrice': papersPrice,
        'TheoryAndPracticalPrice': theoryAndPracticalPrice,
        'AllPrice': allPrice,
        'Visibility': visible,
      };

  @override
  String toString() {
    return 'SemesterModel{sem: $sem, theoryPrice: $theoryPrice, practicalPrice: $practicalPrice, papersPrice: $papersPrice, theoryAndPracticalPrice: $theoryAndPracticalPrice, allPrice: $allPrice, visible: $visible}';
  }
}
