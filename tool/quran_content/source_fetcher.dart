import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../lib/features/quran/domain/canonical_quran_counts.dart';

const quranEncZakariaKey = 'bengali_zakaria';
const quranEncZakariaCatalogVersion = '1.1.1';
const quranEncZakariaCatalogLastUpdate = '2021-05-22';
const primaryBanglaTranslationResourceId = 1;

class NormalizedQuranDocuments {
  const NormalizedQuranDocuments({required this.quran, required this.words});

  final Map<String, dynamic> quran;
  final Map<String, dynamic> words;
}

class VerifiedSourceDocuments {
  const VerifiedSourceDocuments({
    required this.quran,
    required this.words,
    required this.translation,
  });

  final Map<String, dynamic> quran;
  final Map<String, dynamic> words;
  final Map<String, dynamic> translation;
}

NormalizedQuranDocuments normalizeQuranFoundationDocuments({
  required List<Map<String, dynamic>> chapters,
  required Map<int, List<Map<String, dynamic>>> versesByChapter,
  required String contentVersion,
  required String sourceVersion,
}) {
  if (chapters.isEmpty) {
    throw const FormatException('Quran Foundation returned no chapters.');
  }

  final normalizedSurahs = <Map<String, dynamic>>[];
  final normalizedAyahs = <Map<String, dynamic>>[];
  final normalizedWords = <Map<String, dynamic>>[];

  final sortedChapters = [...chapters]
    ..sort((a, b) => _requiredInt(a, 'id').compareTo(_requiredInt(b, 'id')));

  for (final chapter in sortedChapters) {
    final chapterNumber = _requiredInt(chapter, 'id');
    final expectedAyahCount = _requiredInt(chapter, 'verses_count');
    final verses = [...?versesByChapter[chapterNumber]]
      ..sort(
        (a, b) => _requiredInt(
          a,
          'verse_number',
        ).compareTo(_requiredInt(b, 'verse_number')),
      );

    if (verses.length != expectedAyahCount) {
      throw FormatException(
        'Surah $chapterNumber expected $expectedAyahCount ayahs but '
        'received ${verses.length}.',
      );
    }
    if (verses.isEmpty) {
      throw FormatException('Surah $chapterNumber has no ayahs.');
    }

    final pageNumbers = verses
        .map((verse) => _requiredInt(verse, 'page_number'))
        .toList(growable: false);
    final juzNumbers = verses
        .map((verse) => _requiredInt(verse, 'juz_number'))
        .toList(growable: false);

    normalizedSurahs.add({
      'number': chapterNumber,
      'name_arabic': _requiredString(chapter, 'name_arabic'),
      'name_english': _requiredString(chapter, 'name_simple'),
      'name_bangla': null,
      'revelation_place': _optionalString(chapter, 'revelation_place'),
      'ayah_count': expectedAyahCount,
      'page_start': pageNumbers.reduce(_min),
      'page_end': pageNumbers.reduce(_max),
      'juz_start': juzNumbers.first,
    });

    for (final verse in verses) {
      final verseChapter = _optionalInt(verse, 'chapter_id') ?? chapterNumber;
      final ayahNumber = _requiredInt(verse, 'verse_number');
      if (verseChapter != chapterNumber) {
        throw FormatException(
          'Verse ${verse['verse_key']} belongs to Surah $verseChapter but '
          'was returned under Surah $chapterNumber.',
        );
      }

      final verseKey = _requiredString(verse, 'verse_key');
      if (verseKey != '$chapterNumber:$ayahNumber') {
        throw FormatException(
          'Unexpected verse_key "$verseKey" for $chapterNumber:$ayahNumber.',
        );
      }

      final arabicText = _firstNonEmptyString(verse, const [
        'text_qpc_hafs',
        'text_uthmani',
      ]);
      final arabicTextIndopak = _requiredString(verse, 'text_indopak');
      final arabicTextTajweed = _optionalString(verse, 'text_uthmani_tajweed');
      final rawWords = _objectList(verse, 'words');
      final verseWordRows = <Map<String, dynamic>>[];

      for (final word in rawWords) {
        if (_optionalString(word, 'char_type_name') != 'word') {
          continue;
        }
        final arabic = _firstNonEmptyString(word, const [
          'text_qpc_hafs',
          'text_uthmani',
        ]);
        final arabicIndopak = _requiredString(word, 'text_indopak');
        final arabicTajweed = _optionalString(word, 'text_uthmani_tajweed');
        verseWordRows.add({
          'surah_number': chapterNumber,
          'ayah_number': ayahNumber,
          'position': _requiredInt(word, 'position'),
          'arabic': arabic,
          'arabic_indopak': arabicIndopak,
          'arabic_tajweed': arabicTajweed,
          'transliteration': _nestedText(word['transliteration']),
          'bangla_meaning': null,
          'english_meaning': _nestedText(word['translation']),
          'root': null,
          'lemma': null,
          'grammar': null,
          'audio_remote_path': _optionalString(word, 'audio_url'),
        });
      }

      if (verseWordRows.isEmpty) {
        throw FormatException('No Quran words returned for $verseKey.');
      }

      normalizedAyahs.add({
        'surah_number': chapterNumber,
        'ayah_number': ayahNumber,
        'verse_key': verseKey,
        'arabic_text': arabicText,
        'arabic_text_indopak': arabicTextIndopak,
        'arabic_text_tajweed': arabicTextTajweed,
        'page_number': _requiredInt(verse, 'page_number'),
        'juz_number': _requiredInt(verse, 'juz_number'),
        'hizb_number': _optionalInt(verse, 'hizb_number'),
        'rub_number': _optionalInt(verse, 'rub_el_hizb_number'),
      });
      normalizedWords.addAll(verseWordRows);
    }
  }

  return NormalizedQuranDocuments(
    quran: {
      'source_name': 'Quran Foundation Content API',
      'source_version': sourceVersion,
      'content_version': contentVersion,
      'surahs': normalizedSurahs,
      'ayahs': normalizedAyahs,
    },
    words: {
      'source_name': 'Quran Foundation Content API word data',
      'source_version': sourceVersion,
      'words': normalizedWords,
    },
  );
}

