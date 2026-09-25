String combinedTafsirText({
  required String translation,
  required String footnotes,
}) {
  final plainTranslation = plainTafsirText(translation);
  final plainFootnotes = plainTafsirText(footnotes);
  if (plainTranslation.isEmpty) return plainFootnotes;
  if (plainFootnotes.isEmpty) return plainTranslation;
  return '$plainTranslation\n\n$plainFootnotes';
}

String plainTafsirText(String source) {
  final text = source
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</(?:p|div|li|h[1-6])\s*>', caseSensitive: false),
        '\n',
      )
      .replaceAll(RegExp(r'</?[a-z][^>]*>', caseSensitive: false), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");

  return text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}
