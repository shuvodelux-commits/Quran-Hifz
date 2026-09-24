import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hifz/core/config/app_config.dart';

void main() {
  test('production backend default is the deployed HTTPS worker', () {
    expect(
      AppConfig.productionBackendBaseUrl,
      'https://quran-hifz-api.shoaibadmisec.workers.dev',
    );
    expect(Uri.parse(AppConfig.productionBackendBaseUrl).scheme, 'https');
  });

  test('QURAN_BACKEND_URL remains a compile-time override', () {
    const expectedBackendUrl = String.fromEnvironment(
      'EXPECTED_BACKEND_URL',
      defaultValue: AppConfig.productionBackendBaseUrl,
    );

    expect(AppConfig.backendBaseUrl, expectedBackendUrl);
  });
  test('preserves the audio HTTP client identity', () {
    expect(AppConfig.audioUserAgent, 'QuranHifz/1.0');
  });
}
