enum QuranScriptPreference { uthmaniMadani, indoPak }

extension QuranScriptPreferenceLabel on QuranScriptPreference {
  String get label => switch (this) {
    QuranScriptPreference.uthmaniMadani => 'Uthmani / Madani',
    QuranScriptPreference.indoPak => 'IndoPak',
  };

  /// Quran text uses the registered IndoPak face, with system fallbacks.
  String get preferredFontFamily => switch (this) {
    QuranScriptPreference.uthmaniMadani => 'Noto Naskh Arabic',
    QuranScriptPreference.indoPak => 'Indopak Nastaleeq',
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
