import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quran_backend_client.dart';

final quranBackendClientProvider = Provider<QuranBackendClient>((ref) {
  final client = QuranBackendClient();
  ref.onDispose(client.close);
  return client;
});
