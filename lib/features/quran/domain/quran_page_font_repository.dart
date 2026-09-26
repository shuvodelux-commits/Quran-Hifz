abstract interface class QuranPageFontRepository {
  Future<Uri> ensurePageFont(int page);

  Future<void> prefetchNeighbors(int page);

  Future<bool> isCached(int page);
}

class QuranPageFontUnavailableException implements Exception {
  const QuranPageFontUnavailableException({
    required this.page,
    required this.message,
    this.cause,
  });

  final int page;
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'QuranPageFontUnavailableException(page: $page, message: $message)';
}
