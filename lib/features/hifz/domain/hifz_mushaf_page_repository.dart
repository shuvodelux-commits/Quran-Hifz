import 'hifz_mushaf_page.dart';
import 'hifz_reading_mode.dart';
import 'hifz_session.dart';

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

abstract interface class HifzMushafPageRepository {
  Future<HifzMushafPage> loadPage({
    required QuranMushafVariant variant,
    required int page,
  });

  Future<int?> pageForAyah({
    required QuranMushafVariant variant,
    required AyahRef ayah,
  });

  Future<bool> isVariantAvailable(QuranMushafVariant variant);
}
