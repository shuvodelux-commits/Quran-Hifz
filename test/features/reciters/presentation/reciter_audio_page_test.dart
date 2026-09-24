import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/downloads/domain/download_job.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/domain/quran_surah.dart';
import 'package:quran_hifz/features/quran/data/quran_audio_sync_service.dart';
import 'package:quran_hifz/features/reciters/application/reciter_audio_providers.dart';
import 'package:quran_hifz/features/reciters/application/reciter_catalog_controller.dart';
import 'package:quran_hifz/features/reciters/data/bundled_reciter_catalog_source.dart';
import 'package:quran_hifz/features/reciters/presentation/reciter_audio_page.dart';

import '../../../fakes/fake_audio_player_adapter.dart';

void main() {
  testWidgets(
    'bundled catalog selects reciter and exposes stream and download actions',
    (tester) async {
      final database = UserDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final preparer = _FakeChapterAudioPreparer();
      final player = FakeAudioPlayerAdapter(autoComplete: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reciterCatalogSourceProvider.overrideWithValue(
              BundledReciterCatalogSource(
                bundle: _MapAssetBundle({
                  'assets/audio/reciters_v1.json': jsonEncode(_catalog()),
                }),
              ),
            ),
            userDatabaseProvider.overrideWithValue(database),
            quranSurahListProvider.overrideWith((ref) async => const [_surah]),
            chapterAudioPreparerProvider.overrideWithValue(preparer),
            audioPlayerAdapterProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: ReciterAudioPage(currentSurahNumber: 67),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bundled Seven'), findsOneWidget);
      expect(find.text('Reciter catalog is unavailable.'), findsNothing);
      expect(find.text('67. Al-Mulk · الملك'), findsOneWidget);

      await tester.tap(find.text('Bundled Seven'));
      await tester.pumpAndSettle();
      expect(find.text('Selected reciter: Bundled Seven'), findsOneWidget);

      await tester.tap(find.text('Play / Stream'));
      await tester.pumpAndSettle();
      expect(preparer.calls, [(7, 67, false)]);
      expect(player.loadedSources, [
        'https://download.quranicaudio.com/test/67.mp3',
      ]);
      expect(player.playCalls, 1);
      expect(find.text('Surah audio playback started.'), findsOneWidget);

      final messenger = tester.state<ScaffoldMessengerState>(
        find.byType(ScaffoldMessenger),
      );
      messenger.hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Download for offline'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(preparer.calls, [(7, 67, false), (7, 67, true)]);
      expect(
        find.text('Surah and word audio downloaded for offline playback.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('download failure shows the actual downloader error category', (
    tester,
  ) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final preparer = _FakeChapterAudioPreparer(
      downloadError: ChapterAudioDownloadException(
        status: DownloadJobStatus.failed,
        errorCode: DownloadErrorCode.sizeMismatch.name,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reciterCatalogSourceProvider.overrideWithValue(
            BundledReciterCatalogSource(
              bundle: _MapAssetBundle({
                'assets/audio/reciters_v1.json': jsonEncode(_catalog()),
              }),
            ),
          ),
          userDatabaseProvider.overrideWithValue(database),
          quranSurahListProvider.overrideWith((ref) async => const [_surah]),
          chapterAudioPreparerProvider.overrideWithValue(preparer),
        ],
        child: const MaterialApp(
          home: ReciterAudioPage(currentSurahNumber: 67),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bundled Seven'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download for offline'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The downloaded audio size did not match the verified metadata.',
      ),
      findsOneWidget,
    );
  });
}

const _surah = QuranSurahSummary(
  number: 67,
  nameArabic: 'الملك',
  nameEnglish: 'Al-Mulk',
  ayahCount: 30,
  pageStart: 562,
  pageEnd: 564,
  juzStart: 29,
);

Map<String, dynamic> _catalog() => {
  'schema_version': 1,
  'source_name': 'Quran Foundation Content API v4',
  'source_version': 'test',
  'generated_at_utc': '2026-09-13T00:00:00.000Z',
  'reciters': [
    {
      'id': 7,
      'name': 'Bundled Seven',
      'style': {'name': 'Murattal', 'language_name': 'English'},
      'qirat': {'name': 'Hafs', 'language_name': 'English'},
    },
  ],
};

class _FakeChapterAudioPreparer implements ChapterAudioPreparer {
  _FakeChapterAudioPreparer({this.downloadError});

  final ChapterAudioDownloadException? downloadError;
  final calls = <(int, int, bool)>[];

  @override
  Future<ChapterAudioSyncResult> prepare({
    required int reciterId,
    required int surahNumber,
    required bool downloadAudio,
    ChapterAudioPreparationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    calls.add((reciterId, surahNumber, downloadAudio));
    if (downloadAudio && downloadError != null) {
      throw downloadError!;
    }
    return ChapterAudioSyncResult(
      reciterId: reciterId,
      surahNumber: surahNumber,
      remoteUrl: 'https://download.quranicaudio.com/test/$surahNumber.mp3',
      localPath: downloadAudio ? '/offline/$surahNumber.mp3' : null,
      format: 'mp3',
      fileSize: 100,
      ayahTimingCount: 7,
    );
  }
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Missing fake asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}
