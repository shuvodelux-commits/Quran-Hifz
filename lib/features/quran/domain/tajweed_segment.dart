enum TajweedRule {
  hamWasl,
  silent,
  laamShamsiyah,
  maddaNormal,
  maddaPermissible,
  maddaNecessary,
  maddaObligatory,
  qalqalah,
  ikhfa,
  ikhfaShafawi,
  iqlab,
  idghamShafawi,
  idghamWithGhunnah,
  idghamWithoutGhunnah,
  idghamMutajaanisain,
  idghamMutaqaaribain,
  ghunnah,
}

class TajweedSegment {
  const TajweedSegment({required this.text, this.rule});

  final String text;
  final TajweedRule? rule;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TajweedSegment && other.text == text && other.rule == rule;

  @override
  int get hashCode => Object.hash(text, rule);

  @override
  String toString() => 'TajweedSegment(text: $text, rule: $rule)';
}
