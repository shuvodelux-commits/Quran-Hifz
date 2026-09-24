import 'dart:convert';
import 'dart:io';

import '../quran_content/source_fetcher.dart';
import 'reciter_catalog_builder.dart';

class VerifiedReciterAudioCatalog {
  const VerifiedReciterAudioCatalog({
    required this.reciterIndex,
    required this.chaptersByReciter,
  });

  final Map<String, dynamic> reciterIndex;
  final Map<int, Map<int, Map<String, dynamic>>> chaptersByReciter;

  int get reciterCount => chaptersByReciter.length;

  int get chapterDocumentCount => chaptersByReciter.values.fold<int>(
    0,
    (total, chapters) => total + chapters.length,
  );
}

Future<VerifiedReciterAudioCatalog> fetchVerifiedReciterAudioCatalog({
  required QuranFoundationClient client,
  required List<int> reciterIds,
  required String sourceVersion,
  required DateTime generatedAtUtc,
}) async {
  if (reciterIds.isEmpty) {
    throw ArgumentError.value(reciterIds, 'reciterIds', 'must not be empty');
  }
  final requested = <int>{};
  for (final id in reciterIds) {
    if (id <= 0) {
      throw ArgumentError.value(id, 'reciterIds', 'ids must be positive');
    }
    if (!requested.add(id)) {
      throw ArgumentError.value(
        reciterIds,
        'reciterIds',
        'duplicate reciter id $id',
      );
    }
  }

  final allReciters = await client.fetchChapterReciters();
  final byId = <int, Map<String, dynamic>>{};
  for (final row in allReciters) {
    final rawId = row['id'];
    if (rawId is! int || rawId <= 0) {
      throw const FormatException(
        'Quran Foundation chapter-reciter catalog contains an invalid id.',
      );
    }
    if (byId.containsKey(rawId)) {
      throw FormatException(
        'Quran Foundation chapter-reciter catalog contains duplicate id $rawId.',
      );
    }
    byId[rawId] = row;
  }

  final missing = requested.where((id) => !byId.containsKey(id)).toList()
    ..sort();
  if (missing.isNotEmpty) {
    throw StateError(
      'Requested reciter ids are missing from the verified Quran Foundation '
      'catalog: $missing.',
    );
  }

  final selectedRows = requested.map((id) => byId[id]!).toList(growable: false);
  final reciterIndex = buildReciterIndex(
    sourceVersion: sourceVersion,
    generatedAtUtc: generatedAtUtc,
    reciters: selectedRows,
  );
  final chaptersByReciter = <int, Map<int, Map<String, dynamic>>>{};

  final sortedIds = requested.toList()..sort();
  for (final reciterId in sortedIds) {
    final chapters = <int, Map<String, dynamic>>{};
    for (var surahNumber = 1; surahNumber <= 114; surahNumber++) {
      final raw = await client.fetchChapterAudio(
        reciterId: reciterId,
        surahNumber: surahNumber,
        segments: true,
      );
      chapters[surahNumber] = buildChapterAudioDocument(
        reciterId: reciterId,
        surahNumber: surahNumber,
        raw: raw,
      );
    }
    chaptersByReciter[reciterId] = chapters;
  }

  validateGeneratedAudioCatalog(
    reciterIndex: reciterIndex,
    chaptersByReciter: chaptersByReciter,
  );

  return VerifiedReciterAudioCatalog(
    reciterIndex: reciterIndex,
    chaptersByReciter: chaptersByReciter,
  );
}

