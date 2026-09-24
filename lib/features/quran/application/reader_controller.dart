import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quran_page_window.dart';
import 'quran_providers.dart';
import 'reader_state.dart';

class ReadingLocation {
  const ReadingLocation({
    required this.page,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int page;
  final int surahNumber;
  final int ayahNumber;
}

abstract class ReadingLocationStore {
  Future<ReadingLocation?> load();
  Future<void> save(ReadingLocation location);
}

abstract class SurahReadingLocationStore {
  Future<ReadingLocation?> loadForSurah(int surahNumber);
  Future<void> saveForSurah(ReadingLocation location);
}

class ReaderController extends AsyncNotifier<ReaderState> {
  static const int firstPage = 1;
  static const int lastPage = 604;

  @override
  Future<ReaderState> build() async {
    final saved = await ref.read(readingLocationStoreProvider).load();
    final page = (saved?.page ?? firstPage).clamp(firstPage, lastPage).toInt();
    final translationResourceId = ref.read(quranTranslationResourceIdProvider);
    return _loadBoundedState(
      page: page,
      translationResourceId: translationResourceId,
    );
  }

  Future<void> openPage(
    int page, {
    int? preferredSurahNumber,
    int firstPage = ReaderController.firstPage,
    int lastPage = ReaderController.lastPage,
  }) async {
    final bounded = page.clamp(firstPage, lastPage).toInt();
    final previous = state.value;
    final int translationResourceId =
        previous?.translationResourceId ??
        ref.read(quranTranslationResourceIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _loadBoundedState(
        page: bounded,
        translationResourceId: translationResourceId,
        existingWindows: previous?.windows ?? const {},
        firstPage: firstPage,
        lastPage: lastPage,
      ),
    );

    final loaded = state.value?.currentWindow;
    if (loaded != null && loaded.ayahs.isNotEmpty) {
      final firstAyah = preferredSurahNumber == null
          ? loaded.ayahs.first
          : loaded.ayahs.firstWhere(
              (ayah) => ayah.surahNumber == preferredSurahNumber,
              orElse: () => loaded.ayahs.first,
            );
      await ref
          .read(readingLocationStoreProvider)
          .save(
            ReadingLocation(
              page: bounded,
              surahNumber: firstAyah.surahNumber,
              ayahNumber: firstAyah.ayahNumber,
            ),
          );
    }
  }

  Future<void> nextPage() async {
    final value = state.value;
    final current = value?.currentPage ?? firstPage;
    if (current < (value?.lastPage ?? lastPage)) {
      await openPage(
        current + 1,
        firstPage: value?.firstPage ?? firstPage,
        lastPage: value?.lastPage ?? lastPage,
      );
    }
  }

  Future<void> previousPage() async {
    final value = state.value;
    final current = value?.currentPage ?? firstPage;
    if (current > (value?.firstPage ?? firstPage)) {
      await openPage(
        current - 1,
        firstPage: value?.firstPage ?? firstPage,
        lastPage: value?.lastPage ?? lastPage,
      );
    }
  }

  Future<void> loadNextWindow() async {
    final current = state.value;
    if (current == null || current.loadedPages.isEmpty) return;
    final nextPage = current.loadedPages.last + 1;
    if (nextPage > current.lastPage || current.windows.containsKey(nextPage)) {
      return;
    }

    final window = await ref
        .read(quranRepositoryProvider)
        .loadPageWindow(
          page: nextPage,
          translationResourceId: current.translationResourceId,
        );
    state = AsyncData(
      current.copyWith(windows: {...current.windows, window.page: window}),
    );
  }

  Future<void> loadPreviousWindow() async {
    final current = state.value;
    if (current == null || current.loadedPages.isEmpty) return;
    final previousPage = current.loadedPages.first - 1;
    if (previousPage < current.firstPage ||
        current.windows.containsKey(previousPage)) {
      return;
    }

    final window = await ref
        .read(quranRepositoryProvider)
        .loadPageWindow(
          page: previousPage,
          translationResourceId: current.translationResourceId,
        );
    state = AsyncData(
      current.copyWith(windows: {window.page: window, ...current.windows}),
    );
  }

  Future<ReaderState> _loadBoundedState({
    required int page,
    required int translationResourceId,
    Map<int, QuranPageWindow> existingWindows = const {},
    int firstPage = ReaderController.firstPage,
    int lastPage = ReaderController.lastPage,
  }) async {
    final repository = ref.read(quranRepositoryProvider);
    final pages = <int>{
      if (page > firstPage) page - 1,
      page,
      if (page < lastPage) page + 1,
    }.toList()..sort();

    final loaded = await Future.wait(
      pages.map((candidate) async {
        final cached = existingWindows[candidate];
        if (cached != null) return cached;
        return repository.loadPageWindow(
          page: candidate,
          translationResourceId: translationResourceId,
        );
      }),
    );

    return ReaderState(
      currentPage: page,
      windows: {for (final window in loaded) window.page: window},
      translationResourceId: translationResourceId,
      firstPage: firstPage,
      lastPage: lastPage,
    );
  }
}

final readerControllerProvider =
    AsyncNotifierProvider<ReaderController, ReaderState>(ReaderController.new);
