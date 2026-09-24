import 'package:flutter/material.dart';

import '../../../settings/domain/app_preferences.dart';
import '../../domain/dua.dart';

class DuaCategoryFilter extends StatelessWidget {
  const DuaCategoryFilter({
    super.key,
    required this.categories,
    required this.language,
    required this.selectedId,
    required this.onSelected,
  });

  final List<DuaCategory> categories;
  final AppLanguage language;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            FilterChip(
              key: ValueKey('dua-category-${category.id}'),
              label: Text(
                language == AppLanguage.bangla
                    ? category.banglaLabel
                    : category.englishLabel,
              ),
              selected: selectedId == category.id,
              selectedColor: scheme.primaryContainer,
              backgroundColor: scheme.surfaceContainerLow,
              checkmarkColor: scheme.onPrimaryContainer,
              showCheckmark: false,
              side: BorderSide(
                color: selectedId == category.id
                    ? scheme.primary.withValues(alpha: 0.45)
                    : scheme.outlineVariant,
              ),
              onSelected: (_) =>
                  onSelected(selectedId == category.id ? null : category.id),
            ),
            const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}
