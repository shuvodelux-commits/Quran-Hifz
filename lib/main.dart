import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/quran_hifz_app.dart';

Widget buildRootApp() {
  return const ProviderScope(child: QuranHifzApp());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildRootApp());
}
