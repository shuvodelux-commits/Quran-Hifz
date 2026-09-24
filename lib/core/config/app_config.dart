class AppConfig {
  AppConfig._();

  static const productionBackendBaseUrl =
      'https://quran-hifz-api.shoaibadmisec.workers.dev';

  static const backendBaseUrl = String.fromEnvironment(
    'QURAN_BACKEND_URL',
    defaultValue: productionBackendBaseUrl,
  );

  static const wordAudioCdnBase = 'https://audio.qurancdn.com/';
  static const audioUserAgent = 'QuranHifz/1.0';
}
