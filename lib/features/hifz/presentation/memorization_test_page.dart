import 'package:flutter/material.dart';

import '../../quran/domain/quran_ayah.dart';
import '../application/progressive_hide_generator.dart';
import '../domain/memorization_result.dart';

enum MemorizationTestMode { reveal, progressiveHide }

class MemorizationTestPage extends StatefulWidget {
  const MemorizationTestPage({
    super.key,
    required this.ayah,
    required this.mode,
    required this.onResult,
    this.progressiveRound = 1,
    this.difficulty = ProgressiveHideDifficulty.easy,
    this.hideSeed = 0,
  });

  final QuranAyah ayah;
  final MemorizationTestMode mode;
  final ValueChanged<MemorizationResult> onResult;
  final int progressiveRound;
  final ProgressiveHideDifficulty difficulty;
  final int hideSeed;

  @override
  State<MemorizationTestPage> createState() => _MemorizationTestPageState();
}

class _MemorizationTestPageState extends State<MemorizationTestPage> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final visibleMask = _revealed
        ? List<bool>.filled(widget.ayah.words.length, true)
        : _initialMask();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memorization Test · ${widget.ayah.surahNumber}:${widget.ayah.ayahNumber}',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.mode == MemorizationTestMode.reveal
                  ? 'Recite the ayah from memory, then reveal it.'
                  : 'Recite the missing words, then reveal the full ayah.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 14,
                children: [
                  for (var index = 0; index < widget.ayah.words.length; index++)
                    _WordOrPlaceholder(
                      arabic: widget.ayah.words[index].arabic,
                      visible: visibleMask[index],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (!_revealed)
              FilledButton.icon(
                onPressed: () => setState(() => _revealed = true),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Reveal'),
              ),
            if (_revealed) ...[
              Text(
                'How well did you remember it?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _ResultButton(
                label: 'Perfect',
                result: MemorizationResult.perfect,
                onPressed: widget.onResult,
              ),
              _ResultButton(
                label: 'Small Mistake',
                result: MemorizationResult.smallMistake,
                onPressed: widget.onResult,
              ),
              _ResultButton(
                label: 'Difficult',
                result: MemorizationResult.difficult,
                onPressed: widget.onResult,
              ),
              _ResultButton(
                label: 'Forgot',
                result: MemorizationResult.forgot,
                onPressed: widget.onResult,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<bool> _initialMask() {
    if (widget.mode == MemorizationTestMode.reveal) {
      return List<bool>.filled(widget.ayah.words.length, false);
    }

    return ProgressiveHideGenerator(seed: widget.hideSeed).maskFor(
      widget.ayah.words,
      round: widget.progressiveRound,
      difficulty: widget.difficulty,
    );
  }
}

class _WordOrPlaceholder extends StatelessWidget {
  const _WordOrPlaceholder({required this.arabic, required this.visible});

  final String arabic;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: visible ? arabic : 'Hidden Quran word',
      child: Text(
        visible ? arabic : '••••',
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 30,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    required this.result,
    required this.onPressed,
  });

  final String label;
  final MemorizationResult result;
  final ValueChanged<MemorizationResult> onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => onPressed(result),
        child: Text(label),
      ),
    );
  }
}
