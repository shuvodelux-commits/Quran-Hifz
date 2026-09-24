import '../domain/quran_page_window.dart';

class ReaderState {
  const ReaderState({
    required this.currentPage,
    required this.windows,
    required this.translationResourceId,
    this.firstPage = 1,
    this.lastPage = 604,
  });

  final int currentPage;
  final Map<int, QuranPageWindow> windows;
  final int translationResourceId;
  final int firstPage;
  final int lastPage;

  QuranPageWindow? get currentWindow => windows[currentPage];

  List<int> get loadedPages {
    final pages = windows.keys.toList()..sort();
    return List.unmodifiable(pages);
  }

  ReaderState copyWith({
    int? currentPage,
    Map<int, QuranPageWindow>? windows,
    int? translationResourceId,
    int? firstPage,
    int? lastPage,
  }) {
    return ReaderState(
      currentPage: currentPage ?? this.currentPage,
      windows: windows ?? this.windows,
      translationResourceId:
          translationResourceId ?? this.translationResourceId,
      firstPage: firstPage ?? this.firstPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}
