import 'dart:io';

import 'source_fetcher.dart';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final environment = Platform.environment;
  final qfEnvironment = options['qf-env'] ?? environment['QF_ENV'] ?? 'prelive';
  if (qfEnvironment != 'prelive' && qfEnvironment != 'production') {
    throw FormatException('QF_ENV/--qf-env must be prelive or production.');
  }

  final clientId = _requiredSetting(
    options['qf-client-id'] ?? environment['QF_CLIENT_ID'],
    'QF_CLIENT_ID',
  );
  final clientSecret =
      options['qf-client-secret'] ?? environment['QF_CLIENT_SECRET'];
  final accessToken =
      options['qf-access-token'] ?? environment['QF_ACCESS_TOKEN'];
  if ((clientSecret == null || clientSecret.isEmpty) &&
      (accessToken == null || accessToken.isEmpty)) {
    throw StateError(
      'Set QF_CLIENT_SECRET or QF_ACCESS_TOKEN in the environment. '
      'Do not commit either value to the project.',
    );
  }

  final defaultApiBase = qfEnvironment == 'production'
      ? 'https://apis.quran.foundation'
      : 'https://apis-prelive.quran.foundation';
  final defaultAuthBase = qfEnvironment == 'production'
      ? 'https://oauth2.quran.foundation'
      : 'https://prelive-oauth2.quran.foundation';
  final apiBase = Uri.parse(options['qf-api-base'] ?? defaultApiBase);
  final authBase = Uri.parse(options['qf-auth-base'] ?? defaultAuthBase);
  final quranEncBase = Uri.parse(
    options['quranenc-base'] ?? 'https://quranenc.com',
  );
  final outputDirectory = Directory(
    options['out-dir'] ?? 'tool/quran_content/source',
  );
  final contentVersion = options['content-version'] ?? _todayVersion();

  final transport = DartIoJsonTransport();
  try {
    final fetcher = VerifiedSourceFetcher(
      quranFoundation: QuranFoundationClient(
        transport: transport,
        clientId: clientId,
        clientSecret: clientSecret,
        accessToken: accessToken,
        apiBase: apiBase,
        authBase: authBase,
      ),
      quranEnc: QuranEncClient(transport: transport, baseUri: quranEncBase),
      contentVersion: contentVersion,
      quranFoundationSourceVersion:
          'content-api-v4-$qfEnvironment ($contentVersion)',
    );

    final documents = await fetcher.fetch();
    await writeVerifiedSourceDocuments(
      outputDirectory: outputDirectory,
      documents: documents,
    );

    final ayahCount = (documents.quran['ayahs'] as List<Object?>).length;
    final wordCount = (documents.words['words'] as List<Object?>).length;
    final translationCount =
        (documents.translation['translations'] as List<Object?>).length;
    stdout.writeln('Verified source download complete.');
    stdout.writeln('Ayahs: $ayahCount');
    stdout.writeln('Words with bundled Bangla meanings: $wordCount');
    stdout.writeln('Zakaria Bangla translations: $translationCount');
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
    result[argument.substring(2)] = args[++i];
  }
  return result;
}

String _requiredSetting(String? value, String name) {
  if (value == null || value.trim().isEmpty) {
    throw StateError('$name is required.');
  }
  return value;
}

String _todayVersion() {
  final now = DateTime.now().toUtc();
  return '${now.year.toString().padLeft(4, '0')}.'
      '${now.month.toString().padLeft(2, '0')}.'
      '${now.day.toString().padLeft(2, '0')}';
}
