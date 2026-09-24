import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/database_providers.dart';
import '../../../core/database/user_database.dart';

abstract class BengaliWordMeanings {
  Future<String?> meaningFor(String ayahKey, int position);
  Future<bool> isSurahDownloaded(int surahNumber) async => false;
  Future<void> downloadSurah(
    int surahNumber,
    int ayahCount, {
    void Function(int completed, int total)? onProgress,
  }) => throw UnimplementedError();
}

/// Loads display-only Bengali word glosses; canonical Quran rows stay intact.
class QuranComBengaliWordMeanings implements BengaliWordMeanings {
  QuranComBengaliWordMeanings(this._client, {UserDatabase? database})
    : _database = database;

  final http.Client _client;
  final UserDatabase? _database;
  final Map<String, Future<Map<int, String>>> _sessionCache = {};
  final Map<int, Map<String, Map<int, String>>> _downloadedCache = {};

  String _settingKey(int surahNumber) => 'bangla_word_surah_v1_$surahNumber';

  Future<Map<String, Map<int, String>>?> _downloaded(int surahNumber) async {
    final cached = _downloadedCache[surahNumber];
    if (cached != null) return cached;
    final raw = await _database?.getSetting(_settingKey(surahNumber));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final result = <String, Map<int, String>>{};
      for (final entry in decoded.entries) {
        result[entry.key] = {
          for (final word in (entry.value as Map<String, dynamic>).entries)
            int.parse(word.key): word.value as String,
        };
      }
      return _downloadedCache[surahNumber] = result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isSurahDownloaded(int surahNumber) async =>
      await _downloaded(surahNumber) != null;

  @override
  Future<void> downloadSurah(
    int surahNumber,
    int ayahCount, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (surahNumber < 1 ||
        surahNumber > 114 ||
        ayahCount < 1 ||
        _database == null)
      throw ArgumentError('Invalid Surah download.');
    if (await isSurahDownloaded(surahNumber)) return;
    final all = <String, Map<int, String>>{};
    var page = 1;
    while (true) {
      final uri = Uri.https(
        'api.quran.com',
        '/api/v4/verses/by_chapter/$surahNumber',
        {'words': 'true', 'language': 'bn', 'per_page': '50', 'page': '$page'},
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw StateError('Bengali word download failed.');
      }
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final verses = body['verses'] as List<dynamic>;
      if (verses.isEmpty) throw const FormatException('Empty Surah page.');
      for (final rawVerse in verses) {
        final verse = rawVerse as Map<String, dynamic>;
        final key = verse['verse_key'] as String?;
        if (key != '$surahNumber:${all.length + 1}') {
          throw const FormatException('Unexpected verse in Surah download.');
        }
        all[key!] = _parseWords(verse['words'] as List<dynamic>);
      }
      onProgress?.call(all.length, ayahCount);
      final pagination = body['pagination'] as Map<String, dynamic>;
      final next = pagination['next_page'];
      if (next == null) break;
      if (next is! int || next != page + 1 || page >= 20) {
        throw const FormatException('Invalid Surah pagination.');
      }
      page = next;
    }
    if (all.length != ayahCount) {
      throw StateError('The Surah download is incomplete.');
    }
    await _database.saveSetting(
      _settingKey(surahNumber),
      jsonEncode({
        for (final entry in all.entries)
          entry.key: {
            for (final word in entry.value.entries) '${word.key}': word.value,
          },
      }),
    );
    _downloadedCache[surahNumber] = all;
  }

  @override
  Future<String?> meaningFor(String ayahKey, int position) async {
    if (!RegExp(r'^\d{1,3}:\d{1,3}$').hasMatch(ayahKey) || position < 1) {
      throw FormatException('Invalid word location: $ayahKey:$position');
    }
    final surah = int.parse(ayahKey.split(':').first);
    final saved = await _downloaded(surah);
    if (saved != null) return saved[ayahKey]?[position];
    late final Map<int, String> meanings;
    try {
      meanings = await _sessionCache.putIfAbsent(
        ayahKey,
        () => _loadAyah(ayahKey),
      );
    } catch (_) {
      _sessionCache.remove(ayahKey);
      rethrow;
    }
    return meanings[position];
  }

  Future<Map<int, String>> _loadAyah(String ayahKey) async {
    final uri = Uri.https('api.quran.com', '/api/v4/verses/by_key/$ayahKey', {
      'words': 'true',
      'language': 'bn',
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Bengali word meanings are unavailable.');
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final verse = body['verse'] as Map<String, dynamic>;
    if (verse['verse_key'] != ayahKey) {
      throw const FormatException('The word response belongs to another ayah.');
    }
    return _parseWords(verse['words'] as List<dynamic>);
  }

  Map<int, String> _parseWords(List<dynamic> words) => {
    for (final item in words)
      if (item is Map<String, dynamic> && item['char_type_name'] == 'word')
        if (item['position'] is int && item['translation'] is Map)
          if ((item['translation']['text'] as String?)?.trim().isNotEmpty ==
              true)
            item['position'] as int: (item['translation']['text'] as String)
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .trim(),
  };
}

final bengaliWordMeaningsProvider = Provider<BengaliWordMeanings>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return QuranComBengaliWordMeanings(
    client,
    database: ref.watch(userDatabaseProvider),
  );
});
