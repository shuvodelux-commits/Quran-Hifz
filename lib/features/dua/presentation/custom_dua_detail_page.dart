import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/dua_providers.dart';
import '../domain/custom_dua.dart';
import 'custom_dua_form_page.dart';

class CustomDuaDetailPage extends ConsumerStatefulWidget {
  const CustomDuaDetailPage({super.key, required this.dua});

  final CustomDua dua;

  @override
  ConsumerState<CustomDuaDetailPage> createState() =>
      _CustomDuaDetailPageState();
}

class _CustomDuaDetailPageState extends ConsumerState<CustomDuaDetailPage> {
  late CustomDua _dua;

  @override
  void initState() {
    super.initState();
    _dua = widget.dua;
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<CustomDua>(
      MaterialPageRoute<CustomDua>(
        builder: (_) => CustomDuaFormPage(initial: _dua),
      ),
    );
    if (saved != null && mounted) {
      setState(() => _dua = saved);
    }
  }

  Future<void> _confirmDelete(AppLanguage language) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(language, 'দোয়া মুছবেন?', 'Delete Dua?')),
        content: Text(
          appText(
            language,
            'এই ব্যক্তিগত দোয়াটি স্থায়ীভাবে মুছে যাবে।',
            'This custom Dua will be permanently deleted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(appText(language, 'বাতিল', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(appText(language, 'মুছুন', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(customDuasProvider.notifier).delete(_dua.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(
              language,
              'দোয়া মুছতে সমস্যা হয়েছে',
              'Could not delete Dua',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(_dua.title),
        actions: [
          IconButton(
            key: const ValueKey('custom-dua-detail-edit'),
            tooltip: appText(language, 'সম্পাদনা করুন', 'Edit'),
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const ValueKey('custom-dua-detail-delete'),
            tooltip: appText(language, 'মুছুন', 'Delete'),
            onPressed: () => _confirmDelete(language),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                appText(language, 'ব্যক্তিগত দোয়া', 'Custom'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _dua.arabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontFamily: 'QPC Hafs',
                  fontSize: 27,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _CustomTextSection(
            heading: appText(language, 'উচ্চারণ', 'Transliteration'),
            body: _dua.transliteration,
          ),
          const SizedBox(height: 16),
          _CustomTextSection(
            heading: appText(language, 'অর্থ', 'Meaning'),
            body: _dua.meaning,
          ),
          const SizedBox(height: 16),
          _CustomTextSection(
            heading: appText(language, 'সূত্র', 'Reference'),
            body: _dua.reference,
          ),
        ],
      ),
    );
  }
}

class _CustomTextSection extends StatelessWidget {
  const _CustomTextSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
