import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/quran_backend_providers.dart';
import '../data/bundled_chapter_audio_source.dart';
import '../data/bundled_reciter_catalog_source.dart';
import '../data/fallback_chapter_audio_source.dart';
import '../data/fallback_reciter_catalog_source.dart';
import '../data/quran_backend_chapter_audio_source.dart';
import '../data/quran_backend_reciter_catalog_source.dart';
import '../domain/chapter_audio_source.dart';
import '../domain/reciter_catalog_source.dart';

final reciterCatalogSourceProvider = Provider<ReciterCatalogSource>((ref) {
  return FallbackReciterCatalogSource(
    primary: QuranBackendReciterCatalogSource(
      ref.watch(quranBackendClientProvider),
    ),
    fallback: BundledReciterCatalogSource(bundle: rootBundle),
  );
});

final chapterAudioSourceProvider = Provider<ChapterAudioSource>((ref) {
  return FallbackChapterAudioSource(
    primary: QuranBackendChapterAudioSource(
      ref.watch(quranBackendClientProvider),
    ),
    fallback: BundledChapterAudioSource(bundle: rootBundle),
  );
});
