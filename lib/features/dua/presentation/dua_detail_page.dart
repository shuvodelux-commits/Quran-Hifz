import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_text.dart';
import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../domain/dua.dart';
import 'dua_source_label.dart';

class DuaDetailPage extends ConsumerWidget {
  const DuaDetailPage({super.key, required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final scheme = Theme.of(context).colorScheme;
    final title = language == AppLanguage.bangla
        ? dua.titleBangla
        : dua.titleEnglish;
    final pronunciation = language == AppLanguage.bangla
        ? dua.banglaPronunciation
        : dua.englishTransliteration;
    final meaning = language == AppLanguage.bangla
        ? dua.banglaMeaning
        : dua.englishMeaning;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Directionality(
            key: const ValueKey('dua-arabic-block'),
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                dua.arabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 27,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _TextSection(
            heading: appText(language, 'বাংলা উচ্চারণ', 'Transliteration'),
            body: pronunciation,
          ),
          const SizedBox(height: 16),
          _TextSection(
            heading: appText(language, 'বাংলা অর্থ', 'Meaning'),
            body: meaning,
          ),
          const SizedBox(height: 18),
          Container(
            key: const ValueKey('dua-source-section'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appText(language, 'সূত্র / রেফারেন্স', 'Source / Reference'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (var index = 0; index < dua.sources.length; index++) ...[
                  _SourceRow(
                    source: dua.sources[index],
                    language: language,
                    primaryKey: index == 0
                        ? const ValueKey('dua-source-primary')
                        : null,
                  ),
                  if (index != dua.sources.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.heading, required this.body});

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

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.source,
    required this.language,
    this.primaryKey,
  });

  final DuaSource source;
  final AppLanguage language;
  final Key? primaryKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final grade = duaSourceGrade(source, language);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          duaSourcePrimary(source, language),
          key: primaryKey,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (grade != null) ...[
          const SizedBox(height: 2),
          Text(
            grade,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        if (source.gradingAuthority case final authority?) ...[
          const SizedBox(height: 2),
          Text(
            authority,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
