enum QuranMushafVariant {
  qcfV2(label: 'QCF V2 Madani', mushafId: 1),
  qcfV4Tajweed(label: 'QCF V4 Tajweed', mushafId: 19);

  const QuranMushafVariant({
    required this.label,
    required this.mushafId,
  });

  final String label;
  final int mushafId;

  int get pageCount => 604;
}
