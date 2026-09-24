import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/dua_providers.dart';
import '../domain/custom_dua.dart';

class CustomDuaFormPage extends ConsumerStatefulWidget {
  const CustomDuaFormPage({super.key, this.initial});

  final CustomDua? initial;

  @override
  ConsumerState<CustomDuaFormPage> createState() => _CustomDuaFormPageState();
}

class _CustomDuaFormPageState extends ConsumerState<CustomDuaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _arabicController;
  late final TextEditingController _transliterationController;
  late final TextEditingController _meaningController;
  late final TextEditingController _referenceController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _arabicController = TextEditingController(text: initial?.arabic ?? '');
    _transliterationController = TextEditingController(
      text: initial?.transliteration ?? '',
    );
    _meaningController = TextEditingController(text: initial?.meaning ?? '');
    _referenceController = TextEditingController(
      text: initial?.reference ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _arabicController.dispose();
    _transliterationController.dispose();
    _meaningController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String? _required(String? value, AppLanguage language) {
    if (value == null || value.trim().isEmpty) {
      return appText(language, 'এই ঘরটি পূরণ করুন', 'This field is required');
    }
    return null;
  }

  Future<void> _save(AppLanguage language) async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(customDuasProvider.notifier);
      final saved = widget.initial == null
          ? await notifier.create(
              title: _titleController.text,
              arabic: _arabicController.text,
              transliteration: _transliterationController.text,
              meaning: _meaningController.text,
              reference: _referenceController.text,
            )
          : await notifier.edit(
              id: widget.initial!.id,
              title: _titleController.text,
              arabic: _arabicController.text,
              transliteration: _transliterationController.text,
              meaning: _meaningController.text,
              reference: _referenceController.text,
            );
      if (mounted) Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(language, 'দোয়া সংরক্ষণ করা যায়নি', 'Could not save Dua'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final isEditing = widget.initial != null;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          isEditing
              ? appText(language, 'দোয়া সম্পাদনা', 'Edit Dua')
              : appText(language, 'দোয়া যোগ করুন', 'Add Dua'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              TextFormField(
                key: const ValueKey('custom-dua-title'),
                controller: _titleController,
                validator: (value) => _required(value, language),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: appText(language, 'নাম', 'Title'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('custom-dua-arabic'),
                controller: _arabicController,
                validator: (value) => _required(value, language),
                minLines: 3,
                maxLines: 6,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 22,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  labelText: appText(language, 'আরবি', 'Arabic'),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('custom-dua-transliteration'),
                controller: _transliterationController,
                validator: (value) => _required(value, language),
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: appText(language, 'উচ্চারণ', 'Transliteration'),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('custom-dua-meaning'),
                controller: _meaningController,
                validator: (value) => _required(value, language),
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: appText(language, 'অর্থ', 'Meaning'),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('custom-dua-reference'),
                controller: _referenceController,
                validator: (value) => _required(value, language),
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: appText(language, 'সূত্র', 'Reference'),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const ValueKey('custom-dua-save'),
                onPressed: _saving ? null : () => _save(language),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isEditing
                      ? appText(language, 'পরিবর্তন সংরক্ষণ', 'Save changes')
                      : appText(language, 'দোয়া সংরক্ষণ', 'Save Dua'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
