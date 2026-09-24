abstract interface class ChapterAudioSource {
  Future<Map<String, dynamic>> loadChapterAudio({
    required int reciterId,
    required int surahNumber,
  });
}
