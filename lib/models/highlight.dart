import 'dart:convert';

class Highlight {
  final String bookName;
  final int chapter;
  final String verseNumber;
  final String verseText;
  final bool isSwahili;

  Highlight({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.isSwahili,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookName': bookName,
      'chapter': chapter,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'isSwahili': isSwahili,
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      bookName: map['bookName'],
      chapter: map['chapter'],
      verseNumber: map['verseNumber'],
      verseText: map['verseText'],
      isSwahili: map['isSwahili'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Highlight.fromJson(String source) =>
      Highlight.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Highlight &&
        other.bookName == bookName &&
        other.chapter == chapter &&
        other.verseNumber == verseNumber &&
        other.isSwahili == isSwahili;
  }

  @override
  int get hashCode {
    return bookName.hashCode ^
        chapter.hashCode ^
        verseNumber.hashCode ^
        isSwahili.hashCode;
  }
}
