import '../domain/tajweed_segment.dart';

final RegExp _tagPattern = RegExp(
  r"""<(tajweed|rule|span)\s+class=(?:"([^"]+)"|'([^']+)'|([^\s>]+))>(.*?)</\1>""",
  dotAll: true,
  caseSensitive: false,
);

List<TajweedSegment> parseTajweedMarkup(String markup) {
  if (markup.isEmpty) return const [];

  final segments = <TajweedSegment>[];
  var cursor = 0;

  for (final match in _tagPattern.allMatches(markup)) {
    if (match.start > cursor) {
      _appendPlain(segments, markup.substring(cursor, match.start));
    }

    final tag = match.group(1)?.toLowerCase();
    final className = (match.group(2) ?? match.group(3) ?? match.group(4) ?? '')
        .trim()
        .toLowerCase();
    final innerText = _stripAnyTags(match.group(5) ?? '');

    if (tag == 'span' && className == 'end') {
      cursor = match.end;
      continue;
    }

    final rule = tag == 'tajweed' || tag == 'rule'
        ? _ruleForClass(className)
        : null;
    _append(segments, innerText, rule);
    cursor = match.end;
  }

  if (cursor < markup.length) {
    _appendPlain(segments, markup.substring(cursor));
  }

  return List.unmodifiable(segments);
}

void _appendPlain(List<TajweedSegment> segments, String text) {
  _append(segments, _stripAnyTags(text), null);
}

void _append(List<TajweedSegment> segments, String text, TajweedRule? rule) {
  final decoded = _decodeEntities(text);
  if (decoded.isEmpty) return;

  if (segments.isNotEmpty && segments.last.rule == rule) {
    final previous = segments.removeLast();
    segments.add(TajweedSegment(text: previous.text + decoded, rule: rule));
    return;
  }
  segments.add(TajweedSegment(text: decoded, rule: rule));
}

String _stripAnyTags(String value) => value.replaceAll(RegExp(r'<[^>]+>'), '');

String _decodeEntities(String value) => value
    .replaceAll('&nbsp;', '\u00A0')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');

TajweedRule? _ruleForClass(String className) => switch (className) {
  'ham_wasl' || 'hamzat_wasl' => TajweedRule.hamWasl,
  'slnt' || 'silent' => TajweedRule.silent,
  'laam_shamsiyah' || 'lam_shamsiyyah' => TajweedRule.laamShamsiyah,
  'madda_normal' || 'madd_2' => TajweedRule.maddaNormal,
  'madda_permissible' || 'madd_246' => TajweedRule.maddaPermissible,
  'madda_necessary' || 'madd_6' => TajweedRule.maddaNecessary,
  'madda_obligatory' ||
  'madda_pbligatory' ||
  'madda_obligatory_mottasel' ||
  'madda_obligatory_monfasel' ||
  'madd_muttasil' ||
  'madd_munfasil' => TajweedRule.maddaObligatory,
  'qlq' || 'qalaqah' || 'qalqalah' => TajweedRule.qalqalah,
  'ikhf' || 'ikhfa' => TajweedRule.ikhfa,
  'ikhf_shfw' || 'ikhfa_shafawi' => TajweedRule.ikhfaShafawi,
  'iqlb' || 'iqlab' => TajweedRule.iqlab,
  'idghm_shfw' ||
  'idghaam_shafawi' ||
  'idgham_shafawi' => TajweedRule.idghamShafawi,
  'idgh_ghn' ||
  'idgham_ghunnah' ||
  'idghaam_ghunnah' ||
  'idgham_with_ghunnah' => TajweedRule.idghamWithGhunnah,
  'idgh_w_ghn' ||
  'idgham_wo_ghunnah' ||
  'idghaam_no_ghunnah' ||
  'idgham_without_ghunnah' => TajweedRule.idghamWithoutGhunnah,
  'idghm_mus' ||
  'idghaam_mutajaanisain' ||
  'idgham_mutajaanisain' => TajweedRule.idghamMutajaanisain,
  'idghaam_mutaqaaribain' ||
  'idgham_mutaqaaribain' => TajweedRule.idghamMutaqaaribain,
  'ghn' || 'ghunnah' => TajweedRule.ghunnah,
  _ => null,
};
