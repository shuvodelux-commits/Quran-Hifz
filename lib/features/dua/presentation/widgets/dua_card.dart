import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/dua.dart';
import '../../domain/dua_entry.dart';
import '../dua_source_label.dart';

class DuaCard extends StatelessWidget {
  DuaCard({
    super.key,
    DuaEntry? entry,
    Dua? dua,
    required this.language,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : assert(
         (entry == null) != (dua == null),
         'Provide exactly one of entry or dua.',
       ),
       entry = entry ?? VerifiedDuaEntry(dua!);

  final DuaEntry entry;
  final AppLanguage language;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (title, arabic, meaning) = switch (entry) {
      VerifiedDuaEntry(:final dua) => (
        language == AppLanguage.bangla ? dua.titleBangla : dua.titleEnglish,
        dua.arabic,
        language == AppLanguage.bangla ? dua.banglaMeaning : dua.englishMeaning,
      ),
      CustomDuaEntry(:final dua) => (dua.title, dua.arabic, dua.meaning),
    };

    return Card(
      key: ValueKey('dua-card-${entry.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('dua-favorite-${entry.id}'),
                    tooltip: appText(
                      language,
                      isFavorite ? 'ফেভারিট থেকে সরান' : 'ফেভারিটে রাখুন',
                      isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  if (entry is CustomDuaEntry &&
                      (onEdit != null || onDelete != null))
                    PopupMenuButton<_CustomDuaAction>(
                      tooltip: appText(language, 'আরও অপশন', 'More options'),
                      onSelected: (action) {
                        switch (action) {
                          case _CustomDuaAction.edit:
                            onEdit?.call();
                          case _CustomDuaAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: _CustomDuaAction.edit,
                            child: Text(appText(language, 'সম্পাদনা', 'Edit')),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: _CustomDuaAction.delete,
                            child: Text(appText(language, 'মুছুন', 'Delete')),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  arabic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontFamily: 'Noto Naskh Arabic',
                    fontSize: 20,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 7),
              switch (entry) {
                VerifiedDuaEntry(:final dua) => _VerifiedSourceRow(
                  dua: dua,
                  language: language,
                ),
                CustomDuaEntry(:final dua) => _CustomSourceRow(
                  reference: dua.reference,
                  language: language,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedSourceRow extends StatelessWidget {
  const _VerifiedSourceRow({required this.dua, required this.language});

  final Dua dua;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final source = dua.sources.first;
    return Row(
      children: [
        Icon(
          source.type == DuaSourceType.quran
              ? Icons.menu_book_outlined
              : Icons.verified_outlined,
          size: 14,
          color: scheme.primary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            duaSourcePrimary(source, language),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _CustomSourceRow extends StatelessWidget {
  const _CustomSourceRow({required this.reference, required this.language});

  final String reference;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.person_outline_rounded, size: 14, color: scheme.primary),
        const SizedBox(width: 5),
        Text(
          appText(language, 'ব্যক্তিগত দোয়া', 'Custom'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            reference,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

enum _CustomDuaAction { edit, delete }