Map<String, dynamic> mergeBanglaWordMeanings({
  required Map<String, dynamic> words,
  required Map<int, List<Map<String, dynamic>>> banglaVersesByChapter,
  String? sourceName,
  String? sourceVersion,
}) {
  final canonicalRows = _objectList(words, 'words');
  final canonicalByLocation = <String, Map<String, dynamic>>{};
  for (final raw in canonicalRows) {
    final row = Map<String, dynamic>.from(raw);
    final location =
        '${_requiredInt(row, 'surah_number')}:'
        '${_requiredInt(row, 'ayah_number')}:'
        '${_requiredInt(row, 'position')}';
    if (canonicalByLocation.putIfAbsent(location, () => row) != row) {
      throw StateError('Duplicate canonical word location $location.');
    }
  }

  final meanings = <String, String>{};
  final chapterNumbers = banglaVersesByChapter.keys.toList()..sort();
  for (final chapter in chapterNumbers) {
    final verses = banglaVersesByChapter[chapter] ?? const [];
    for (final verse in verses) {
      final verseChapter = _optionalInt(verse, 'chapter_id') ?? chapter;
      final ayah = _requiredInt(verse, 'verse_number');
      final verseKey = _requiredString(verse, 'verse_key');
      if (verseChapter != chapter || verseKey != '$chapter:$ayah') {
        throw FormatException(
          'Unexpected Bangla word verse $verseKey under Surah $chapter.',
        );
      }
      for (final word in _objectList(verse, 'words')) {
        if (_optionalString(word, 'char_type_name') != 'word') continue;
        final position = _requiredInt(word, 'position');
        final location = '$chapter:$ayah:$position';
        if (meanings.containsKey(location)) {
          throw StateError('Duplicate Bangla word location $location.');
        }
        final meaning = _displayWordMeaning(word['translation']);
        if (meaning == null || meaning.isEmpty) {
          throw StateError('Empty Bangla word meaning at $location.');
        }
        if (!canonicalByLocation.containsKey(location)) {
          throw StateError('Extra Bangla word meaning at $location.');
        }
        meanings[location] = meaning;
      }
    }
  }

  final missing = canonicalByLocation.keys
      .where((location) => !meanings.containsKey(location))
      .toList(growable: false);
  if (missing.isNotEmpty) {
    throw StateError(
      'Missing Bangla word meaning for ${missing.length} canonical words. '
      'First missing: ${missing.first}.',
    );
  }

  final mergedRows = <Map<String, dynamic>>[];
  for (final raw in canonicalRows) {
    final row = Map<String, dynamic>.from(raw);
    final location =
        '${_requiredInt(row, 'surah_number')}:'
        '${_requiredInt(row, 'ayah_number')}:'
        '${_requiredInt(row, 'position')}';
    row['bangla_meaning'] = meanings[location];
    mergedRows.add(row);
  }

  return {
    ...words,
    'bangla_word_source_name':
        sourceName ?? 'Quran Foundation Content API word data',
    'bangla_word_source_version':
        sourceVersion ?? words['source_version'] ?? 'unknown',
    'bangla_word_language': 'bn',
    'words': mergedRows,
  };
}

