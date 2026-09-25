import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/bangladesh_cities.dart';
import 'home_page.dart'
    show
        prayerScheduleRepositoryProvider,
        prayerScheduleProvider,
        savedPrayerLocationProvider;

class PrayerLocationPage extends ConsumerStatefulWidget {
  const PrayerLocationPage({super.key, this.manualOnly = false});

  final bool manualOnly;

  @override
  ConsumerState<PrayerLocationPage> createState() => _PrayerLocationPageState();
}

class _PrayerLocationPageState extends ConsumerState<PrayerLocationPage> {
  String _query = '';
  bool _configuring = false;

  Future<void> _selectLocation(String? cityId) async {
    if (_configuring) return;
    setState(() => _configuring = true);
    try {
      await ref
          .read(prayerScheduleRepositoryProvider)
          .configureLocation(
            bangladeshCityById(cityId),
            school: ref.read(asrSchoolProvider),
          );
      await ref
          .read(appPreferencesControllerProvider.notifier)
          .setPrayerCity(cityId);
      ref.invalidate(savedPrayerLocationProvider);
      ref.invalidate(prayerScheduleProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location setup needs internet once. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _configuring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selected = ref.watch(prayerCityIdProvider);
    final cities = bangladeshCities.where((city) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          city.name.toLowerCase().contains(query) ||
          city.bnName.contains(query);
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
    final bn = language == AppLanguage.bangla;
    return Scaffold(
      appBar: AppBar(
        title: Text(bn ? 'বাংলাদেশের অবস্থান' : 'Location in Bangladesh'),
      ),
      body: Column(
        children: [
          if (_configuring) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: bn ? 'জেলা খুঁজুন' : 'Search district',
              leading: const Icon(Icons.search_rounded),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (!widget.manualOnly) ...[
            ListTile(
              leading: const Icon(Icons.my_location_rounded),
              title: Text(bn ? 'GPS অবস্থান ব্যবহার করুন' : 'Use GPS location'),
              trailing: selected == null
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: _configuring ? null : () => _selectLocation(null),
            ),
            const Divider(height: 1),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  title: Text(bn ? city.bnName : city.name),
                  subtitle: Text(bn ? city.name : city.bnName),
                  trailing: selected == city.id
                      ? const Icon(Icons.check_circle_rounded)
                      : null,
                  onTap: _configuring ? null : () => _selectLocation(city.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
