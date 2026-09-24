bool shouldShowStandaloneBismillah(int surahNumber) {
  if (surahNumber < 1 || surahNumber > 114) {
    throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
  }

  // Al-Fatihah already contains Bismillah as ayah 1. At-Tawbah is the
  // canonical exception and begins without a standalone Bismillah.
  return surahNumber != 1 && surahNumber != 9;
}
