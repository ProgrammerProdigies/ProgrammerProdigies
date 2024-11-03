class ChapterModel {
  late String chapterName;
  late String subject;
  late String pdfName;
  late bool visible;

  ChapterModel(this.chapterName, this.subject, this.visible, this.pdfName);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'ChapterName': chapterName,
        'SubjectKey': subject,
        'PDFName': pdfName,
        'Visibility': visible
      };

  @override
  String toString() {
    return 'ChapterModel{chapterName: $chapterName, subject: $subject, Visibility: $visible, PDFName: $pdfName}';
  }
}
