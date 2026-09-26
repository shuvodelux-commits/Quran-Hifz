import 'quran_mushaf_page.dart';
import 'quran_mushaf_variant.dart';

class MushafDataIntegrityException implements Exception {
  const MushafDataIntegrityException(this.message);
  final String message;
  @override
  String toString() => 'MushafDataIntegrityException: $message';
}

class MushafVariantUnavailableException implements Exception {
  const MushafVariantUnavailableException(this.variant);
  final QuranMushafVariant variant;
  @override
  String toString() => 'Mushaf variant is unavailable: ${variant.name}';
}

abstract interface class QuranMushafPageRepository {
  Future<QcfMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  });

  Future<bool> isVariantAvailable(QuranMushafVariant variant);
}
