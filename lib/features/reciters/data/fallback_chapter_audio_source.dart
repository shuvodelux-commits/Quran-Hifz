import '../domain/chapter_audio_source.dart';

class FallbackChapterAudioSource implements ChapterAudioSource {
  FallbackChapterAudioSource({
    required ChapterAudioSource primary,
    required ChapterAudioSource fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final ChapterAudioSource _primary;
  final ChapterAudioSource _fallback;

  @override
  Future<Map<String, dynamic>> loadChapterAudio({
    required int reciterId,
    required int surahNumber,
  }) async {
    try {
      return await _primary.loadChapterAudio(
        reciterId: reciterId,
        surahNumber: surahNumber,
      );
    } catch (_) {
      return _fallback.loadChapterAudio(
        reciterId: reciterId,
        surahNumber: surahNumber,
      );
    }
  }
}
