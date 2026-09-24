import '../../../core/database/user_database.dart';
import '../domain/audio_timing.dart';

class DriftTimingRepository implements TimingRepository {
  DriftTimingRepository(this._database);

  final UserDatabase _database;

  @override
  Future<AyahAudioTiming?> getAyahTiming({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final record = await _database.getAyahTiming(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    if (record == null || record.endMs <= record.startMs) return null;

    return AyahAudioTiming(
      start: Duration(milliseconds: record.startMs),
      end: Duration(milliseconds: record.endMs),
    );
  }

  @override
  Future<List<WordAudioTiming>> getWordTimings({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final records = await _database.getWordTimings(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    return [
      for (final record in records)
        if (record.endMs > record.startMs)
          WordAudioTiming(
            wordPosition: record.wordPosition,
            start: Duration(milliseconds: record.startMs),
            end: Duration(milliseconds: record.endMs),
          ),
    ];
  }
}
