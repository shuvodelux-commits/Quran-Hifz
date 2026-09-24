import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale_text.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../domain/dua.dart';
import '../dua_source_label.dart';

class DuaCard extends StatelessWidget {
  const DuaCard({
    super.key,
    required this.dua,
    required this.language,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Dua dua;
  final AppLanguage language;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = language == AppLanguage.bangla
        ? dua.titleBangla
        : dua.titleEnglish;
    final meaning = language == AppLanguage.bangla
        ? dua.banglaMeaning
        : dua.englishMeaning;
    final source = dua.sources.first;

    return Card(
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
                    key: ValueKey('dua-favorite-${dua.id}'),
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
                ],
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  dua.arabic,
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
              Row(
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
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