String? _displayWordMeaning(Object? translation) {
  if (translation is! Map) return null;
  final value = translation['text'];
  if (value is! String) return null;
  return value.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

Map<String, dynamic> normalizeQuranEncTranslationDocument({
  required String sourceVersion,
  required Map<int, List<Map<String, dynamic>>> chapterPayloads,
}) {
  final rows = <Map<String, dynamic>>[];
  final chapterNumbers = chapterPayloads.keys.toList()..sort();

  for (final chapterNumber in chapterNumbers) {
    final chapterRows = chapterPayloads[chapterNumber] ?? const [];
    for (final row in chapterRows) {
      final surahNumber = _requiredFlexibleInt(row, 'sura');
      final ayahNumber = _requiredFlexibleInt(row, 'aya');
      if (surahNumber != chapterNumber) {
        throw FormatException(
          'QuranEnc row $surahNumber:$ayahNumber was returned under '
          'Surah $chapterNumber.',
        );
      }
      rows.add({
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'text': _requiredStringPreserve(row, 'translation'),
      });
    }
  }

  rows.sort((a, b) {
    final surahOrder = (a['surah_number'] as int).compareTo(
      b['surah_number'] as int,
    );
    if (surahOrder != 0) return surahOrder;
    return (a['ayah_number'] as int).compareTo(b['ayah_number'] as int);
  });

  return {
    'source_name':
        'QuranEnc.com - Bengali translation by Dr. Abu Bakr Muhammad Zakaria',
    'source_version': sourceVersion,
    'resource_id': primaryBanglaTranslationResourceId,
    'language': 'bn',
    'translations': rows,
  };
}

void validateCanonicalChapterCatalog(List<Map<String, dynamic>> chapters) {
  if (chapters.length != 114) {
    throw StateError(
      'Quran Foundation returned ${chapters.length} chapters, but a canonical '
      'release build requires all 114. Your current Quran Foundation '
      'environment/account is returning an incomplete content catalog. Use '
      'an environment and matching credentials with full Content API access '
      'before building the release database.',
    );
  }

  final ids = chapters.map((chapter) => _requiredInt(chapter, 'id')).toSet();
  for (var chapter = 1; chapter <= 114; chapter++) {
    if (!ids.contains(chapter)) {
      throw StateError(
        'Quran Foundation chapter catalog is missing Surah $chapter.',
      );
    }
  }
}

void validateNormalizedSourceCoverage({
  required Map<String, dynamic> quran,
  required Map<String, dynamic> words,
  required Map<String, dynamic> translation,
  bool requireCanonicalQuran = true,
  int? expectedWordCount,
  bool? requireBanglaWordMeanings,
}) {
  final surahs = _objectList(quran, 'surahs');
  final ayahs = _objectList(quran, 'ayahs');
  final wordRows = _objectList(words, 'words');
  final translations = _objectList(translation, 'translations');
  final requiredWordCount =
      expectedWordCount ??
      (requireCanonicalQuran ? canonicalQuranWordCount : null);
  final requireBanglaMeanings =
      requireBanglaWordMeanings ?? requireCanonicalQuran;

  if (requiredWordCount != null && wordRows.length != requiredWordCount) {
    throw StateError(
      'Expected $requiredWordCount canonical words, found ${wordRows.length}.',
    );
  }

  if (requireBanglaMeanings) {
    for (final word in wordRows) {
      final surah = _requiredInt(word, 'surah_number');
      final ayah = _requiredInt(word, 'ayah_number');
      final position = _requiredInt(word, 'position');
      final meaning = word['bangla_meaning'];
      if (meaning is! String || meaning.trim().isEmpty) {
        throw StateError(
          'Empty Bangla word meaning at $surah:$ayah:$position.',
        );
      }
    }
  }

  if (requireCanonicalQuran) {
    if (surahs.length != 114) {
      throw StateError('Expected 114 Surahs, found ${surahs.length}.');
    }
    if (ayahs.length != 6236) {
      throw StateError('Expected 6236 ayahs, found ${ayahs.length}.');
    }
  }

  final ayahKeys = <String>{};
  final metadataCounts = <int, int>{};
  for (final surah in surahs) {
    final number = _requiredInt(surah, 'number');
    metadataCounts[number] = _requiredInt(surah, 'ayah_count');
  }
  for (final ayah in ayahs) {
    final surah = _requiredInt(ayah, 'surah_number');
    final number = _requiredInt(ayah, 'ayah_number');
    final key = '$surah:$number';
    if (!ayahKeys.add(key)) {
      throw StateError('Duplicate normalized ayah $key.');
    }
  }

  for (final entry in metadataCounts.entries) {
    final actual = ayahKeys
        .where((key) => key.startsWith('${entry.key}:'))
        .length;
    if (actual != entry.value) {
      throw StateError(
        'Surah ${entry.key} metadata declares ${entry.value} ayahs, '
        'but normalized data contains $actual.',
      );
    }
  }

  final ayahsWithWords = <String>{};
  for (final word in wordRows) {
    ayahsWithWords.add(
      '${_requiredInt(word, 'surah_number')}:${_requiredInt(word, 'ayah_number')}',
    );
  }

  final translationKeys = <String>{};
  for (final row in translations) {
    final key =
        '${_requiredInt(row, 'surah_number')}:${_requiredInt(row, 'ayah_number')}';
    if (!translationKeys.add(key)) {
      throw StateError('Duplicate normalized translation $key.');
    }
  }

  final missingWords = ayahKeys.difference(ayahsWithWords);
  if (missingWords.isNotEmpty) {
    throw StateError(
      'Missing word coverage for ${missingWords.length} ayahs. '
      'First missing: ${missingWords.first}.',
    );
  }
  final missingTranslations = ayahKeys.difference(translationKeys);
  if (missingTranslations.isNotEmpty) {
    throw StateError(
      'Missing Bangla translation coverage for ${missingTranslations.length} '
      'ayahs. First missing: ${missingTranslations.first}.',
    );
  }

  final orphanTranslations = translationKeys.difference(ayahKeys);
  if (orphanTranslations.isNotEmpty) {
    throw StateError(
      'Translation contains ${orphanTranslations.length} orphan ayahs. '
      'First orphan: ${orphanTranslations.first}.',
    );
  }
}

abstract interface class JsonTransport {
  Future<JsonHttpResponse> send({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  });
}

class JsonHttpResponse {
  const JsonHttpResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Object? body;
}

class DartIoJsonTransport implements JsonTransport {
  DartIoJsonTransport({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<JsonHttpResponse> send({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  }) async {
    final request = await _client.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'quran-hifz-content-builder/1',
    );
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }

    if (basicUsername != null || basicPassword != null) {
      if (basicUsername == null || basicPassword == null) {
        throw ArgumentError(
          'Both Basic auth username and password are required.',
        );
      }
      final credentials = base64Encode(
        utf8.encode('$basicUsername:$basicPassword'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Basic $credentials',
      );
    }

    if (formFields != null) {
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.write(
        formFields.entries
            .map(
              (entry) =>
                  '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
            )
            .join('&'),
      );
    }

    final response = await request.close();
    final bodyText = await utf8.decoder.bind(response).join();
    Object? decoded;
    if (bodyText.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } on FormatException {
        decoded = bodyText;
      }
    }
    return JsonHttpResponse(statusCode: response.statusCode, body: decoded);
  }

  void close() => _client.close(force: true);
}

class QuranFoundationClient {
  QuranFoundationClient({
    required JsonTransport transport,
    required this.clientId,
    required this.apiBase,
    required this.authBase,
    this.clientSecret,
    String? accessToken,
  }) : _transport = transport,
       _accessToken = accessToken;

  final JsonTransport _transport;
  final String clientId;
  final String? clientSecret;
  final Uri apiBase;
  final Uri authBase;
  String? _accessToken;

  Future<List<Map<String, dynamic>>> fetchChapters() async {
    final payload = await _authenticatedGet('/content/api/v4/chapters');
    return _objectList(payload, 'chapters');
  }

  Future<List<Map<String, dynamic>>> fetchChapterReciters({
    String language = 'en',
  }) async {
    final normalizedLanguage = language.trim();
    if (normalizedLanguage.isEmpty) {
      throw ArgumentError.value(language, 'language', 'must not be empty');
    }
    final payload = await _authenticatedGet(
      '/content/api/v4/resources/chapter_reciters',
      queryParameters: {'language': normalizedLanguage},
    );
    return _objectList(payload, 'reciters');
  }

  Future<Map<String, dynamic>> fetchChapterAudio({
    required int reciterId,
    required int surahNumber,
    bool segments = true,
  }) async {
    if (reciterId <= 0) {
      throw ArgumentError.value(reciterId, 'reciterId', 'must be positive');
    }
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }

    return _authenticatedGet(
      '/content/api/v4/chapter_recitations/$reciterId/$surahNumber',
      queryParameters: {'segments': segments ? 'true' : 'false'},
    );
  }

  Future<List<Map<String, dynamic>>> fetchChapterVerses(
    int chapter, {
    String language = 'en',
  }) async {
    final normalizedLanguage = language.trim();
    if (normalizedLanguage.isEmpty) {
      throw ArgumentError.value(language, 'language', 'must not be empty');
    }
    final verses = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final payload = await _authenticatedGet(
        '/content/api/v4/verses/by_chapter/$chapter',
        queryParameters: {
          'language': normalizedLanguage,
          'words': 'true',
          'fields':
              'text_qpc_hafs,text_uthmani,text_indopak,text_uthmani_tajweed',
          'word_fields':
              'text_qpc_hafs,text_uthmani,text_indopak,text_uthmani_tajweed,verse_key,location,line_number,v1_page,v2_page',
          'per_page': '50',
          'page': '$page',
        },
      );
      verses.addAll(_objectList(payload, 'verses'));
      final pagination = _requiredObject(payload, 'pagination');
      final nextPage = _optionalInt(pagination, 'next_page');
      if (nextPage == null) break;
      if (nextPage <= page) {
        throw FormatException(
          'Quran Foundation pagination did not advance for Surah $chapter.',
        );
      }
      page = nextPage;
    }
    return verses;
  }

  Future<Map<String, dynamic>> _authenticatedGet(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    var token = await _ensureAccessToken();
    var response = await _sendWithRetry(
      method: 'GET',
      uri: _resolve(apiBase, path, queryParameters),
      headers: {'x-auth-token': token, 'x-client-id': clientId},
    );

    if (response.statusCode == HttpStatus.unauthorized &&
        clientSecret != null) {
      _accessToken = null;
      token = await _ensureAccessToken();
      response = await _sendWithRetry(
        method: 'GET',
        uri: _resolve(apiBase, path, queryParameters),
        headers: {'x-auth-token': token, 'x-client-id': clientId},
      );
    }

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Quran Foundation request failed with HTTP ${response.statusCode}: '
        '${_safeError(response.body)}',
      );
    }
    return _requireObjectBody(response.body, 'Quran Foundation');
  }

  Future<String> _ensureAccessToken() async {
    final existing = _accessToken;
    if (existing != null && existing.isNotEmpty) return existing;
    final secret = clientSecret;
    if (secret == null || secret.isEmpty) {
      throw StateError(
        'QF_CLIENT_SECRET is required when QF_ACCESS_TOKEN is not supplied.',
      );
    }

    final response = await _sendWithRetry(
      method: 'POST',
      uri: authBase.resolve('/oauth2/token'),
      basicUsername: clientId,
      basicPassword: secret,
      formFields: const {
        'grant_type': 'client_credentials',
        'scope': 'content',
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Quran Foundation token request failed with HTTP '
        '${response.statusCode}: ${_safeError(response.body)}',
      );
    }
    final body = _requireObjectBody(response.body, 'Quran Foundation token');
    final token = _requiredString(body, 'access_token');
    _accessToken = token;
    return token;
  }

  Future<JsonHttpResponse> _sendWithRetry({
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    Map<String, String>? formFields,
    String? basicUsername,
    String? basicPassword,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        final response = await _transport.send(
          method: method,
          uri: uri,
          headers: headers,
          formFields: formFields,
          basicUsername: basicUsername,
          basicPassword: basicPassword,
        );
        if (response.statusCode != HttpStatus.tooManyRequests &&
            response.statusCode < 500) {
          return response;
        }
        lastError = HttpException('HTTP ${response.statusCode}');
      } on SocketException catch (error) {
        lastError = error;
      } on HttpException catch (error) {
        lastError = error;
      }

      if (attempt < 3) {
        await Future<void>.delayed(
          Duration(milliseconds: 250 * (1 << attempt)),
        );
      }
    }
    throw StateError(
      'Quran Foundation request failed after retries: $lastError',
    );
  }
}

