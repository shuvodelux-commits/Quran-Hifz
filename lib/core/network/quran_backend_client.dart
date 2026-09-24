import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';

class QuranBackendClient {
  QuranBackendClient({HttpClient? httpClient})
    : _client = httpClient ?? HttpClient();

  final HttpClient _client;

  Future<Map<String, dynamic>> getChapterAudio({
    required int reciterId,
    required int surahNumber,
    bool segments = true,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/quran/chapter-audio'
      '?reciterId=$reciterId'
      '&surah=$surahNumber'
      '&segments=$segments',
    );

    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Backend returned ${response.statusCode}: $body',
        uri: uri,
      );
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getZakariaTafsirManifest() async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/tafsir/bn-zakaria/manifest',
    );

    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Backend returned ${response.statusCode}: $body',
        uri: uri,
      );
    }

    return Map<String, dynamic>.from(jsonDecode(body) as Map);
  }

  Future<List<Map<String, dynamic>>> getChapterReciters() async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/quran/chapter-reciters',
    );

    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Backend returned ${response.statusCode}: $body',
        uri: uri,
      );
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final raw = json['reciters'] as List<dynamic>? ?? const [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void close() => _client.close(force: true);
}
