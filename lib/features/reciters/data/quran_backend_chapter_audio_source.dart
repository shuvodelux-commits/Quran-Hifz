import '../../../core/network/quran_backend_client.dart';
import '../domain/chapter_audio_source.dart';

class QuranBackendChapterAudioSource implements ChapterAudioSource {
  QuranBackendChapterAudioSource(this._client);

  final QuranBackendClient _client;

  @override
  Future<Map<String, dynamic>> loadChapterAudio({
    required int reciterId,
    required int surahNumber,
  }) => _client.getChapterAudio(
    reciterId: reciterId,
    surahNumber: surahNumber,
    segments: true,
  );
}