class QuranEncClient {
  QuranEncClient({required JsonTransport transport, required this.baseUri})
    : _transport = transport;

  final JsonTransport _transport;
  final Uri baseUri;

  Future<String> fetchZakariaSourceVersion() async {
    final response = await _get(
      '/api/v1/translations/list/bn',
      queryParameters: const {'localization': 'en'},
    );
    final rows = _extractListBody(
      response,
      preferredKeys: const ['translations', 'result'],
    );
    final item = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['key'] == quranEncZakariaKey,
      orElse: () => null,
    );

    if (item != null) {
      final version = _optionalString(item, 'version');
      final lastUpdate = _optionalDateLikeValue(item['last_update']);
      if (version != null && lastUpdate != null) {
        return '$version (last_update $lastUpdate)';
      }
      if (version != null) return version;
      if (lastUpdate != null) return lastUpdate;
    }

    // QuranEnc's current public translations-list endpoint can omit older
    // catalog entries that are still published and served by the translation
    // endpoint. Probe the actual Zakaria Surah API before using the catalog
    // version shown on QuranEnc's Bengali catalog page.
    final probe = await fetchZakariaSurah(1);
    if (probe.isEmpty) {
      throw StateError(
        'QuranEnc did not list $quranEncZakariaKey and its direct Surah API '
        'returned no rows.',
      );
    }
    return '$quranEncZakariaCatalogVersion '
        '(catalog $quranEncZakariaCatalogLastUpdate)';
  }

  Future<List<Map<String, dynamic>>> fetchZakariaSurah(int surah) async {
    final response = await _get(
      '/api/v1/translation/sura/$quranEncZakariaKey/$surah',
    );
    return _extractListBody(
      response,
      preferredKeys: const ['result', 'translations', 'data'],
    );
  }

  Future<Object?> _get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        final response = await _transport.send(
          method: 'GET',
          uri: _resolve(baseUri, path, queryParameters),
        );
        if (response.statusCode == HttpStatus.ok) {
          return response.body;
        }
        if (response.statusCode != HttpStatus.tooManyRequests &&
            response.statusCode < 500) {
          throw HttpException(
            'QuranEnc request failed with HTTP ${response.statusCode}: '
            '${_safeError(response.body)}',
          );
        }
        lastError = HttpException('HTTP ${response.statusCode}');
      } on SocketException catch (error) {
        lastError = error;
      } on HttpException catch (error) {
        lastError = error;
      }

      if (attempt < 3) {
        await Future<void>.delayed(
          Duration(milliseconds: 250 * (1 << attempt)),
        );
      }
    }
    throw StateError('QuranEnc request failed after retries: $lastError');
  }
}

