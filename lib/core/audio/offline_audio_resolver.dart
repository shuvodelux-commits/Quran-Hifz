import 'dart:io';

import '../database/user_database.dart';

abstract class AudioSourceResolver {
  Future<String?> resolve(String audioKey);
}

class OfflineAudioResolver implements AudioSourceResolver {
  OfflineAudioResolver(this._database);

  final UserDatabase _database;

  @override
  Future<String?> resolve(String audioKey) async {
    final row = await _database.getAudio(audioKey);
    if (row == null) return null;

    final localPath = row.localPath;
    if (localPath != null &&
        localPath.isNotEmpty &&
        !localPath.endsWith('.part')) {
      final file = File(localPath);
      if (await file.exists() && await file.length() > 0) {
        return localPath;
      }
    }

    return row.remoteUrl.isEmpty ? null : row.remoteUrl;
  }
}
