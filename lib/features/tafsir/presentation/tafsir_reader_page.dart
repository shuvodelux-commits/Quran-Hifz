import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tafsir_providers.dart';
import '../domain/tafsir_catalog.dart';
import '../domain/tafsir_entry.dart';

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
  String? _installError;
  bool _installing = false;
  late Future<_TafsirViewState> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TafsirViewState> _load() async {
    final repository = ref.read(tafsirRepositoryProvider);
    final sources = await repository.listInstalledSources();
    if (sources.isEmpty) return const _TafsirViewState(sources: []);

    final selected =
        sources.any((source) => source.sourceId == _selectedSourceId)
        ? _selectedSourceId!
        : sources.any(
            (source) => source.sourceId == primaryBanglaTafsirSourceId,
          )
        ? primaryBanglaTafsirSourceId
        : sources.first.sourceId;
    _selectedSourceId = selected;
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

  void _selectSource(String sourceId) {
    setState(() {
      _selectedSourceId = sourceId;
      _future = _load();
    });
  }

  Future<void> _installPrimaryBanglaTafsir() async {
    setState(() {
      _installing = true;
      _installError = null;
    });
    try {
      final manifest = await ref
          .read(tafsirCatalogProvider)
          .fetchPrimaryBanglaManifest();
      await ref.read(tafsirPackageInstallerProvider).install(manifest);
      if (!mounted) return;
      setState(() {
        _selectedSourceId = primaryBanglaTafsirSourceId;
        _future = _load();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _installError =
            'Tafsir package could not be installed. Check the connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _installing = false;
        });
      }
    }
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      primaryBanglaTafsirName,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Primary Bangla tafsir source. Download once for verified offline reading.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _installing
                          ? null
                          : _installPrimaryBanglaTafsir,
                      icon: _installing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(
                        _installing ? 'Installing…' : 'Download tafsir',
                      ),
                    ),
                    if (_installError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _installError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
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
                      if (state.sources.length > 1)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSourceId,
                          decoration: const InputDecoration(
                            labelText: 'Tafsir source',
                          ),
                          items: [
                            for (final source in state.sources)
                              DropdownMenuItem(
                                value: source.sourceId,
                                child: Text(source.name),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) _selectSource(value);
                          },
                        ),
                      Text(
                        selectedSource.name,
                        style: Theme.of(context).textTheme.titleLarge,
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
              if (state.sources.length > 1)
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
                    if (value != null) _selectSource(value);
                  },
                ),
              if (state.sources.length > 1) const SizedBox(height: 16),
              Text(
                entry?.sourceName ?? selectedSource.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