class VerifiedSourceFetcher {
  VerifiedSourceFetcher({
    required this.quranFoundation,
    required this.quranEnc,
    required this.contentVersion,
    required this.quranFoundationSourceVersion,
  });

  final QuranFoundationClient quranFoundation;
  final QuranEncClient quranEnc;
  final String contentVersion;
  final String quranFoundationSourceVersion;

  Future<VerifiedSourceDocuments> fetch() async {
    final chapters = await quranFoundation.fetchChapters();
    validateCanonicalChapterCatalog(chapters);
    final versesByChapter = <int, List<Map<String, dynamic>>>{};
    final chapterNumbers =
        chapters
            .map((chapter) => _requiredInt(chapter, 'id'))
            .toList(growable: false)
          ..sort();

    for (final chapter in chapterNumbers) {
      stdout.writeln('Fetching Quran Foundation Surah $chapter/114...');
      versesByChapter[chapter] = await quranFoundation.fetchChapterVerses(
        chapter,
      );
    }

    final normalizedQuran = normalizeQuranFoundationDocuments(
      chapters: chapters,
      versesByChapter: versesByChapter,
      contentVersion: contentVersion,
      sourceVersion: quranFoundationSourceVersion,
    );

    final banglaVersesByChapter = <int, List<Map<String, dynamic>>>{};
    for (final chapter in chapterNumbers) {
      stdout.writeln(
        'Fetching Quran Foundation Bangla word meanings Surah $chapter/114...',
      );
      banglaVersesByChapter[chapter] = await quranFoundation.fetchChapterVerses(
        chapter,
        language: 'bn',
      );
    }
    final wordsWithBangla = mergeBanglaWordMeanings(
      words: normalizedQuran.words,
      banglaVersesByChapter: banglaVersesByChapter,
      sourceName: 'Quran Foundation Content API Bangla word data',
      sourceVersion: quranFoundationSourceVersion,
    );

    final zakariaVersion = await quranEnc.fetchZakariaSourceVersion();
    final translationPayloads = <int, List<Map<String, dynamic>>>{};
    for (final chapter in chapterNumbers) {
      stdout.writeln('Fetching Zakaria Bangla Surah $chapter/114...');
      translationPayloads[chapter] = await quranEnc.fetchZakariaSurah(chapter);
    }
    final translation = normalizeQuranEncTranslationDocument(
      sourceVersion: zakariaVersion,
      chapterPayloads: translationPayloads,
    );

    validateNormalizedSourceCoverage(
      quran: normalizedQuran.quran,
      words: wordsWithBangla,
      translation: translation,
    );

    return VerifiedSourceDocuments(
      quran: normalizedQuran.quran,
      words: wordsWithBangla,
      translation: translation,
    );
  }
}