Future<void> writeVerifiedReciterAudioCatalog({
  required Directory outputDirectory,
  required VerifiedReciterAudioCatalog catalog,
}) async {
  validateGeneratedAudioCatalog(
    reciterIndex: catalog.reciterIndex,
    chaptersByReciter: catalog.chaptersByReciter,
  );

  final outputParent = outputDirectory.parent;
  await outputParent.create(recursive: true);
  final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final staging = Directory(
    '${outputParent.path}${Platform.pathSeparator}'
    '.${_basename(outputDirectory.path)}.staging-$stamp',
  );
  final backup = Directory(
    '${outputParent.path}${Platform.pathSeparator}'
    '.${_basename(outputDirectory.path)}.generated-backup-$stamp',
  );

  await staging.create(recursive: true);
  var committed = false;
  try {
    final stagedChapters = Directory(
      '${staging.path}${Platform.pathSeparator}chapters_v1',
    );
    await stagedChapters.create(recursive: true);

    final encoder = const JsonEncoder.withIndent('  ');
    final stagedIndex = File(
      '${staging.path}${Platform.pathSeparator}reciters_v1.json',
    );
    await stagedIndex.writeAsString(
      '${encoder.convert(catalog.reciterIndex)}\n',
    );

    final reciterIds = catalog.chaptersByReciter.keys.toList()..sort();
    for (final reciterId in reciterIds) {
      final chapters = catalog.chaptersByReciter[reciterId]!;
      for (var surahNumber = 1; surahNumber <= 114; surahNumber++) {
        final document = chapters[surahNumber]!;
        final file = File(
          '${stagedChapters.path}${Platform.pathSeparator}'
          '$reciterId-$surahNumber.json',
        );
        await file.writeAsString('${encoder.convert(document)}\n');
      }
    }

    await outputDirectory.create(recursive: true);
    await backup.create(recursive: true);

    final currentIndex = File(
      '${outputDirectory.path}${Platform.pathSeparator}reciters_v1.json',
    );
    final currentChapters = Directory(
      '${outputDirectory.path}${Platform.pathSeparator}chapters_v1',
    );
    final backupIndex = File(
      '${backup.path}${Platform.pathSeparator}reciters_v1.json',
    );
    final backupChapters = Directory(
      '${backup.path}${Platform.pathSeparator}chapters_v1',
    );

    var oldIndexMoved = false;
    var oldChaptersMoved = false;
    var newIndexMoved = false;
    var newChaptersMoved = false;

    try {
      if (await currentIndex.exists()) {
        await currentIndex.rename(backupIndex.path);
        oldIndexMoved = true;
      }
      if (await currentChapters.exists()) {
        await currentChapters.rename(backupChapters.path);
        oldChaptersMoved = true;
      }

      await stagedIndex.rename(currentIndex.path);
      newIndexMoved = true;
      await stagedChapters.rename(currentChapters.path);
      newChaptersMoved = true;
      committed = true;
    } catch (_) {
      if (newChaptersMoved && await currentChapters.exists()) {
        await currentChapters.delete(recursive: true);
      }
      if (newIndexMoved && await currentIndex.exists()) {
        await currentIndex.delete();
      }
      if (oldChaptersMoved && await backupChapters.exists()) {
        await backupChapters.rename(currentChapters.path);
      }
      if (oldIndexMoved && await backupIndex.exists()) {
        await backupIndex.rename(currentIndex.path);
      }
      rethrow;
    }

    if (await backup.exists()) {
      await backup.delete(recursive: true);
    }
  } finally {
    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    if (committed && await backup.exists()) {
      await backup.delete(recursive: true);
    }
  }
}

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final environment = Platform.environment;
  final qfEnvironment =
      options['qf-env'] ?? environment['QF_ENV'] ?? 'production';
  if (qfEnvironment != 'prelive' && qfEnvironment != 'production') {
    throw FormatException('QF_ENV/--qf-env must be prelive or production.');
  }

  final clientId = _requiredSetting(
    options['qf-client-id'] ?? environment['QF_CLIENT_ID'],
    'QF_CLIENT_ID',
  );
  final clientSecret = environment['QF_CLIENT_SECRET'];
  final accessToken = environment['QF_ACCESS_TOKEN'];
  if ((clientSecret == null || clientSecret.isEmpty) &&
      (accessToken == null || accessToken.isEmpty)) {
    throw StateError(
      'Set QF_CLIENT_SECRET or QF_ACCESS_TOKEN in the environment. '
      'Do not pass or commit Quran Foundation secrets in project files.',
    );
  }

  final reciterIds = _parseReciterIds(
    _requiredSetting(options['reciter-ids'], '--reciter-ids'),
  );
  final defaultApiBase = qfEnvironment == 'production'
      ? 'https://apis.quran.foundation'
      : 'https://apis-prelive.quran.foundation';
  final defaultAuthBase = qfEnvironment == 'production'
      ? 'https://oauth2.quran.foundation'
      : 'https://prelive-oauth2.quran.foundation';
  final apiBase = Uri.parse(options['qf-api-base'] ?? defaultApiBase);
  final authBase = Uri.parse(options['qf-auth-base'] ?? defaultAuthBase);
  final outputDirectory = Directory(options['out-dir'] ?? 'assets/audio');
  final generatedAtUtc = DateTime.now().toUtc();
  final sourceVersion =
      'content-api-v4-$qfEnvironment (${_dateVersion(generatedAtUtc)})';

  final transport = DartIoJsonTransport();
  try {
    final client = QuranFoundationClient(
      transport: transport,
      clientId: clientId,
      clientSecret: clientSecret,
      accessToken: accessToken,
      apiBase: apiBase,
      authBase: authBase,
    );
    final catalog = await fetchVerifiedReciterAudioCatalog(
      client: client,
      reciterIds: reciterIds,
      sourceVersion: sourceVersion,
      generatedAtUtc: generatedAtUtc,
    );
    await writeVerifiedReciterAudioCatalog(
      outputDirectory: outputDirectory,
      catalog: catalog,
    );

    stdout.writeln('Verified reciter audio metadata generation complete.');
    stdout.writeln('Reciters: ${catalog.reciterCount}');
    stdout.writeln('Chapter documents: ${catalog.chapterDocumentCount}');
    stdout.writeln('Output: ${outputDirectory.path}');
  } finally {
    transport.close();
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final argument = args[i];
    if (!argument.startsWith('--')) {
      throw FormatException('Unexpected argument "$argument".');
    }
    if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
      throw FormatException('Missing value for "$argument".');
    }
    final key = argument.substring(2);
    const allowed = {
      'qf-env',
      'qf-client-id',
      'qf-api-base',
      'qf-auth-base',
      'reciter-ids',
      'out-dir',
    };
    if (!allowed.contains(key)) {
      throw FormatException('Unsupported argument "$argument".');
    }
    result[key] = args[++i];
  }
  return result;
}

List<int> _parseReciterIds(String raw) {
  final ids = raw
      .split(',')
      .map((value) => int.tryParse(value.trim()))
      .toList(growable: false);
  if (ids.isEmpty || ids.any((id) => id == null || id <= 0)) {
    throw FormatException(
      '--reciter-ids must be a comma-separated list of positive integers.',
    );
  }
  final values = ids.cast<int>();
  if (values.toSet().length != values.length) {
    throw FormatException('--reciter-ids must not contain duplicate ids.');
  }
  return values;
}

String _requiredSetting(String? value, String name) {
  if (value == null || value.trim().isEmpty) {
    throw StateError('$name is required.');
  }
  return value.trim();
}

String _dateVersion(DateTime time) =>
    '${time.year.toString().padLeft(4, '0')}-'
    '${time.month.toString().padLeft(2, '0')}-'
    '${time.day.toString().padLeft(2, '0')}';

String _basename(String path) {
  final normalized = path.endsWith(Platform.pathSeparator)
      ? path.substring(0, path.length - 1)
      : path;
  final separator = normalized.lastIndexOf(Platform.pathSeparator);
  return separator == -1 ? normalized : normalized.substring(separator + 1);
}
