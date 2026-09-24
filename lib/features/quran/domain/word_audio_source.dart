class QuranWordAudioSource {
  const QuranWordAudioSource({
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordPosition,
    required this.remotePath,
  });

  final int surahNumber;
  final int ayahNumber;
  final int wordPosition;
  final String remotePath;
}

abstract interface class SurahWordAudioCatalog {
  Future<List<QuranWordAudioSource>> listForSurah(int surahNumber);
}