Future<void> writeVerifiedSourceDocuments({
  required Directory outputDirectory,
  required VerifiedSourceDocuments documents,
}) async {
  await outputDirectory.create(recursive: true);
  await _writeJsonAtomically(
    File.fromUri(outputDirectory.uri.resolve('verified-quran.json')),
    documents.quran,
  );
  await _writeJsonAtomically(
    File.fromUri(outputDirectory.uri.resolve('verified-words.json')),
    documents.words,
  );
  await _writeJsonAtomically(
    File.fromUri(outputDirectory.uri.resolve('verified-bangla.json')),
    documents.translation,
  );
}

Future<void> _writeJsonAtomically(
  File target,
  Map<String, dynamic> value,
) async {
  final staged = File('${target.path}.tmp');
  if (await staged.exists()) await staged.delete();
  await staged.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
    flush: true,
  );
  if (await target.exists()) await target.delete();
  await staged.rename(target.path);
}

Uri _resolve(Uri base, String path, Map<String, String> queryParameters) {
  final resolved = base.resolve(path);
  return resolved.replace(
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  );
}

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;

Map<String, dynamic> _requireObjectBody(Object? body, String source) {
  if (body is! Map) {
    throw FormatException('$source returned a non-object JSON response.');
  }
  return Map<String, dynamic>.from(body);
}

