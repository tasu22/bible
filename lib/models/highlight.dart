import 'dart:convert';

class Highlight {
  final String bookName;
  final int chapter;
  final String verseNumber;
  final String verseText;
  final bool isSwahili;
  final String? note;

  Highlight({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.isSwahili,
    this.note,
  });

  Highlight copyWith({
    String? bookName,
    int? chapter,
    String? verseNumber,
    String? verseText,
    bool? isSwahili,
    String? note,
  }) {
    return Highlight(
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      verseText: verseText ?? this.verseText,
      isSwahili: isSwahili ?? this.isSwahili,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookName': bookName,
      'chapter': chapter,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'isSwahili': isSwahili,
      'note': note,
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      bookName: map['bookName'],
      chapter: map['chapter'],
      verseNumber: map['verseNumber'],
      verseText: map['verseText'],
      isSwahili: map['isSwahili'],
      note: map['note'],
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
        other.isSwahili == isSwahili &&
        other.note == note;
  }

  @override
  int get hashCode {
    return bookName.hashCode ^
        chapter.hashCode ^
        verseNumber.hashCode ^
        isSwahili.hashCode ^
        note.hashCode;
  }
}
