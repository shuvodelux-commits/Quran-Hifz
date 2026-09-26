enum QuranScriptPreference { uthmaniMadani, indoPak }

extension QuranScriptPreferenceLabel on QuranScriptPreference {
  String get label => switch (this) {
    QuranScriptPreference.uthmaniMadani => 'Uthmani / Madani',
    QuranScriptPreference.indoPak => 'IndoPak',
  };

  /// Preferred bundled adaptive family for this script.
  String get preferredFontFamily => switch (this) {
    QuranScriptPreference.uthmaniMadani => 'QPC Hafs',
    QuranScriptPreference.indoPak => 'IndoPak Nastaleeq',
  };

  List<String> get fontFamilyFallback => switch (this) {
    QuranScriptPreference.uthmaniMadani => const ['Noto Sans Arabic', 'serif'],
    QuranScriptPreference.indoPak => const [
      'Noto Nastaliq Urdu',
      'Noto Naskh Arabic',
      'Noto Sans Arabic',
      'serif',
    ],
  };
}