List<Map<String, dynamic>> _extractListBody(
  Object? body, {
  required List<String> preferredKeys,
}) {
  Object? candidate = body;
  if (body is Map) {
    final object = Map<String, dynamic>.from(body);
    for (final key in preferredKeys) {
      if (object[key] is List) {
        candidate = object[key];
        break;
      }
    }
  }
  if (candidate is! List) {
    throw const FormatException('Expected a JSON array response.');
  }
  return candidate
      .map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Expected every array item to be an object.',
          );
        }
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}

Map<String, dynamic> _requiredObject(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('Expected "$key" to be a JSON object.');
  }
  return Map<String, dynamic>.from(value);
}

List<Map<String, dynamic>> _objectList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected "$key" to be a JSON array.');
  }
  return value
      .map((item) {
        if (item is! Map) {
          throw FormatException('Expected every "$key" item to be an object.');
        }
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw FormatException('Expected integer "$key".');
}

int _requiredFlexibleInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Expected integer-like "$key".');
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw FormatException('Expected integer or null "$key".');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string "$key".');
  }
  return value;
}

String _requiredStringPreserve(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string "$key".');
  }
  return value;
}

String? _optionalDateLikeValue(Object? value) {
  if (value == null) return null;
  if (value is String) {
    return value.trim().isEmpty ? null : value;
  }
  if (value is int) {
    final date = DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return _optionalDateLikeValue(value.toInt());
  }
  throw const FormatException(
    'Expected last_update to be a string, Unix timestamp, or null.',
  );
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Expected string or null "$key".');
  }
  return value.trim().isEmpty ? null : value;
}

String _firstNonEmptyString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  throw FormatException(
    'Expected one non-empty string field from ${keys.join(', ')}.',
  );
}

String? _nestedText(Object? value) {
  if (value is! Map) return null;
  final object = Map<String, dynamic>.from(value);
  final text = object['text'];
  if (text is! String || text.trim().isEmpty) return null;
  return text;
}

String _safeError(Object? body) {
  final text = body?.toString() ?? '<empty response>';
  if (text.length <= 300) return text;
  return '${text.substring(0, 300)}...';
}
