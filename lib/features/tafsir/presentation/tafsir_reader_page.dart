import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tafsir_providers.dart';
import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_entry.dart';
import '../domain/tafsir_repository.dart';

class TafsirReaderPage extends ConsumerStatefulWidget {
  const TafsirReaderPage({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    this.wholeSurah = false,
    this.ayahCount,
  });

  final int surahNumber;
  final int ayahNumber;
  final bool wholeSurah;
  final int? ayahCount;

  @override
  ConsumerState<TafsirReaderPage> createState() => _TafsirReaderPageState();
}

class _TafsirReaderPageState extends ConsumerState<TafsirReaderPage> {
  String? _selectedSourceId;
  bool _includeRemoteSources = false;
  late Future<_TafsirViewState> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TafsirViewState> _load() async {
    final repository = ref.read(tafsirRepositoryProvider);
    final selectionStore = ref.read(tafsirSourceSelectionStoreProvider);
    final saved = _selectedSourceId ?? await selectionStore.read();
    final savedRemote = saved?.startsWith('qf.') ?? false;
    final includeRemote = _includeRemoteSources || savedRemote;
    final TafsirAvailableSources? availableRepository =
        repository is TafsirAvailableSources
        ? repository as TafsirAvailableSources
        : null;
    final sources = includeRemote && availableRepository != null
        ? await availableRepository.listAvailableSources()
        : await repository.listInstalledSources();
    if (sources.isEmpty) return const _TafsirViewState(sources: []);

    final selected =
        saved != null && sources.any((source) => source.sourceId == saved)
        ? saved
        : sources.any(
            (source) => source.sourceId == primaryBanglaTafsirSourceId,
          )
        ? primaryBanglaTafsirSourceId
        : sources.first.sourceId;
    _selectedSourceId = selected;
    if (saved != selected && !savedRemote) {
      await selectionStore.write(selected);
    }

    if (widget.wholeSurah) {
      final entries = await repository.readSurah(
        sourceId: selected,
        surahNumber: widget.surahNumber,
      );
      return _TafsirViewState(sources: sources, entries: entries);
    }
    final entry = await repository.readAyah(
      sourceId: selected,
      surahNumber: widget.surahNumber,
      ayahNumber: widget.ayahNumber,
    );
    return _TafsirViewState(sources: sources, entry: entry);
  }

  Future<void> _selectSource(String sourceId) async {
    await ref.read(tafsirSourceSelectionStoreProvider).write(sourceId);
    if (!mounted) return;
    setState(() {
      _selectedSourceId = sourceId;
      _includeRemoteSources =
          _includeRemoteSources || sourceId.startsWith('qf.');
      _future = _load();
    });
  }

  void _loadMoreTafsirs() {
    setState(() {
      _includeRemoteSources = true;
      _future = _load();
    });
  }

  Widget _sourceControls(_TafsirViewState state) {
    final showSelector = state.sources.length > 1;
    final showMore =
        !_includeRemoteSources &&
        !(_selectedSourceId?.startsWith('qf.') ?? false);
    if (!showSelector && !showMore) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSelector)
          DropdownButtonFormField<String>(
            initialValue: _selectedSourceId,
            decoration: const InputDecoration(labelText: 'Tafsir source'),
            items: [
              for (final source in state.sources)
                DropdownMenuItem(
                  value: source.sourceId,
                  child: Text(source.name),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                unawaited(_selectSource(value));
              }
            },
          ),
        if (showMore)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('load-more-tafsirs'),
              onPressed: _loadMoreTafsirs,
              icon: const Icon(Icons.public_rounded, size: 18),
              label: const Text('More Tafsirs'),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.wholeSurah
              ? 'Surah ${widget.surahNumber} Tafsir'
              : 'Tafsir · ${widget.surahNumber}:${widget.ayahNumber}',
        ),
      ),
      body: FutureBuilder<_TafsirViewState>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Installed tafsir could not be opened.'),
            );
          }
          final state = snapshot.data ?? const _TafsirViewState(sources: []);
          if (state.sources.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No Tafsir sources are available.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final entry = state.entry;
          final selectedSource = state.sources.firstWhere(
            (source) => source.sourceId == _selectedSourceId,
            orElse: () => state.sources.first,
          );
          if (widget.wholeSurah) {
            final entries = state.entries;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sourceControls(state),
                      Text(
                        selectedSource.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (selectedSource.kind == TafsirSourceKind.remote)
                        Text(
                          'Online source · internet required',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      if (entries.isEmpty)
                        const Text('This source has no Tafsir for this Surah.'),
                      const SizedBox(height: 12),
                    ],
                  );
                final entry = entries[index - 1];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ayah ${entry.ayahNumber}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.text,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.65),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sourceControls(state),
              Text(
                entry?.sourceName ?? selectedSource.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (selectedSource.kind == TafsirSourceKind.remote) ...[
                const SizedBox(height: 2),
                Text(
                  'Online source · internet required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (entry == null)
                const Text(
                  'This tafsir source has no entry for the selected ayah.',
                )
              else ...[
                Text(
                  entry.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.65),
                ),
                if (entry.attribution != null &&
                    entry.attribution!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Source', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(entry.attribution!),
                ],
                if (entry.license != null &&
                    entry.license!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'License',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(entry.license!),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TafsirViewState {
  const _TafsirViewState({
    required this.sources,
    this.entry,
    this.entries = const [],
  });

  final List<TafsirSource> sources;
  final TafsirEntry? entry;
  final List<TafsirEntry> entries;
}
