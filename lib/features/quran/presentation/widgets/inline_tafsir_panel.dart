import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tafsir/application/tafsir_providers.dart';
import '../../../tafsir/domain/tafsir_catalog.dart';
import '../../../tafsir/domain/tafsir_entry.dart';
import '../../../tafsir/presentation/tafsir_reader_page.dart';

class InlineTafsirPanel extends ConsumerStatefulWidget {
  const InlineTafsirPanel({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  ConsumerState<InlineTafsirPanel> createState() => _InlineTafsirPanelState();
}

class _InlineTafsirPanelState extends ConsumerState<InlineTafsirPanel> {
  Future<_InlineTafsirState>? _future;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('Tafsir'),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(Icons.expand_more_rounded),
          ),
          onTap: _toggleExpanded,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildExpandedBody(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded && _future == null) {
        _future = _load();
      }
    });
  }

  Widget _buildExpandedBody() {
    final future = _future;
    if (future == null) return const SizedBox.shrink();

    return FutureBuilder<_InlineTafsirState>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return _MessageBody(
            message: 'Installed tafsir could not be opened.',
            actionLabel: 'Open tafsir',
            onAction: _openFullTafsir,
          );
        }

        final state = snapshot.data ?? const _InlineTafsirState();
        if (state.source == null) {
          return _MessageBody(
            title: primaryBanglaTafsirName,
            message:
                'Download the primary Bangla tafsir once to read it inline and offline.',
            actionLabel: 'Set up tafsir',
            onAction: _openFullTafsir,
          );
        }

        final entry = state.entry;
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.source!.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open full tafsir',
                    onPressed: _openFullTafsir,
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ],
              ),
              if (entry == null)
                const Text(
                  'This tafsir source has no entry for the selected ayah.',
                )
              else
                Text(
                  entry.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.65),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<_InlineTafsirState> _load() async {
    final repository = ref.read(tafsirRepositoryProvider);
    final sources = await repository.listInstalledSources();
    if (sources.isEmpty) return const _InlineTafsirState();

    final source = sources.firstWhere(
      (item) => item.sourceId == primaryBanglaTafsirSourceId,
      orElse: () => sources.first,
    );
    final entry = await repository.readAyah(
      sourceId: source.sourceId,
      surahNumber: widget.surahNumber,
      ayahNumber: widget.ayahNumber,
    );
    return _InlineTafsirState(source: source, entry: entry);
  }

  Future<void> _openFullTafsir() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TafsirReaderPage(
          surahNumber: widget.surahNumber,
          ayahNumber: widget.ayahNumber,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }
}

class _InlineTafsirState {
  const _InlineTafsirState({this.source, this.entry});

  final TafsirSource? source;
  final TafsirEntry? entry;
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String? title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
          ],
          Text(message),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
