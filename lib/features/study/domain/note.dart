import 'bookmark.dart';

class Note {
  const Note({required this.target, required this.text, this.updatedAt});

  final StudyTarget target;
  final String text;
  final DateTime? updatedAt;
}
