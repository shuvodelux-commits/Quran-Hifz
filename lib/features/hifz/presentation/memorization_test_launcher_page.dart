import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/application/quran_providers.dart';
import '../domain/memorization_result.dart';
import 'memorization_test_page.dart';

class MemorizationTestLauncherPage extends ConsumerStatefulWidget {
  const MemorizationTestLauncherPage({super.key});

  @override
  ConsumerState<MemorizationTestLauncherPage> createState() =>
      _MemorizationTestLauncherPageState();
}

class _MemorizationTestLauncherPageState
    extends ConsumerState<MemorizationTestLauncherPage> {
  final _surahController = TextEditingController(text: '1');
  final _ayahController = TextEditingController(text: '1');
  bool _loading = false;

  @override
  void dispose() {
    _surahController.dispose();
    _ayahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memorization Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose a Quran ayah, recite it from memory, then reveal and grade your result.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _surahController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Surah number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ayahController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ayah number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _start,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: const Text('Start test'),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    final surah = int.tryParse(_surahController.text.trim());
    final ayah = int.tryParse(_ayahController.text.trim());
    if (surah == null || ayah == null || surah <= 0 || ayah <= 0) {
      _show('Enter valid Surah and ayah numbers.');
      return;
    }

    setState(() => _loading = true);
    try {
      final quranAyah = await ref
          .read(quranRepositoryProvider)
          .loadAyah(
            surahNumber: surah,
            ayahNumber: ayah,
            translationResourceId: ref.read(quranTranslationResourceIdProvider),
          );
      if (!mounted) return;
      if (quranAyah == null) {
        _show('That ayah was not found in the verified Quran database.');
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MemorizationTestPage(
            ayah: quranAyah,
            mode: MemorizationTestMode.reveal,
            onResult: _onResult,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onResult(MemorizationResult result) {
    Navigator.of(context).pop();
    _show('Recorded result: ${result.name}.');
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
