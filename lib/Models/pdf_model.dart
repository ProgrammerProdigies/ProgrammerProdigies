class PdfModel {
  late String pdfName;
  late String chapterName;


  PdfModel(this.pdfName,this.chapterName);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'PdfName':pdfName,
    'ChapterName': chapterName,
  };

  @override
  String toString() {
    return 'PdfModel{PdfName: $pdfName, ChapterName: $chapterName}';
  }
}