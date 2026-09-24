import 'dart:math' as math;

import '../domain/quran_surah.dart';

const _banglaDigits = '০১২৩৪৫৬৭৮৯';

String normalizeSurahQuery(String value) {
  return value
      .toLowerCase()
      .replaceAllMapped(
        RegExp('[০-৯]'),
        (match) => '${_banglaDigits.indexOf(match[0]!)}',
      )
      .replaceAll(RegExp(r"[\s\-_’']+"), '')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff\u0980-\u09ff]'), '');
}

List<QuranSurahSummary> rankSurahMatches(
  Iterable<QuranSurahSummary> surahs,
  String query,
) {
  final normalized = normalizeSurahQuery(query);
  if (normalized.isEmpty) return List.unmodifiable(surahs);
  final terms = query
      .trim()
      .split(RegExp(r'[\s\-_]+'))
      .map(normalizeSurahQuery)
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
  final scored = <({QuranSurahSummary surah, int score})>[];

  for (final surah in surahs) {
    var best = 0;
    for (final alias in _aliasesFor(surah)) {
      best = math.max(best, _score(normalized, terms, alias));
    }
    if (best > 0) scored.add((surah: surah, score: best));
  }

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.surah.number.compareTo(b.surah.number);
  });
  return List.unmodifiable(scored.map((entry) => entry.surah));
}

Set<String> _aliasesFor(QuranSurahSummary surah) {
  final aliases = <String>{
    '${surah.number}',
    normalizeSurahQuery(surah.nameArabic),
    normalizeSurahQuery(surah.nameEnglish),
    if (surah.nameBangla != null) normalizeSurahQuery(surah.nameBangla!),
  };
  for (final alias in aliases.toList(growable: false)) {
    if (alias.startsWith('al') && alias.length > 3)
      aliases.add(alias.substring(2));
    if (alias.startsWith('an') && alias.length > 3)
      aliases.add(alias.substring(2));
    if (alias.startsWith('আল') && alias.length > 3)
      aliases.add(alias.substring(2));
    aliases.add(_foldLatin(alias));
  }
  return aliases.where((alias) => alias.isNotEmpty).toSet();
}

int _score(String query, List<String> terms, String alias) {
  if (query == alias) return 100;
  if (alias.startsWith(query)) return 80;
  if (terms.length > 1 && terms.every((term) => _isSubsequence(term, alias))) {
    return 70;
  }
  if (alias.contains(query)) return 60;
  if (query.length < 4) return 0;

  final foldedQuery = _foldLatin(query);
  final foldedAlias = _foldLatin(alias);
  final distance = _levenshtein(foldedQuery, foldedAlias);
  final limit = math.max(1, foldedQuery.length ~/ 4);
  return distance <= limit ? 40 - distance : 0;
}

String _foldLatin(String value) {
  if (!RegExp('[a-z]').hasMatch(value)) return value;
  var folded = value.replaceAll('ph', 'f');
  folded = folded.replaceAll(RegExp(r'(.)\1+'), r'$1');
  if (folded.endsWith('ah')) folded = folded.substring(0, folded.length - 1);
  return folded;
}

bool _isSubsequence(String needle, String haystack) {
  var index = 0;
  for (final unit in haystack.codeUnits) {
    if (index < needle.length && unit == needle.codeUnitAt(index)) index++;
  }
  return index == needle.length;
}

int _levenshtein(String left, String right) {
  var previous = List<int>.generate(right.length + 1, (index) => index);
  for (var row = 1; row <= left.length; row++) {
    final current = List<int>.filled(right.length + 1, 0)..[0] = row;
    for (var column = 1; column <= right.length; column++) {
      final substitution =
          previous[column - 1] +
          (left.codeUnitAt(row - 1) == right.codeUnitAt(column - 1) ? 0 : 1);
      current[column] = math.min(
        math.min(current[column - 1] + 1, previous[column] + 1),
        substitution,
      );
    }
    previous = current;
  }
  return previous.last;
}
