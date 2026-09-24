import 'dart:convert';
import 'dart:io';

import 'materialize_qul_sources.dart';
import 'qul_api_client.dart';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final scriptPath = options['indopak-out'] ?? '/tmp/qul-indopak-59.sqlite';
  final layoutPath = options['layout-out'] ?? '/tmp/qul-pdms-layout-3.sqlite';
  final canonicalPath =
      options['canonical-words'] ??
      'tool/quran_content/source/verified-words.json';
  final canonicalJson =
      jsonDecode(File(canonicalPath).readAsStringSync())
          as Map<String, dynamic>;
  final segmentation = canonicalSegmentationFromJson(canonicalJson);
  final responses = await fetchQulMushafResponses(getPublicQulResponse);
  final sources = materializeQulMushafResponses(
    responses,
    canonicalWordCountsByVerse: segmentation.wordCountsByVerse,
    joinedCanonicalLocations: segmentation.joinedWordLocations,
  );
  writeQulMaterializedSqlite(
    sources,
    scriptPath: scriptPath,
    layoutPath: layoutPath,
  );
  print('Materialized ${sources.words.length} QUL canonical words.');
  print('QUL endpoint: $qulChapterVersesEndpoint/chapters/{surah}/verses.json');
  print('IndoPak resource field: text_indopak_nastaleeq; Mushaf: 3.');
  print('Script input: $scriptPath');
  print('Layout input: $layoutPath');
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final arg = args[index];
    if (!arg.startsWith('--')) {
      throw FormatException('Unexpected argument "$arg".');
    }
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw FormatException('Missing value for $arg.');
    }
    result[arg.substring(2)] = args[++index];
  }
  const accepted = {'indopak-out', 'layout-out', 'canonical-words'};
  final unknown = result.keys.where((key) => !accepted.contains(key)).toList();
  if (unknown.isNotEmpty) {
    throw FormatException('Unknown option --${unknown.first}.');
  }
  return result;
}
