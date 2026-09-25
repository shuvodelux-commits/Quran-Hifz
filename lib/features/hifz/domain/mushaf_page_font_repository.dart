abstract interface class MushafPageFontRepository {
  Future<Uri> ensurePageFont(int page);

  Future<void> prefetchNeighbors(int page);

  Future<bool> isCached(int page);
}
