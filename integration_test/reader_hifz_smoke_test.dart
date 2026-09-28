import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_hifz/app/quran_hifz_shell.dart';
import 'package:quran_hifz/core/database/database_providers.dart';
import 'package:quran_hifz/core/database/user_database.dart';
import 'package:quran_hifz/features/audio/application/audio_providers.dart';
import 'package:quran_hifz/features/audio/application/quran_audio_controller.dart';
import 'package:quran_hifz/features/audio/domain/quran_audio_state.dart';
import 'package:quran_hifz/features/hifz/presentation/hifz_reader_page.dart';
import 'package:quran_hifz/features/home/presentation/home_page.dart';
import 'package:quran_hifz/features/quran/application/quran_mushaf_providers.dart';
import 'package:quran_hifz/features/quran/application/quran_providers.dart';
import 'package:quran_hifz/features/quran/application/reader_controller.dart';
import 'package:quran_hifz/features/quran/data/demo_quran_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_page_repository.dart';
import 'package:quran_hifz/features/quran/domain/quran_mushaf_variant.dart';
import 'package:quran_hifz/features/quran/domain/quran_page_font_repository.dart';
import 'package:quran_hifz/features/quran/presentation/mushaf/quran_strict_reader_body.dart';
import 'package:quran_hifz/features/quran/presentation/quran_reader_page.dart';
import 'package:quran_hifz/features/quran/presentation/widgets/quran_surah_row.dart';
import 'package:quran_hifz/features/settings/application/app_preferences_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reported Hifz path stays isolated from the normal Quran reader', (
    tester,
  ) async {
    final database = UserDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWithValue(database),
          prayerScheduleProvider.overrideWith(
            (ref) async => throw StateError('Location unavailable in test'),
          ),
          quranRepositoryProvider.overrideWithValue(DemoQuranRepository()),
          readingLocationStoreProvider.overrideWithValue(
            _NoopLocationStore(),
          ),
          quranMushafPageRepositoryProvider.overrideWithValue(
            _FixtureMushafPageRepository(),
          ),
          quranPageFontRepositoryProvider.overrideWith(
            (ref, variant) => _UnavailablePageFontRepository(),
          ),
          quranAudioControllerProvider.overrideWith(
            _FixtureAudioController.new,
          ),
        ],
        child: const MaterialApp(home: QuranHifzShell()),
      ),
    );
    await _pumpFlow(tester);

    await tester.tap(find.text('আরও').last);
    await _pumpFlow(tester);
    await tester.tap(find.text('হিফজ').first);
    await _pumpFlow(tester);
    await tester.tap(find.text('সূরা থেকে হিফজ শুরু করুন'));
    await _pumpFlow(tester);
    await tester.tap(find.byKey(const ValueKey('hifz-surah-1')));
    await _pumpFlow(tester);
    await tester.tap(find.byKey(const ValueKey('hifz-setup-start')));
    await _pumpFlow(tester);

    expect(find.byType(HifzReaderPage), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HifzReaderPage)),
    );
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzFontSize(56);
    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzMushafVariant(QuranMushafVariant.qcfV2);
    await _pumpFlow(tester);

    final hifz = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(hifz.fontSize, 56);
    expect(hifz.variant, QuranMushafVariant.qcfV2);

    await tester.pageBack();
    await _pumpFlow(tester);
    expect(find.text('Al-Fatihah 1–2'), findsOneWidget);

    await tester.tap(find.text('Al-Fatihah 1–2'));
    await _pumpFlow(tester);
    expect(find.byType(HifzReaderPage), findsOneWidget);
    final reopened = tester.widget<QuranStrictReaderBody>(
      find.byType(QuranStrictReaderBody),
    );
    expect(reopened.fontSize, 56);

    await container
        .read(appPreferencesControllerProvider.notifier)
        .setHifzMushafVariant(QuranMushafVariant.qcfV4Tajweed);
    await _pumpFlow(tester);
    expect(
      tester.widget<QuranStrictReaderBody>(find.byType(QuranStrictReaderBody)).variant,
      QuranMushafVariant.qcfV4Tajweed,
    );

    await tester.pageBack();
    await _pumpFlow(tester);
    await tester.pageBack();
    await _pumpFlow(tester);

    await tester.tap(find.text('কুরআন').last);
    await _pumpFlow(tester);
    await tester.tap(find.byType(QuranSurahRow).first);
    await _pumpFlow(tester);

    expect(find.byType(QuranReaderPage), findsOneWidget);
    expect(find.byType(QuranStrictReaderBody), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

class _NoopLocationStore implements ReadingLocationStore {
  @override
  Future<ReadingLocation?> load() async => null;

  @override
  Future<void> save(ReadingLocation location) async {}
}

class _FixtureMushafPageRepository implements QuranMushafPageRepository {
  @override
  Future<bool> isVariantAvailable(QuranMushafVariant variant) async => true;

  @override
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  }) async =>
      QcfMushafPage(page: page, variant: variant, lines: const []);
}

class _UnavailablePageFontRepository implements QuranPageFontRepository {
  @override
  Future<Uri> ensurePageFont(int page) async {
    throw QuranPageFontUnavailableException(
      page: page,
      message: 'offline integration fixture',
    );
  }

  @override
  Future<bool> isCached(int page) async => false;

  @override
  Future<void> prefetchNeighbors(int page) async {}
}

class _FixtureAudioController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState.initial();
}


Future<void> _pumpFlow(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
