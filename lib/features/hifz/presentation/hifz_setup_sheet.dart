import 'package:flutter/material.dart';

import '../../quran/domain/quran_surah.dart';
import '../domain/hifz_preset.dart';

class HifzSetupResult {
  const HifzSetupResult({
    required this.startAyah,
    required this.endAyah,
    required this.preset,
  });

  final int startAyah;
  final int endAyah;
  final HifzPreset preset;
}

class HifzSetupSheet extends StatefulWidget {
  const HifzSetupSheet({
    required this.surah,
    required this.initialStartAyah,
    required this.initialEndAyah,
    required this.initialPreset,
    super.key,
  });

  final QuranSurahSummary surah;
  final int initialStartAyah;
  final int initialEndAyah;
  final HifzPreset initialPreset;

  @override
  State<HifzSetupSheet> createState() => _HifzSetupSheetState();
}

class _HifzSetupSheetState extends State<HifzSetupSheet> {
  late int _startAyah;
  late int _endAyah;
  late int _ayahRepeatCount;

  @override
  void initState() {
    super.initState();
    _startAyah = widget.initialStartAyah.clamp(1, widget.surah.ayahCount);
    _endAyah = widget.initialEndAyah.clamp(
      _startAyah,
      widget.surah.ayahCount,
    );
    _ayahRepeatCount = widget.initialPreset.ayahRepeatCount;
  }

  HifzPreset get _preset => HifzPresets.progressive(
    ayahRepeatCount: _ayahRepeatCount,
    combinedRepeatCount: widget.initialPreset.combinedRepeatCount,
    finalRangeRepeatCount: widget.initialPreset.finalRangeRepeatCount,
    pauseBetweenRepeats: widget.initialPreset.pauseBetweenRepeats,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.surah.nameEnglish,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              widget.surah.nameArabic,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SetupRow(
                    key: const ValueKey('hifz-start-ayah'),
                    label: 'Start ayah',
                    value: _startAyah.toString(),
                    onTap: _chooseStart,
                  ),
                  const Divider(height: 1),
                  _SetupRow(
                    key: const ValueKey('hifz-end-ayah'),
                    label: 'End ayah',
                    value: _endAyah.toString(),
                    onTap: _chooseEnd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Repetition',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              key: const ValueKey('hifz-repeat-count'),
              initialValue: _ayahRepeatCount,
              decoration: const InputDecoration(
                labelText: 'Each new ayah',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [1, 2, 3, 5, 10, 20]
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString() + '×'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _ayahRepeatCount = value);
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Ayah ' +
                  _startAyah.toString() +
                  '–' +
                  _endAyah.toString(),
              key: const ValueKey('hifz-setup-range-summary'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('hifz-setup-start'),
              onPressed: () => Navigator.of(context).pop(
                HifzSetupResult(
                  startAyah: _startAyah,
                  endAyah: _endAyah,
                  preset: _preset,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('হিফজ শুরু করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseStart() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _HifzAyahPicker(
        title: 'Start ayah',
        minimum: 1,
        maximum: widget.surah.ayahCount,
        selected: _startAyah,
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _startAyah = selected;
      if (_endAyah < selected) _endAyah = selected;
    });
  }

  Future<void> _chooseEnd() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _HifzAyahPicker(
        title: 'End ayah',
        minimum: _startAyah,
        maximum: widget.surah.ayahCount,
        selected: _endAyah,
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _endAyah = selected);
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 52,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _HifzAyahPicker extends StatefulWidget {
  const _HifzAyahPicker({
    required this.title,
    required this.minimum,
    required this.maximum,
    required this.selected,
  });

  final String title;
  final int minimum;
  final int maximum;
  final int selected;

  @override
  State<_HifzAyahPicker> createState() => _HifzAyahPickerState();
}

class _HifzAyahPickerState extends State<_HifzAyahPicker> {
  static const _itemExtent = 52.0;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    final selectedIndex = widget.selected - widget.minimum;
    _controller = ScrollController(
      initialScrollOffset: selectedIndex <= 0
          ? 0
          : (selectedIndex - 1) * _itemExtent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.62,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemExtent: _itemExtent,
                itemCount: widget.maximum - widget.minimum + 1,
                itemBuilder: (context, index) {
                  final ayah = widget.minimum + index;
                  return ListTile(
                    key: ValueKey(
                      'hifz-ayah-choice-' + ayah.toString(),
                    ),
                    title: Text('Ayah ' + ayah.toString()),
                    selected: widget.selected == ayah,
                    trailing: widget.selected == ayah
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(context).pop(ayah),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
