import 'package:flutter/material.dart';

import '../../quran/domain/quran_word.dart';
import '../application/study_controller.dart';
import '../domain/bookmark.dart';

class WordDetailsSheet extends StatefulWidget {
  const WordDetailsSheet({
    super.key,
    required this.target,
    required this.word,
    required this.controller,
  });

  final StudyTarget target;
  final QuranWord word;
  final StudyController controller;

  @override
  State<WordDetailsSheet> createState() => _WordDetailsSheetState();
}

class _WordDetailsSheetState extends State<WordDetailsSheet> {
  final TextEditingController _noteController = TextEditingController();
  StudyState _study = const StudyState();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final state = await widget.controller.load(widget.target);
      if (!mounted) return;
      _noteController.text = state.note?.text ?? '';
      setState(() {
        _study = state;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Could not load study details.');
    }
  }

  Future<void> _toggleBookmark() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final state = await widget.controller.toggleBookmark(widget.target);
      if (!mounted) return;
      setState(() => _study = state);
    } catch (error) {
      if (mounted) _showError('Could not update bookmark.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveNote() async {
    if (_saving) return;
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      _showError('Write a note before saving.');
      return;
    }

    setState(() => _saving = true);
    try {
      final state = await widget.controller.saveNote(widget.target, text);
      if (!mounted) return;
      _noteController.text = state.note?.text ?? text;
      setState(() => _study = state);
    } catch (error) {
      if (mounted) _showError('Could not save note.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteNote() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final state = await widget.controller.deleteNote(widget.target);
      if (!mounted) return;
      _noteController.clear();
      setState(() => _study = state);
    } catch (error) {
      if (mounted) _showError('Could not delete note.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              word.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 42, height: 1.6),
            ),
            if (word.transliteration != null)
              Text(
                word.transliteration!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            const SizedBox(height: 12),
            if (word.banglaMeaning != null)
              _DetailRow(label: 'বাংলা', value: word.banglaMeaning!),
            if (word.englishMeaning != null)
              _DetailRow(label: 'English', value: word.englishMeaning!),
            if (word.root != null) _DetailRow(label: 'Root', value: word.root!),
            if (word.lemma != null)
              _DetailRow(label: 'Lemma', value: word.lemma!),
            if (word.grammar != null)
              _DetailRow(label: 'Grammar', value: word.grammar!),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _toggleBookmark,
                icon: Icon(
                  _study.isBookmarked
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  _study.isBookmarked ? 'Remove bookmark' : 'Bookmark',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Add a study note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _saveNote,
                      child: const Text('Save note'),
                    ),
                  ),
                  if (_study.note != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Delete note',
                      onPressed: _saving ? null : _deleteNote,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
