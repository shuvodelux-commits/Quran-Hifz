import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class HifzSystemUi {
  Future<void> enter();

  Future<void> restore();
}

class FlutterHifzSystemUi implements HifzSystemUi {
  const FlutterHifzSystemUi();

  @override
  Future<void> enter() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  @override
  Future<void> restore() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

final hifzSystemUiProvider = Provider<HifzSystemUi>(
  (ref) => const FlutterHifzSystemUi(),
);
