class ChapterModel {
  late String chapterName;
  late String subject;
  late bool visible;

  ChapterModel(this.chapterName, this.subject, this.visible);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'ChapterName': chapterName,
        'SubjectKey': subject,
        'Visibility': visible
      };

  @override
  String toString() {
    return 'ChapterModel{chapterName: $chapterName, subject: $subject, Visibility: $visible}';
  }
}
