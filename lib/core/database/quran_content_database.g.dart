// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_content_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, Surah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnglishMeta = const VerificationMeta(
    'nameEnglish',
  );
  @override
  late final GeneratedColumn<String> nameEnglish = GeneratedColumn<String>(
    'name_english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameBanglaMeta = const VerificationMeta(
    'nameBangla',
  );
  @override
  late final GeneratedColumn<String> nameBangla = GeneratedColumn<String>(
    'name_bangla',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revelationPlaceMeta = const VerificationMeta(
    'revelationPlace',
  );
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
    'revelation_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ayahCountMeta = const VerificationMeta(
    'ayahCount',
  );
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
    'ayah_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageStartMeta = const VerificationMeta(
    'pageStart',
  );
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
    'page_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageEndMeta = const VerificationMeta(
    'pageEnd',
  );
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
    'page_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzStartMeta = const VerificationMeta(
    'juzStart',
  );
  @override
  late final GeneratedColumn<int> juzStart = GeneratedColumn<int>(
    'juz_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    nameArabic,
    nameEnglish,
    nameBangla,
    revelationPlace,
    ayahCount,
    pageStart,
    pageEnd,
    juzStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Surah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_english')) {
      context.handle(
        _nameEnglishMeta,
        nameEnglish.isAcceptableOrUnknown(
          data['name_english']!,
          _nameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEnglishMeta);
    }
    if (data.containsKey('name_bangla')) {
      context.handle(
        _nameBanglaMeta,
        nameBangla.isAcceptableOrUnknown(data['name_bangla']!, _nameBanglaMeta),
      );
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
        _revelationPlaceMeta,
        revelationPlace.isAcceptableOrUnknown(
          data['revelation_place']!,
          _revelationPlaceMeta,
        ),
      );
    }
    if (data.containsKey('ayah_count')) {
      context.handle(
        _ayahCountMeta,
        ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('page_start')) {
      context.handle(
        _pageStartMeta,
        pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta),
      );
    } else if (isInserting) {
      context.missing(_pageStartMeta);
    }
    if (data.containsKey('page_end')) {
      context.handle(
        _pageEndMeta,
        pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta),
      );
    } else if (isInserting) {
      context.missing(_pageEndMeta);
    }
    if (data.containsKey('juz_start')) {
      context.handle(
        _juzStartMeta,
        juzStart.isAcceptableOrUnknown(data['juz_start']!, _juzStartMeta),
      );
    } else if (isInserting) {
      context.missing(_juzStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  Surah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Surah(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_english'],
      )!,
      nameBangla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_bangla'],
      ),
      revelationPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place'],
      ),
      ayahCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_count'],
      )!,
      pageStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_start'],
      )!,
      pageEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_end'],
      )!,
      juzStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz_start'],
      )!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class Surah extends DataClass implements Insertable<Surah> {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String? nameBangla;
  final String? revelationPlace;
  final int ayahCount;
  final int pageStart;
  final int pageEnd;
  final int juzStart;
  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    this.nameBangla,
    this.revelationPlace,
    required this.ayahCount,
    required this.pageStart,
    required this.pageEnd,
    required this.juzStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_english'] = Variable<String>(nameEnglish);
    if (!nullToAbsent || nameBangla != null) {
      map['name_bangla'] = Variable<String>(nameBangla);
    }
    if (!nullToAbsent || revelationPlace != null) {
      map['revelation_place'] = Variable<String>(revelationPlace);
    }
    map['ayah_count'] = Variable<int>(ayahCount);
    map['page_start'] = Variable<int>(pageStart);
    map['page_end'] = Variable<int>(pageEnd);
    map['juz_start'] = Variable<int>(juzStart);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      number: Value(number),
      nameArabic: Value(nameArabic),
      nameEnglish: Value(nameEnglish),
      nameBangla: nameBangla == null && nullToAbsent
          ? const Value.absent()
          : Value(nameBangla),
      revelationPlace: revelationPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationPlace),
      ayahCount: Value(ayahCount),
      pageStart: Value(pageStart),
      pageEnd: Value(pageEnd),
      juzStart: Value(juzStart),
    );
  }

  factory Surah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Surah(
      number: serializer.fromJson<int>(json['number']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameEnglish: serializer.fromJson<String>(json['nameEnglish']),
      nameBangla: serializer.fromJson<String?>(json['nameBangla']),
      revelationPlace: serializer.fromJson<String?>(json['revelationPlace']),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
      pageStart: serializer.fromJson<int>(json['pageStart']),
      pageEnd: serializer.fromJson<int>(json['pageEnd']),
      juzStart: serializer.fromJson<int>(json['juzStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameEnglish': serializer.toJson<String>(nameEnglish),
      'nameBangla': serializer.toJson<String?>(nameBangla),
      'revelationPlace': serializer.toJson<String?>(revelationPlace),
      'ayahCount': serializer.toJson<int>(ayahCount),
      'pageStart': serializer.toJson<int>(pageStart),
      'pageEnd': serializer.toJson<int>(pageEnd),
      'juzStart': serializer.toJson<int>(juzStart),
    };
  }

  Surah copyWith({
    int? number,
    String? nameArabic,
    String? nameEnglish,
    Value<String?> nameBangla = const Value.absent(),
    Value<String?> revelationPlace = const Value.absent(),
    int? ayahCount,
    int? pageStart,
    int? pageEnd,
    int? juzStart,
  }) => Surah(
    number: number ?? this.number,
    nameArabic: nameArabic ?? this.nameArabic,
    nameEnglish: nameEnglish ?? this.nameEnglish,
    nameBangla: nameBangla.present ? nameBangla.value : this.nameBangla,
    revelationPlace: revelationPlace.present
        ? revelationPlace.value
        : this.revelationPlace,
    ayahCount: ayahCount ?? this.ayahCount,
    pageStart: pageStart ?? this.pageStart,
    pageEnd: pageEnd ?? this.pageEnd,
    juzStart: juzStart ?? this.juzStart,
  );
  Surah copyWithCompanion(SurahsCompanion data) {
    return Surah(
      number: data.number.present ? data.number.value : this.number,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameEnglish: data.nameEnglish.present
          ? data.nameEnglish.value
          : this.nameEnglish,
      nameBangla: data.nameBangla.present
          ? data.nameBangla.value
          : this.nameBangla,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
      juzStart: data.juzStart.present ? data.juzStart.value : this.juzStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Surah(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameBangla: $nameBangla, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('juzStart: $juzStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    nameArabic,
    nameEnglish,
    nameBangla,
    revelationPlace,
    ayahCount,
    pageStart,
    pageEnd,
    juzStart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Surah &&
          other.number == this.number &&
          other.nameArabic == this.nameArabic &&
          other.nameEnglish == this.nameEnglish &&
          other.nameBangla == this.nameBangla &&
          other.revelationPlace == this.revelationPlace &&
          other.ayahCount == this.ayahCount &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd &&
          other.juzStart == this.juzStart);
}

class SurahsCompanion extends UpdateCompanion<Surah> {
  final Value<int> number;
  final Value<String> nameArabic;
  final Value<String> nameEnglish;
  final Value<String?> nameBangla;
  final Value<String?> revelationPlace;
  final Value<int> ayahCount;
  final Value<int> pageStart;
  final Value<int> pageEnd;
  final Value<int> juzStart;
  const SurahsCompanion({
    this.number = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameEnglish = const Value.absent(),
    this.nameBangla = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
    this.juzStart = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.number = const Value.absent(),
    required String nameArabic,
    required String nameEnglish,
    this.nameBangla = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    required int ayahCount,
    required int pageStart,
    required int pageEnd,
    required int juzStart,
  }) : nameArabic = Value(nameArabic),
       nameEnglish = Value(nameEnglish),
       ayahCount = Value(ayahCount),
       pageStart = Value(pageStart),
       pageEnd = Value(pageEnd),
       juzStart = Value(juzStart);
  static Insertable<Surah> custom({
    Expression<int>? number,
    Expression<String>? nameArabic,
    Expression<String>? nameEnglish,
    Expression<String>? nameBangla,
    Expression<String>? revelationPlace,
    Expression<int>? ayahCount,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
    Expression<int>? juzStart,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameEnglish != null) 'name_english': nameEnglish,
      if (nameBangla != null) 'name_bangla': nameBangla,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
      if (juzStart != null) 'juz_start': juzStart,
    });
  }

  SurahsCompanion copyWith({
    Value<int>? number,
    Value<String>? nameArabic,
    Value<String>? nameEnglish,
    Value<String?>? nameBangla,
    Value<String?>? revelationPlace,
    Value<int>? ayahCount,
    Value<int>? pageStart,
    Value<int>? pageEnd,
    Value<int>? juzStart,
  }) {
    return SurahsCompanion(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameBangla: nameBangla ?? this.nameBangla,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      ayahCount: ayahCount ?? this.ayahCount,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      juzStart: juzStart ?? this.juzStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameEnglish.present) {
      map['name_english'] = Variable<String>(nameEnglish.value);
    }
    if (nameBangla.present) {
      map['name_bangla'] = Variable<String>(nameBangla.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    if (juzStart.present) {
      map['juz_start'] = Variable<int>(juzStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameBangla: $nameBangla, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('juzStart: $juzStart')
          ..write(')'))
        .toString();
  }
}

class $AyahsTable extends Ayahs with TableInfo<$AyahsTable, Ayah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseKeyMeta = const VerificationMeta(
    'verseKey',
  );
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
    'verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _arabicTextMeta = const VerificationMeta(
    'arabicText',
  );
  @override
  late final GeneratedColumn<String> arabicText = GeneratedColumn<String>(
    'arabic_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTextIndopakMeta = const VerificationMeta(
    'arabicTextIndopak',
  );
  @override
  late final GeneratedColumn<String> arabicTextIndopak =
      GeneratedColumn<String>(
        'arabic_text_indopak',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _arabicTextTajweedMeta = const VerificationMeta(
    'arabicTextTajweed',
  );
  @override
  late final GeneratedColumn<String> arabicTextTajweed =
      GeneratedColumn<String>(
        'arabic_text_tajweed',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzNumberMeta = const VerificationMeta(
    'juzNumber',
  );
  @override
  late final GeneratedColumn<int> juzNumber = GeneratedColumn<int>(
    'juz_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hizbNumberMeta = const VerificationMeta(
    'hizbNumber',
  );
  @override
  late final GeneratedColumn<int> hizbNumber = GeneratedColumn<int>(
    'hizb_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rubNumberMeta = const VerificationMeta(
    'rubNumber',
  );
  @override
  late final GeneratedColumn<int> rubNumber = GeneratedColumn<int>(
    'rub_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    surahNumber,
    ayahNumber,
    verseKey,
    arabicText,
    arabicTextIndopak,
    arabicTextTajweed,
    pageNumber,
    juzNumber,
    hizbNumber,
    rubNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ayah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('arabic_text')) {
      context.handle(
        _arabicTextMeta,
        arabicText.isAcceptableOrUnknown(data['arabic_text']!, _arabicTextMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicTextMeta);
    }
    if (data.containsKey('arabic_text_indopak')) {
      context.handle(
        _arabicTextIndopakMeta,
        arabicTextIndopak.isAcceptableOrUnknown(
          data['arabic_text_indopak']!,
          _arabicTextIndopakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arabicTextIndopakMeta);
    }
    if (data.containsKey('arabic_text_tajweed')) {
      context.handle(
        _arabicTextTajweedMeta,
        arabicTextTajweed.isAcceptableOrUnknown(
          data['arabic_text_tajweed']!,
          _arabicTextTajweedMeta,
        ),
      );
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('juz_number')) {
      context.handle(
        _juzNumberMeta,
        juzNumber.isAcceptableOrUnknown(data['juz_number']!, _juzNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_juzNumberMeta);
    }
    if (data.containsKey('hizb_number')) {
      context.handle(
        _hizbNumberMeta,
        hizbNumber.isAcceptableOrUnknown(data['hizb_number']!, _hizbNumberMeta),
      );
    }
    if (data.containsKey('rub_number')) {
      context.handle(
        _rubNumberMeta,
        rubNumber.isAcceptableOrUnknown(data['rub_number']!, _rubNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahNumber, ayahNumber};
  @override
  Ayah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ayah(
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      arabicText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text'],
      )!,
      arabicTextIndopak: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text_indopak'],
      )!,
      arabicTextTajweed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text_tajweed'],
      ),
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      juzNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz_number'],
      )!,
      hizbNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb_number'],
      ),
      rubNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rub_number'],
      ),
    );
  }

  @override
  $AyahsTable createAlias(String alias) {
    return $AyahsTable(attachedDatabase, alias);
  }
}

class Ayah extends DataClass implements Insertable<Ayah> {
  final int surahNumber;
  final int ayahNumber;
  final String verseKey;
  final String arabicText;
  final String arabicTextIndopak;
  final String? arabicTextTajweed;
  final int pageNumber;
  final int juzNumber;
  final int? hizbNumber;
  final int? rubNumber;
  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.arabicText,
    required this.arabicTextIndopak,
    this.arabicTextTajweed,
    required this.pageNumber,
    required this.juzNumber,
    this.hizbNumber,
    this.rubNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['verse_key'] = Variable<String>(verseKey);
    map['arabic_text'] = Variable<String>(arabicText);
    map['arabic_text_indopak'] = Variable<String>(arabicTextIndopak);
    if (!nullToAbsent || arabicTextTajweed != null) {
      map['arabic_text_tajweed'] = Variable<String>(arabicTextTajweed);
    }
    map['page_number'] = Variable<int>(pageNumber);
    map['juz_number'] = Variable<int>(juzNumber);
    if (!nullToAbsent || hizbNumber != null) {
      map['hizb_number'] = Variable<int>(hizbNumber);
    }
    if (!nullToAbsent || rubNumber != null) {
      map['rub_number'] = Variable<int>(rubNumber);
    }
    return map;
  }

  AyahsCompanion toCompanion(bool nullToAbsent) {
    return AyahsCompanion(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      verseKey: Value(verseKey),
      arabicText: Value(arabicText),
      arabicTextIndopak: Value(arabicTextIndopak),
      arabicTextTajweed: arabicTextTajweed == null && nullToAbsent
          ? const Value.absent()
          : Value(arabicTextTajweed),
      pageNumber: Value(pageNumber),
      juzNumber: Value(juzNumber),
      hizbNumber: hizbNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(hizbNumber),
      rubNumber: rubNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(rubNumber),
    );
  }

  factory Ayah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ayah(
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      arabicText: serializer.fromJson<String>(json['arabicText']),
      arabicTextIndopak: serializer.fromJson<String>(json['arabicTextIndopak']),
      arabicTextTajweed: serializer.fromJson<String?>(
        json['arabicTextTajweed'],
      ),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      juzNumber: serializer.fromJson<int>(json['juzNumber']),
      hizbNumber: serializer.fromJson<int?>(json['hizbNumber']),
      rubNumber: serializer.fromJson<int?>(json['rubNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'verseKey': serializer.toJson<String>(verseKey),
      'arabicText': serializer.toJson<String>(arabicText),
      'arabicTextIndopak': serializer.toJson<String>(arabicTextIndopak),
      'arabicTextTajweed': serializer.toJson<String?>(arabicTextTajweed),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'juzNumber': serializer.toJson<int>(juzNumber),
      'hizbNumber': serializer.toJson<int?>(hizbNumber),
      'rubNumber': serializer.toJson<int?>(rubNumber),
    };
  }

  Ayah copyWith({
    int? surahNumber,
    int? ayahNumber,
    String? verseKey,
    String? arabicText,
    String? arabicTextIndopak,
    Value<String?> arabicTextTajweed = const Value.absent(),
    int? pageNumber,
    int? juzNumber,
    Value<int?> hizbNumber = const Value.absent(),
    Value<int?> rubNumber = const Value.absent(),
  }) => Ayah(
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    verseKey: verseKey ?? this.verseKey,
    arabicText: arabicText ?? this.arabicText,
    arabicTextIndopak: arabicTextIndopak ?? this.arabicTextIndopak,
    arabicTextTajweed: arabicTextTajweed.present
        ? arabicTextTajweed.value
        : this.arabicTextTajweed,
    pageNumber: pageNumber ?? this.pageNumber,
    juzNumber: juzNumber ?? this.juzNumber,
    hizbNumber: hizbNumber.present ? hizbNumber.value : this.hizbNumber,
    rubNumber: rubNumber.present ? rubNumber.value : this.rubNumber,
  );
  Ayah copyWithCompanion(AyahsCompanion data) {
    return Ayah(
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      arabicText: data.arabicText.present
          ? data.arabicText.value
          : this.arabicText,
      arabicTextIndopak: data.arabicTextIndopak.present
          ? data.arabicTextIndopak.value
          : this.arabicTextIndopak,
      arabicTextTajweed: data.arabicTextTajweed.present
          ? data.arabicTextTajweed.value
          : this.arabicTextTajweed,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      juzNumber: data.juzNumber.present ? data.juzNumber.value : this.juzNumber,
      hizbNumber: data.hizbNumber.present
          ? data.hizbNumber.value
          : this.hizbNumber,
      rubNumber: data.rubNumber.present ? data.rubNumber.value : this.rubNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ayah(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('arabicText: $arabicText, ')
          ..write('arabicTextIndopak: $arabicTextIndopak, ')
          ..write('arabicTextTajweed: $arabicTextTajweed, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('juzNumber: $juzNumber, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('rubNumber: $rubNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    ayahNumber,
    verseKey,
    arabicText,
    arabicTextIndopak,
    arabicTextTajweed,
    pageNumber,
    juzNumber,
    hizbNumber,
    rubNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ayah &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.verseKey == this.verseKey &&
          other.arabicText == this.arabicText &&
          other.arabicTextIndopak == this.arabicTextIndopak &&
          other.arabicTextTajweed == this.arabicTextTajweed &&
          other.pageNumber == this.pageNumber &&
          other.juzNumber == this.juzNumber &&
          other.hizbNumber == this.hizbNumber &&
          other.rubNumber == this.rubNumber);
}

class AyahsCompanion extends UpdateCompanion<Ayah> {
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> verseKey;
  final Value<String> arabicText;
  final Value<String> arabicTextIndopak;
  final Value<String?> arabicTextTajweed;
  final Value<int> pageNumber;
  final Value<int> juzNumber;
  final Value<int?> hizbNumber;
  final Value<int?> rubNumber;
  final Value<int> rowid;
  const AyahsCompanion({
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.arabicText = const Value.absent(),
    this.arabicTextIndopak = const Value.absent(),
    this.arabicTextTajweed = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.juzNumber = const Value.absent(),
    this.hizbNumber = const Value.absent(),
    this.rubNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahsCompanion.insert({
    required int surahNumber,
    required int ayahNumber,
    required String verseKey,
    required String arabicText,
    required String arabicTextIndopak,
    this.arabicTextTajweed = const Value.absent(),
    required int pageNumber,
    required int juzNumber,
    this.hizbNumber = const Value.absent(),
    this.rubNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       verseKey = Value(verseKey),
       arabicText = Value(arabicText),
       arabicTextIndopak = Value(arabicTextIndopak),
       pageNumber = Value(pageNumber),
       juzNumber = Value(juzNumber);
  static Insertable<Ayah> custom({
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? verseKey,
    Expression<String>? arabicText,
    Expression<String>? arabicTextIndopak,
    Expression<String>? arabicTextTajweed,
    Expression<int>? pageNumber,
    Expression<int>? juzNumber,
    Expression<int>? hizbNumber,
    Expression<int>? rubNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (verseKey != null) 'verse_key': verseKey,
      if (arabicText != null) 'arabic_text': arabicText,
      if (arabicTextIndopak != null) 'arabic_text_indopak': arabicTextIndopak,
      if (arabicTextTajweed != null) 'arabic_text_tajweed': arabicTextTajweed,
      if (pageNumber != null) 'page_number': pageNumber,
      if (juzNumber != null) 'juz_number': juzNumber,
      if (hizbNumber != null) 'hizb_number': hizbNumber,
      if (rubNumber != null) 'rub_number': rubNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahsCompanion copyWith({
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<String>? verseKey,
    Value<String>? arabicText,
    Value<String>? arabicTextIndopak,
    Value<String?>? arabicTextTajweed,
    Value<int>? pageNumber,
    Value<int>? juzNumber,
    Value<int?>? hizbNumber,
    Value<int?>? rubNumber,
    Value<int>? rowid,
  }) {
    return AyahsCompanion(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      verseKey: verseKey ?? this.verseKey,
      arabicText: arabicText ?? this.arabicText,
      arabicTextIndopak: arabicTextIndopak ?? this.arabicTextIndopak,
      arabicTextTajweed: arabicTextTajweed ?? this.arabicTextTajweed,
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      rubNumber: rubNumber ?? this.rubNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (arabicText.present) {
      map['arabic_text'] = Variable<String>(arabicText.value);
    }
    if (arabicTextIndopak.present) {
      map['arabic_text_indopak'] = Variable<String>(arabicTextIndopak.value);
    }
    if (arabicTextTajweed.present) {
      map['arabic_text_tajweed'] = Variable<String>(arabicTextTajweed.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (juzNumber.present) {
      map['juz_number'] = Variable<int>(juzNumber.value);
    }
    if (hizbNumber.present) {
      map['hizb_number'] = Variable<int>(hizbNumber.value);
    }
    if (rubNumber.present) {
      map['rub_number'] = Variable<int>(rubNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahsCompanion(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('arabicText: $arabicText, ')
          ..write('arabicTextIndopak: $arabicTextIndopak, ')
          ..write('arabicTextTajweed: $arabicTextTajweed, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('juzNumber: $juzNumber, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('rubNumber: $rubNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranWordsTable extends QuranWords
    with TableInfo<$QuranWordsTable, QuranWordRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicMeta = const VerificationMeta('arabic');
  @override
  late final GeneratedColumn<String> arabic = GeneratedColumn<String>(
    'arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicIndopakMeta = const VerificationMeta(
    'arabicIndopak',
  );
  @override
  late final GeneratedColumn<String> arabicIndopak = GeneratedColumn<String>(
    'arabic_indopak',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTajweedMeta = const VerificationMeta(
    'arabicTajweed',
  );
  @override
  late final GeneratedColumn<String> arabicTajweed = GeneratedColumn<String>(
    'arabic_tajweed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transliterationMeta = const VerificationMeta(
    'transliteration',
  );
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
    'transliteration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _banglaMeaningMeta = const VerificationMeta(
    'banglaMeaning',
  );
  @override
  late final GeneratedColumn<String> banglaMeaning = GeneratedColumn<String>(
    'bangla_meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _englishMeaningMeta = const VerificationMeta(
    'englishMeaning',
  );
  @override
  late final GeneratedColumn<String> englishMeaning = GeneratedColumn<String>(
    'english_meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
    'root',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarMeta = const VerificationMeta(
    'grammar',
  );
  @override
  late final GeneratedColumn<String> grammar = GeneratedColumn<String>(
    'grammar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioRemotePathMeta = const VerificationMeta(
    'audioRemotePath',
  );
  @override
  late final GeneratedColumn<String> audioRemotePath = GeneratedColumn<String>(
    'audio_remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    surahNumber,
    ayahNumber,
    position,
    arabic,
    arabicIndopak,
    arabicTajweed,
    transliteration,
    banglaMeaning,
    englishMeaning,
    root,
    lemma,
    grammar,
    audioRemotePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranWordRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('arabic')) {
      context.handle(
        _arabicMeta,
        arabic.isAcceptableOrUnknown(data['arabic']!, _arabicMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicMeta);
    }
    if (data.containsKey('arabic_indopak')) {
      context.handle(
        _arabicIndopakMeta,
        arabicIndopak.isAcceptableOrUnknown(
          data['arabic_indopak']!,
          _arabicIndopakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arabicIndopakMeta);
    }
    if (data.containsKey('arabic_tajweed')) {
      context.handle(
        _arabicTajweedMeta,
        arabicTajweed.isAcceptableOrUnknown(
          data['arabic_tajweed']!,
          _arabicTajweedMeta,
        ),
      );
    }
    if (data.containsKey('transliteration')) {
      context.handle(
        _transliterationMeta,
        transliteration.isAcceptableOrUnknown(
          data['transliteration']!,
          _transliterationMeta,
        ),
      );
    }
    if (data.containsKey('bangla_meaning')) {
      context.handle(
        _banglaMeaningMeta,
        banglaMeaning.isAcceptableOrUnknown(
          data['bangla_meaning']!,
          _banglaMeaningMeta,
        ),
      );
    }
    if (data.containsKey('english_meaning')) {
      context.handle(
        _englishMeaningMeta,
        englishMeaning.isAcceptableOrUnknown(
          data['english_meaning']!,
          _englishMeaningMeta,
        ),
      );
    }
    if (data.containsKey('root')) {
      context.handle(
        _rootMeta,
        root.isAcceptableOrUnknown(data['root']!, _rootMeta),
      );
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    }
    if (data.containsKey('grammar')) {
      context.handle(
        _grammarMeta,
        grammar.isAcceptableOrUnknown(data['grammar']!, _grammarMeta),
      );
    }
    if (data.containsKey('audio_remote_path')) {
      context.handle(
        _audioRemotePathMeta,
        audioRemotePath.isAcceptableOrUnknown(
          data['audio_remote_path']!,
          _audioRemotePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahNumber, ayahNumber, position};
  @override
  QuranWordRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranWordRecord(
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      arabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic'],
      )!,
      arabicIndopak: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_indopak'],
      )!,
      arabicTajweed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_tajweed'],
      ),
      transliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transliteration'],
      ),
      banglaMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bangla_meaning'],
      ),
      englishMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_meaning'],
      ),
      root: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root'],
      ),
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      ),
      grammar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar'],
      ),
      audioRemotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_remote_path'],
      ),
    );
  }

  @override
  $QuranWordsTable createAlias(String alias) {
    return $QuranWordsTable(attachedDatabase, alias);
  }
}

class QuranWordRecord extends DataClass implements Insertable<QuranWordRecord> {
  final int surahNumber;
  final int ayahNumber;
  final int position;
  final String arabic;
  final String arabicIndopak;
  final String? arabicTajweed;
  final String? transliteration;
  final String? banglaMeaning;
  final String? englishMeaning;
  final String? root;
  final String? lemma;
  final String? grammar;
  final String? audioRemotePath;
  const QuranWordRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.position,
    required this.arabic,
    required this.arabicIndopak,
    this.arabicTajweed,
    this.transliteration,
    this.banglaMeaning,
    this.englishMeaning,
    this.root,
    this.lemma,
    this.grammar,
    this.audioRemotePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['position'] = Variable<int>(position);
    map['arabic'] = Variable<String>(arabic);
    map['arabic_indopak'] = Variable<String>(arabicIndopak);
    if (!nullToAbsent || arabicTajweed != null) {
      map['arabic_tajweed'] = Variable<String>(arabicTajweed);
    }
    if (!nullToAbsent || transliteration != null) {
      map['transliteration'] = Variable<String>(transliteration);
    }
    if (!nullToAbsent || banglaMeaning != null) {
      map['bangla_meaning'] = Variable<String>(banglaMeaning);
    }
    if (!nullToAbsent || englishMeaning != null) {
      map['english_meaning'] = Variable<String>(englishMeaning);
    }
    if (!nullToAbsent || root != null) {
      map['root'] = Variable<String>(root);
    }
    if (!nullToAbsent || lemma != null) {
      map['lemma'] = Variable<String>(lemma);
    }
    if (!nullToAbsent || grammar != null) {
      map['grammar'] = Variable<String>(grammar);
    }
    if (!nullToAbsent || audioRemotePath != null) {
      map['audio_remote_path'] = Variable<String>(audioRemotePath);
    }
    return map;
  }

  QuranWordsCompanion toCompanion(bool nullToAbsent) {
    return QuranWordsCompanion(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      position: Value(position),
      arabic: Value(arabic),
      arabicIndopak: Value(arabicIndopak),
      arabicTajweed: arabicTajweed == null && nullToAbsent
          ? const Value.absent()
          : Value(arabicTajweed),
      transliteration: transliteration == null && nullToAbsent
          ? const Value.absent()
          : Value(transliteration),
      banglaMeaning: banglaMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(banglaMeaning),
      englishMeaning: englishMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(englishMeaning),
      root: root == null && nullToAbsent ? const Value.absent() : Value(root),
      lemma: lemma == null && nullToAbsent
          ? const Value.absent()
          : Value(lemma),
      grammar: grammar == null && nullToAbsent
          ? const Value.absent()
          : Value(grammar),
      audioRemotePath: audioRemotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRemotePath),
    );
  }

  factory QuranWordRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranWordRecord(
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      position: serializer.fromJson<int>(json['position']),
      arabic: serializer.fromJson<String>(json['arabic']),
      arabicIndopak: serializer.fromJson<String>(json['arabicIndopak']),
      arabicTajweed: serializer.fromJson<String?>(json['arabicTajweed']),
      transliteration: serializer.fromJson<String?>(json['transliteration']),
      banglaMeaning: serializer.fromJson<String?>(json['banglaMeaning']),
      englishMeaning: serializer.fromJson<String?>(json['englishMeaning']),
      root: serializer.fromJson<String?>(json['root']),
      lemma: serializer.fromJson<String?>(json['lemma']),
      grammar: serializer.fromJson<String?>(json['grammar']),
      audioRemotePath: serializer.fromJson<String?>(json['audioRemotePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'position': serializer.toJson<int>(position),
      'arabic': serializer.toJson<String>(arabic),
      'arabicIndopak': serializer.toJson<String>(arabicIndopak),
      'arabicTajweed': serializer.toJson<String?>(arabicTajweed),
      'transliteration': serializer.toJson<String?>(transliteration),
      'banglaMeaning': serializer.toJson<String?>(banglaMeaning),
      'englishMeaning': serializer.toJson<String?>(englishMeaning),
      'root': serializer.toJson<String?>(root),
      'lemma': serializer.toJson<String?>(lemma),
      'grammar': serializer.toJson<String?>(grammar),
      'audioRemotePath': serializer.toJson<String?>(audioRemotePath),
    };
  }

  QuranWordRecord copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? position,
    String? arabic,
    String? arabicIndopak,
    Value<String?> arabicTajweed = const Value.absent(),
    Value<String?> transliteration = const Value.absent(),
    Value<String?> banglaMeaning = const Value.absent(),
    Value<String?> englishMeaning = const Value.absent(),
    Value<String?> root = const Value.absent(),
    Value<String?> lemma = const Value.absent(),
    Value<String?> grammar = const Value.absent(),
    Value<String?> audioRemotePath = const Value.absent(),
  }) => QuranWordRecord(
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    position: position ?? this.position,
    arabic: arabic ?? this.arabic,
    arabicIndopak: arabicIndopak ?? this.arabicIndopak,
    arabicTajweed: arabicTajweed.present
        ? arabicTajweed.value
        : this.arabicTajweed,
    transliteration: transliteration.present
        ? transliteration.value
        : this.transliteration,
    banglaMeaning: banglaMeaning.present
        ? banglaMeaning.value
        : this.banglaMeaning,
    englishMeaning: englishMeaning.present
        ? englishMeaning.value
        : this.englishMeaning,
    root: root.present ? root.value : this.root,
    lemma: lemma.present ? lemma.value : this.lemma,
    grammar: grammar.present ? grammar.value : this.grammar,
    audioRemotePath: audioRemotePath.present
        ? audioRemotePath.value
        : this.audioRemotePath,
  );
  QuranWordRecord copyWithCompanion(QuranWordsCompanion data) {
    return QuranWordRecord(
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      position: data.position.present ? data.position.value : this.position,
      arabic: data.arabic.present ? data.arabic.value : this.arabic,
      arabicIndopak: data.arabicIndopak.present
          ? data.arabicIndopak.value
          : this.arabicIndopak,
      arabicTajweed: data.arabicTajweed.present
          ? data.arabicTajweed.value
          : this.arabicTajweed,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      banglaMeaning: data.banglaMeaning.present
          ? data.banglaMeaning.value
          : this.banglaMeaning,
      englishMeaning: data.englishMeaning.present
          ? data.englishMeaning.value
          : this.englishMeaning,
      root: data.root.present ? data.root.value : this.root,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      grammar: data.grammar.present ? data.grammar.value : this.grammar,
      audioRemotePath: data.audioRemotePath.present
          ? data.audioRemotePath.value
          : this.audioRemotePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranWordRecord(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('position: $position, ')
          ..write('arabic: $arabic, ')
          ..write('arabicIndopak: $arabicIndopak, ')
          ..write('arabicTajweed: $arabicTajweed, ')
          ..write('transliteration: $transliteration, ')
          ..write('banglaMeaning: $banglaMeaning, ')
          ..write('englishMeaning: $englishMeaning, ')
          ..write('root: $root, ')
          ..write('lemma: $lemma, ')
          ..write('grammar: $grammar, ')
          ..write('audioRemotePath: $audioRemotePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    ayahNumber,
    position,
    arabic,
    arabicIndopak,
    arabicTajweed,
    transliteration,
    banglaMeaning,
    englishMeaning,
    root,
    lemma,
    grammar,
    audioRemotePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranWordRecord &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.position == this.position &&
          other.arabic == this.arabic &&
          other.arabicIndopak == this.arabicIndopak &&
          other.arabicTajweed == this.arabicTajweed &&
          other.transliteration == this.transliteration &&
          other.banglaMeaning == this.banglaMeaning &&
          other.englishMeaning == this.englishMeaning &&
          other.root == this.root &&
          other.lemma == this.lemma &&
          other.grammar == this.grammar &&
          other.audioRemotePath == this.audioRemotePath);
}

class QuranWordsCompanion extends UpdateCompanion<QuranWordRecord> {
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<int> position;
  final Value<String> arabic;
  final Value<String> arabicIndopak;
  final Value<String?> arabicTajweed;
  final Value<String?> transliteration;
  final Value<String?> banglaMeaning;
  final Value<String?> englishMeaning;
  final Value<String?> root;
  final Value<String?> lemma;
  final Value<String?> grammar;
  final Value<String?> audioRemotePath;
  final Value<int> rowid;
  const QuranWordsCompanion({
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.position = const Value.absent(),
    this.arabic = const Value.absent(),
    this.arabicIndopak = const Value.absent(),
    this.arabicTajweed = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.banglaMeaning = const Value.absent(),
    this.englishMeaning = const Value.absent(),
    this.root = const Value.absent(),
    this.lemma = const Value.absent(),
    this.grammar = const Value.absent(),
    this.audioRemotePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranWordsCompanion.insert({
    required int surahNumber,
    required int ayahNumber,
    required int position,
    required String arabic,
    required String arabicIndopak,
    this.arabicTajweed = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.banglaMeaning = const Value.absent(),
    this.englishMeaning = const Value.absent(),
    this.root = const Value.absent(),
    this.lemma = const Value.absent(),
    this.grammar = const Value.absent(),
    this.audioRemotePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       position = Value(position),
       arabic = Value(arabic),
       arabicIndopak = Value(arabicIndopak);
  static Insertable<QuranWordRecord> custom({
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? position,
    Expression<String>? arabic,
    Expression<String>? arabicIndopak,
    Expression<String>? arabicTajweed,
    Expression<String>? transliteration,
    Expression<String>? banglaMeaning,
    Expression<String>? englishMeaning,
    Expression<String>? root,
    Expression<String>? lemma,
    Expression<String>? grammar,
    Expression<String>? audioRemotePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (position != null) 'position': position,
      if (arabic != null) 'arabic': arabic,
      if (arabicIndopak != null) 'arabic_indopak': arabicIndopak,
      if (arabicTajweed != null) 'arabic_tajweed': arabicTajweed,
      if (transliteration != null) 'transliteration': transliteration,
      if (banglaMeaning != null) 'bangla_meaning': banglaMeaning,
      if (englishMeaning != null) 'english_meaning': englishMeaning,
      if (root != null) 'root': root,
      if (lemma != null) 'lemma': lemma,
      if (grammar != null) 'grammar': grammar,
      if (audioRemotePath != null) 'audio_remote_path': audioRemotePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranWordsCompanion copyWith({
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<int>? position,
    Value<String>? arabic,
    Value<String>? arabicIndopak,
    Value<String?>? arabicTajweed,
    Value<String?>? transliteration,
    Value<String?>? banglaMeaning,
    Value<String?>? englishMeaning,
    Value<String?>? root,
    Value<String?>? lemma,
    Value<String?>? grammar,
    Value<String?>? audioRemotePath,
    Value<int>? rowid,
  }) {
    return QuranWordsCompanion(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      position: position ?? this.position,
      arabic: arabic ?? this.arabic,
      arabicIndopak: arabicIndopak ?? this.arabicIndopak,
      arabicTajweed: arabicTajweed ?? this.arabicTajweed,
      transliteration: transliteration ?? this.transliteration,
      banglaMeaning: banglaMeaning ?? this.banglaMeaning,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      root: root ?? this.root,
      lemma: lemma ?? this.lemma,
      grammar: grammar ?? this.grammar,
      audioRemotePath: audioRemotePath ?? this.audioRemotePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (arabic.present) {
      map['arabic'] = Variable<String>(arabic.value);
    }
    if (arabicIndopak.present) {
      map['arabic_indopak'] = Variable<String>(arabicIndopak.value);
    }
    if (arabicTajweed.present) {
      map['arabic_tajweed'] = Variable<String>(arabicTajweed.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (banglaMeaning.present) {
      map['bangla_meaning'] = Variable<String>(banglaMeaning.value);
    }
    if (englishMeaning.present) {
      map['english_meaning'] = Variable<String>(englishMeaning.value);
    }
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (grammar.present) {
      map['grammar'] = Variable<String>(grammar.value);
    }
    if (audioRemotePath.present) {
      map['audio_remote_path'] = Variable<String>(audioRemotePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranWordsCompanion(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('position: $position, ')
          ..write('arabic: $arabic, ')
          ..write('arabicIndopak: $arabicIndopak, ')
          ..write('arabicTajweed: $arabicTajweed, ')
          ..write('transliteration: $transliteration, ')
          ..write('banglaMeaning: $banglaMeaning, ')
          ..write('englishMeaning: $englishMeaning, ')
          ..write('root: $root, ')
          ..write('lemma: $lemma, ')
          ..write('grammar: $grammar, ')
          ..write('audioRemotePath: $audioRemotePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranslationsTable extends Translations
    with TableInfo<$TranslationsTable, TranslationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resourceId,
    surahNumber,
    ayahNumber,
    language,
    textValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceId, surahNumber, ayahNumber};
  @override
  TranslationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationRecord(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
    );
  }

  @override
  $TranslationsTable createAlias(String alias) {
    return $TranslationsTable(attachedDatabase, alias);
  }
}

class TranslationRecord extends DataClass
    implements Insertable<TranslationRecord> {
  final int resourceId;
  final int surahNumber;
  final int ayahNumber;
  final String language;
  final String textValue;
  const TranslationRecord({
    required this.resourceId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.language,
    required this.textValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<int>(resourceId);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['language'] = Variable<String>(language);
    map['text'] = Variable<String>(textValue);
    return map;
  }

  TranslationsCompanion toCompanion(bool nullToAbsent) {
    return TranslationsCompanion(
      resourceId: Value(resourceId),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      language: Value(language),
      textValue: Value(textValue),
    );
  }

  factory TranslationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationRecord(
      resourceId: serializer.fromJson<int>(json['resourceId']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      language: serializer.fromJson<String>(json['language']),
      textValue: serializer.fromJson<String>(json['textValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<int>(resourceId),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'language': serializer.toJson<String>(language),
      'textValue': serializer.toJson<String>(textValue),
    };
  }

  TranslationRecord copyWith({
    int? resourceId,
    int? surahNumber,
    int? ayahNumber,
    String? language,
    String? textValue,
  }) => TranslationRecord(
    resourceId: resourceId ?? this.resourceId,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    language: language ?? this.language,
    textValue: textValue ?? this.textValue,
  );
  TranslationRecord copyWithCompanion(TranslationsCompanion data) {
    return TranslationRecord(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      language: data.language.present ? data.language.value : this.language,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationRecord(')
          ..write('resourceId: $resourceId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('language: $language, ')
          ..write('textValue: $textValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(resourceId, surahNumber, ayahNumber, language, textValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationRecord &&
          other.resourceId == this.resourceId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.language == this.language &&
          other.textValue == this.textValue);
}

class TranslationsCompanion extends UpdateCompanion<TranslationRecord> {
  final Value<int> resourceId;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> language;
  final Value<String> textValue;
  final Value<int> rowid;
  const TranslationsCompanion({
    this.resourceId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.language = const Value.absent(),
    this.textValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationsCompanion.insert({
    required int resourceId,
    required int surahNumber,
    required int ayahNumber,
    required String language,
    required String textValue,
    this.rowid = const Value.absent(),
  }) : resourceId = Value(resourceId),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       language = Value(language),
       textValue = Value(textValue);
  static Insertable<TranslationRecord> custom({
    Expression<int>? resourceId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? language,
    Expression<String>? textValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (language != null) 'language': language,
      if (textValue != null) 'text': textValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationsCompanion copyWith({
    Value<int>? resourceId,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<String>? language,
    Value<String>? textValue,
    Value<int>? rowid,
  }) {
    return TranslationsCompanion(
      resourceId: resourceId ?? this.resourceId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      language: language ?? this.language,
      textValue: textValue ?? this.textValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (textValue.present) {
      map['text'] = Variable<String>(textValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationsCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('language: $language, ')
          ..write('textValue: $textValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranMetadataTable extends QuranMetadata
    with TableInfo<$QuranMetadataTable, QuranMetadataRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metadataKeyMeta = const VerificationMeta(
    'metadataKey',
  );
  @override
  late final GeneratedColumn<String> metadataKey = GeneratedColumn<String>(
    'metadata_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataValueMeta = const VerificationMeta(
    'metadataValue',
  );
  @override
  late final GeneratedColumn<String> metadataValue = GeneratedColumn<String>(
    'metadata_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metadataKey, metadataValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranMetadataRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metadata_key')) {
      context.handle(
        _metadataKeyMeta,
        metadataKey.isAcceptableOrUnknown(
          data['metadata_key']!,
          _metadataKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataKeyMeta);
    }
    if (data.containsKey('metadata_value')) {
      context.handle(
        _metadataValueMeta,
        metadataValue.isAcceptableOrUnknown(
          data['metadata_value']!,
          _metadataValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metadataKey};
  @override
  QuranMetadataRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranMetadataRecord(
      metadataKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_key'],
      )!,
      metadataValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_value'],
      )!,
    );
  }

  @override
  $QuranMetadataTable createAlias(String alias) {
    return $QuranMetadataTable(attachedDatabase, alias);
  }
}

class QuranMetadataRecord extends DataClass
    implements Insertable<QuranMetadataRecord> {
  final String metadataKey;
  final String metadataValue;
  const QuranMetadataRecord({
    required this.metadataKey,
    required this.metadataValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metadata_key'] = Variable<String>(metadataKey);
    map['metadata_value'] = Variable<String>(metadataValue);
    return map;
  }

  QuranMetadataCompanion toCompanion(bool nullToAbsent) {
    return QuranMetadataCompanion(
      metadataKey: Value(metadataKey),
      metadataValue: Value(metadataValue),
    );
  }

  factory QuranMetadataRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranMetadataRecord(
      metadataKey: serializer.fromJson<String>(json['metadataKey']),
      metadataValue: serializer.fromJson<String>(json['metadataValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metadataKey': serializer.toJson<String>(metadataKey),
      'metadataValue': serializer.toJson<String>(metadataValue),
    };
  }

  QuranMetadataRecord copyWith({String? metadataKey, String? metadataValue}) =>
      QuranMetadataRecord(
        metadataKey: metadataKey ?? this.metadataKey,
        metadataValue: metadataValue ?? this.metadataValue,
      );
  QuranMetadataRecord copyWithCompanion(QuranMetadataCompanion data) {
    return QuranMetadataRecord(
      metadataKey: data.metadataKey.present
          ? data.metadataKey.value
          : this.metadataKey,
      metadataValue: data.metadataValue.present
          ? data.metadataValue.value
          : this.metadataValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranMetadataRecord(')
          ..write('metadataKey: $metadataKey, ')
          ..write('metadataValue: $metadataValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metadataKey, metadataValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranMetadataRecord &&
          other.metadataKey == this.metadataKey &&
          other.metadataValue == this.metadataValue);
}

class QuranMetadataCompanion extends UpdateCompanion<QuranMetadataRecord> {
  final Value<String> metadataKey;
  final Value<String> metadataValue;
  final Value<int> rowid;
  const QuranMetadataCompanion({
    this.metadataKey = const Value.absent(),
    this.metadataValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranMetadataCompanion.insert({
    required String metadataKey,
    required String metadataValue,
    this.rowid = const Value.absent(),
  }) : metadataKey = Value(metadataKey),
       metadataValue = Value(metadataValue);
  static Insertable<QuranMetadataRecord> custom({
    Expression<String>? metadataKey,
    Expression<String>? metadataValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (metadataKey != null) 'metadata_key': metadataKey,
      if (metadataValue != null) 'metadata_value': metadataValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranMetadataCompanion copyWith({
    Value<String>? metadataKey,
    Value<String>? metadataValue,
    Value<int>? rowid,
  }) {
    return QuranMetadataCompanion(
      metadataKey: metadataKey ?? this.metadataKey,
      metadataValue: metadataValue ?? this.metadataValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metadataKey.present) {
      map['metadata_key'] = Variable<String>(metadataKey.value);
    }
    if (metadataValue.present) {
      map['metadata_value'] = Variable<String>(metadataValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranMetadataCompanion(')
          ..write('metadataKey: $metadataKey, ')
          ..write('metadataValue: $metadataValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MushafLinesTable extends MushafLines
    with TableInfo<$MushafLinesTable, MushafLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MushafLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNumberMeta = const VerificationMeta(
    'lineNumber',
  );
  @override
  late final GeneratedColumn<int> lineNumber = GeneratedColumn<int>(
    'line_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTypeMeta = const VerificationMeta(
    'lineType',
  );
  @override
  late final GeneratedColumn<String> lineType = GeneratedColumn<String>(
    'line_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCenteredMeta = const VerificationMeta(
    'isCentered',
  );
  @override
  late final GeneratedColumn<bool> isCentered = GeneratedColumn<bool>(
    'is_centered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_centered" IN (0, 1))',
    ),
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstWordLocationMeta = const VerificationMeta(
    'firstWordLocation',
  );
  @override
  late final GeneratedColumn<String> firstWordLocation =
      GeneratedColumn<String>(
        'first_word_location',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastWordLocationMeta = const VerificationMeta(
    'lastWordLocation',
  );
  @override
  late final GeneratedColumn<String> lastWordLocation = GeneratedColumn<String>(
    'last_word_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pageNumber,
    lineNumber,
    lineType,
    isCentered,
    surahNumber,
    firstWordLocation,
    lastWordLocation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('line_number')) {
      context.handle(
        _lineNumberMeta,
        lineNumber.isAcceptableOrUnknown(data['line_number']!, _lineNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNumberMeta);
    }
    if (data.containsKey('line_type')) {
      context.handle(
        _lineTypeMeta,
        lineType.isAcceptableOrUnknown(data['line_type']!, _lineTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTypeMeta);
    }
    if (data.containsKey('is_centered')) {
      context.handle(
        _isCenteredMeta,
        isCentered.isAcceptableOrUnknown(data['is_centered']!, _isCenteredMeta),
      );
    } else if (isInserting) {
      context.missing(_isCenteredMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    }
    if (data.containsKey('first_word_location')) {
      context.handle(
        _firstWordLocationMeta,
        firstWordLocation.isAcceptableOrUnknown(
          data['first_word_location']!,
          _firstWordLocationMeta,
        ),
      );
    }
    if (data.containsKey('last_word_location')) {
      context.handle(
        _lastWordLocationMeta,
        lastWordLocation.isAcceptableOrUnknown(
          data['last_word_location']!,
          _lastWordLocationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pageNumber, lineNumber};
  @override
  MushafLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafLine(
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      lineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_number'],
      )!,
      lineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_type'],
      )!,
      isCentered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_centered'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      ),
      firstWordLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_word_location'],
      ),
      lastWordLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_word_location'],
      ),
    );
  }

  @override
  $MushafLinesTable createAlias(String alias) {
    return $MushafLinesTable(attachedDatabase, alias);
  }
}

class MushafLine extends DataClass implements Insertable<MushafLine> {
  final int pageNumber;
  final int lineNumber;
  final String lineType;
  final bool isCentered;
  final int? surahNumber;
  final String? firstWordLocation;
  final String? lastWordLocation;
  const MushafLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    this.surahNumber,
    this.firstWordLocation,
    this.lastWordLocation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_number'] = Variable<int>(pageNumber);
    map['line_number'] = Variable<int>(lineNumber);
    map['line_type'] = Variable<String>(lineType);
    map['is_centered'] = Variable<bool>(isCentered);
    if (!nullToAbsent || surahNumber != null) {
      map['surah_number'] = Variable<int>(surahNumber);
    }
    if (!nullToAbsent || firstWordLocation != null) {
      map['first_word_location'] = Variable<String>(firstWordLocation);
    }
    if (!nullToAbsent || lastWordLocation != null) {
      map['last_word_location'] = Variable<String>(lastWordLocation);
    }
    return map;
  }

  MushafLinesCompanion toCompanion(bool nullToAbsent) {
    return MushafLinesCompanion(
      pageNumber: Value(pageNumber),
      lineNumber: Value(lineNumber),
      lineType: Value(lineType),
      isCentered: Value(isCentered),
      surahNumber: surahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(surahNumber),
      firstWordLocation: firstWordLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(firstWordLocation),
      lastWordLocation: lastWordLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWordLocation),
    );
  }

  factory MushafLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafLine(
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      lineNumber: serializer.fromJson<int>(json['lineNumber']),
      lineType: serializer.fromJson<String>(json['lineType']),
      isCentered: serializer.fromJson<bool>(json['isCentered']),
      surahNumber: serializer.fromJson<int?>(json['surahNumber']),
      firstWordLocation: serializer.fromJson<String?>(
        json['firstWordLocation'],
      ),
      lastWordLocation: serializer.fromJson<String?>(json['lastWordLocation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageNumber': serializer.toJson<int>(pageNumber),
      'lineNumber': serializer.toJson<int>(lineNumber),
      'lineType': serializer.toJson<String>(lineType),
      'isCentered': serializer.toJson<bool>(isCentered),
      'surahNumber': serializer.toJson<int?>(surahNumber),
      'firstWordLocation': serializer.toJson<String?>(firstWordLocation),
      'lastWordLocation': serializer.toJson<String?>(lastWordLocation),
    };
  }

  MushafLine copyWith({
    int? pageNumber,
    int? lineNumber,
    String? lineType,
    bool? isCentered,
    Value<int?> surahNumber = const Value.absent(),
    Value<String?> firstWordLocation = const Value.absent(),
    Value<String?> lastWordLocation = const Value.absent(),
  }) => MushafLine(
    pageNumber: pageNumber ?? this.pageNumber,
    lineNumber: lineNumber ?? this.lineNumber,
    lineType: lineType ?? this.lineType,
    isCentered: isCentered ?? this.isCentered,
    surahNumber: surahNumber.present ? surahNumber.value : this.surahNumber,
    firstWordLocation: firstWordLocation.present
        ? firstWordLocation.value
        : this.firstWordLocation,
    lastWordLocation: lastWordLocation.present
        ? lastWordLocation.value
        : this.lastWordLocation,
  );
  MushafLine copyWithCompanion(MushafLinesCompanion data) {
    return MushafLine(
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      lineNumber: data.lineNumber.present
          ? data.lineNumber.value
          : this.lineNumber,
      lineType: data.lineType.present ? data.lineType.value : this.lineType,
      isCentered: data.isCentered.present
          ? data.isCentered.value
          : this.isCentered,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      firstWordLocation: data.firstWordLocation.present
          ? data.firstWordLocation.value
          : this.firstWordLocation,
      lastWordLocation: data.lastWordLocation.present
          ? data.lastWordLocation.value
          : this.lastWordLocation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafLine(')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('lineType: $lineType, ')
          ..write('isCentered: $isCentered, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('firstWordLocation: $firstWordLocation, ')
          ..write('lastWordLocation: $lastWordLocation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pageNumber,
    lineNumber,
    lineType,
    isCentered,
    surahNumber,
    firstWordLocation,
    lastWordLocation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafLine &&
          other.pageNumber == this.pageNumber &&
          other.lineNumber == this.lineNumber &&
          other.lineType == this.lineType &&
          other.isCentered == this.isCentered &&
          other.surahNumber == this.surahNumber &&
          other.firstWordLocation == this.firstWordLocation &&
          other.lastWordLocation == this.lastWordLocation);
}

class MushafLinesCompanion extends UpdateCompanion<MushafLine> {
  final Value<int> pageNumber;
  final Value<int> lineNumber;
  final Value<String> lineType;
  final Value<bool> isCentered;
  final Value<int?> surahNumber;
  final Value<String?> firstWordLocation;
  final Value<String?> lastWordLocation;
  final Value<int> rowid;
  const MushafLinesCompanion({
    this.pageNumber = const Value.absent(),
    this.lineNumber = const Value.absent(),
    this.lineType = const Value.absent(),
    this.isCentered = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.firstWordLocation = const Value.absent(),
    this.lastWordLocation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafLinesCompanion.insert({
    required int pageNumber,
    required int lineNumber,
    required String lineType,
    required bool isCentered,
    this.surahNumber = const Value.absent(),
    this.firstWordLocation = const Value.absent(),
    this.lastWordLocation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pageNumber = Value(pageNumber),
       lineNumber = Value(lineNumber),
       lineType = Value(lineType),
       isCentered = Value(isCentered);
  static Insertable<MushafLine> custom({
    Expression<int>? pageNumber,
    Expression<int>? lineNumber,
    Expression<String>? lineType,
    Expression<bool>? isCentered,
    Expression<int>? surahNumber,
    Expression<String>? firstWordLocation,
    Expression<String>? lastWordLocation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pageNumber != null) 'page_number': pageNumber,
      if (lineNumber != null) 'line_number': lineNumber,
      if (lineType != null) 'line_type': lineType,
      if (isCentered != null) 'is_centered': isCentered,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (firstWordLocation != null) 'first_word_location': firstWordLocation,
      if (lastWordLocation != null) 'last_word_location': lastWordLocation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafLinesCompanion copyWith({
    Value<int>? pageNumber,
    Value<int>? lineNumber,
    Value<String>? lineType,
    Value<bool>? isCentered,
    Value<int?>? surahNumber,
    Value<String?>? firstWordLocation,
    Value<String?>? lastWordLocation,
    Value<int>? rowid,
  }) {
    return MushafLinesCompanion(
      pageNumber: pageNumber ?? this.pageNumber,
      lineNumber: lineNumber ?? this.lineNumber,
      lineType: lineType ?? this.lineType,
      isCentered: isCentered ?? this.isCentered,
      surahNumber: surahNumber ?? this.surahNumber,
      firstWordLocation: firstWordLocation ?? this.firstWordLocation,
      lastWordLocation: lastWordLocation ?? this.lastWordLocation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (lineNumber.present) {
      map['line_number'] = Variable<int>(lineNumber.value);
    }
    if (lineType.present) {
      map['line_type'] = Variable<String>(lineType.value);
    }
    if (isCentered.present) {
      map['is_centered'] = Variable<bool>(isCentered.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (firstWordLocation.present) {
      map['first_word_location'] = Variable<String>(firstWordLocation.value);
    }
    if (lastWordLocation.present) {
      map['last_word_location'] = Variable<String>(lastWordLocation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafLinesCompanion(')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('lineType: $lineType, ')
          ..write('isCentered: $isCentered, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('firstWordLocation: $firstWordLocation, ')
          ..write('lastWordLocation: $lastWordLocation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuranContentDatabase extends GeneratedDatabase {
  _$QuranContentDatabase(QueryExecutor e) : super(e);
  $QuranContentDatabaseManager get managers =>
      $QuranContentDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $AyahsTable ayahs = $AyahsTable(this);
  late final $QuranWordsTable quranWords = $QuranWordsTable(this);
  late final $TranslationsTable translations = $TranslationsTable(this);
  late final $QuranMetadataTable quranMetadata = $QuranMetadataTable(this);
  late final $MushafLinesTable mushafLines = $MushafLinesTable(this);
  late final Index idxAyahPage = Index(
    'idx_ayah_page',
    'CREATE INDEX idx_ayah_page ON ayahs (page_number, surah_number, ayah_number)',
  );
  late final Index idxAyahJuz = Index(
    'idx_ayah_juz',
    'CREATE INDEX idx_ayah_juz ON ayahs (juz_number, surah_number, ayah_number)',
  );
  late final Index idxWordLookup = Index(
    'idx_word_lookup',
    'CREATE INDEX idx_word_lookup ON quran_words (surah_number, ayah_number, position)',
  );
  late final Index idxTranslationLookup = Index(
    'idx_translation_lookup',
    'CREATE INDEX idx_translation_lookup ON translations (resource_id, surah_number, ayah_number)',
  );
  late final Index idxMushafLinePage = Index(
    'idx_mushaf_line_page',
    'CREATE INDEX idx_mushaf_line_page ON mushaf_lines (page_number, line_number)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    surahs,
    ayahs,
    quranWords,
    translations,
    quranMetadata,
    mushafLines,
    idxAyahPage,
    idxAyahJuz,
    idxWordLookup,
    idxTranslationLookup,
    idxMushafLinePage,
  ];
}

typedef $$SurahsTableCreateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      required String nameArabic,
      required String nameEnglish,
      Value<String?> nameBangla,
      Value<String?> revelationPlace,
      required int ayahCount,
      required int pageStart,
      required int pageEnd,
      required int juzStart,
    });
typedef $$SurahsTableUpdateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      Value<String> nameArabic,
      Value<String> nameEnglish,
      Value<String?> nameBangla,
      Value<String?> revelationPlace,
      Value<int> ayahCount,
      Value<int> pageStart,
      Value<int> pageEnd,
      Value<int> juzStart,
    });

class $$SurahsTableFilterComposer
    extends Composer<_$QuranContentDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameBangla => $composableBuilder(
    column: $table.nameBangla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juzStart => $composableBuilder(
    column: $table.juzStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurahsTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameBangla => $composableBuilder(
    column: $table.nameBangla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juzStart => $composableBuilder(
    column: $table.juzStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameBangla => $composableBuilder(
    column: $table.nameBangla,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  GeneratedColumn<int> get juzStart =>
      $composableBuilder(column: $table.juzStart, builder: (column) => column);
}

class $$SurahsTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $SurahsTable,
          Surah,
          $$SurahsTableFilterComposer,
          $$SurahsTableOrderingComposer,
          $$SurahsTableAnnotationComposer,
          $$SurahsTableCreateCompanionBuilder,
          $$SurahsTableUpdateCompanionBuilder,
          (Surah, BaseReferences<_$QuranContentDatabase, $SurahsTable, Surah>),
          Surah,
          PrefetchHooks Function()
        > {
  $$SurahsTableTableManager(_$QuranContentDatabase db, $SurahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameEnglish = const Value.absent(),
                Value<String?> nameBangla = const Value.absent(),
                Value<String?> revelationPlace = const Value.absent(),
                Value<int> ayahCount = const Value.absent(),
                Value<int> pageStart = const Value.absent(),
                Value<int> pageEnd = const Value.absent(),
                Value<int> juzStart = const Value.absent(),
              }) => SurahsCompanion(
                number: number,
                nameArabic: nameArabic,
                nameEnglish: nameEnglish,
                nameBangla: nameBangla,
                revelationPlace: revelationPlace,
                ayahCount: ayahCount,
                pageStart: pageStart,
                pageEnd: pageEnd,
                juzStart: juzStart,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String nameArabic,
                required String nameEnglish,
                Value<String?> nameBangla = const Value.absent(),
                Value<String?> revelationPlace = const Value.absent(),
                required int ayahCount,
                required int pageStart,
                required int pageEnd,
                required int juzStart,
              }) => SurahsCompanion.insert(
                number: number,
                nameArabic: nameArabic,
                nameEnglish: nameEnglish,
                nameBangla: nameBangla,
                revelationPlace: revelationPlace,
                ayahCount: ayahCount,
                pageStart: pageStart,
                pageEnd: pageEnd,
                juzStart: juzStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SurahsTable, Surah>(table),
                  BaseReferences<_$QuranContentDatabase, $SurahsTable, Surah>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurahsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $SurahsTable,
      Surah,
      $$SurahsTableFilterComposer,
      $$SurahsTableOrderingComposer,
      $$SurahsTableAnnotationComposer,
      $$SurahsTableCreateCompanionBuilder,
      $$SurahsTableUpdateCompanionBuilder,
      (Surah, BaseReferences<_$QuranContentDatabase, $SurahsTable, Surah>),
      Surah,
      PrefetchHooks Function()
    >;
typedef $$AyahsTableCreateCompanionBuilder =
    AyahsCompanion Function({
      required int surahNumber,
      required int ayahNumber,
      required String verseKey,
      required String arabicText,
      required String arabicTextIndopak,
      Value<String?> arabicTextTajweed,
      required int pageNumber,
      required int juzNumber,
      Value<int?> hizbNumber,
      Value<int?> rubNumber,
      Value<int> rowid,
    });
typedef $$AyahsTableUpdateCompanionBuilder =
    AyahsCompanion Function({
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<String> verseKey,
      Value<String> arabicText,
      Value<String> arabicTextIndopak,
      Value<String?> arabicTextTajweed,
      Value<int> pageNumber,
      Value<int> juzNumber,
      Value<int?> hizbNumber,
      Value<int?> rubNumber,
      Value<int> rowid,
    });

class $$AyahsTableFilterComposer
    extends Composer<_$QuranContentDatabase, $AyahsTable> {
  $$AyahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicTextIndopak => $composableBuilder(
    column: $table.arabicTextIndopak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicTextTajweed => $composableBuilder(
    column: $table.arabicTextTajweed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juzNumber => $composableBuilder(
    column: $table.juzNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rubNumber => $composableBuilder(
    column: $table.rubNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyahsTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $AyahsTable> {
  $$AyahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicTextIndopak => $composableBuilder(
    column: $table.arabicTextIndopak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicTextTajweed => $composableBuilder(
    column: $table.arabicTextTajweed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juzNumber => $composableBuilder(
    column: $table.juzNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rubNumber => $composableBuilder(
    column: $table.rubNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyahsTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $AyahsTable> {
  $$AyahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arabicTextIndopak => $composableBuilder(
    column: $table.arabicTextIndopak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arabicTextTajweed => $composableBuilder(
    column: $table.arabicTextTajweed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juzNumber =>
      $composableBuilder(column: $table.juzNumber, builder: (column) => column);

  GeneratedColumn<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rubNumber =>
      $composableBuilder(column: $table.rubNumber, builder: (column) => column);
}

class $$AyahsTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $AyahsTable,
          Ayah,
          $$AyahsTableFilterComposer,
          $$AyahsTableOrderingComposer,
          $$AyahsTableAnnotationComposer,
          $$AyahsTableCreateCompanionBuilder,
          $$AyahsTableUpdateCompanionBuilder,
          (Ayah, BaseReferences<_$QuranContentDatabase, $AyahsTable, Ayah>),
          Ayah,
          PrefetchHooks Function()
        > {
  $$AyahsTableTableManager(_$QuranContentDatabase db, $AyahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<String> arabicText = const Value.absent(),
                Value<String> arabicTextIndopak = const Value.absent(),
                Value<String?> arabicTextTajweed = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<int> juzNumber = const Value.absent(),
                Value<int?> hizbNumber = const Value.absent(),
                Value<int?> rubNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahsCompanion(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                arabicText: arabicText,
                arabicTextIndopak: arabicTextIndopak,
                arabicTextTajweed: arabicTextTajweed,
                pageNumber: pageNumber,
                juzNumber: juzNumber,
                hizbNumber: hizbNumber,
                rubNumber: rubNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int surahNumber,
                required int ayahNumber,
                required String verseKey,
                required String arabicText,
                required String arabicTextIndopak,
                Value<String?> arabicTextTajweed = const Value.absent(),
                required int pageNumber,
                required int juzNumber,
                Value<int?> hizbNumber = const Value.absent(),
                Value<int?> rubNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahsCompanion.insert(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                arabicText: arabicText,
                arabicTextIndopak: arabicTextIndopak,
                arabicTextTajweed: arabicTextTajweed,
                pageNumber: pageNumber,
                juzNumber: juzNumber,
                hizbNumber: hizbNumber,
                rubNumber: rubNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AyahsTable, Ayah>(table),
                  BaseReferences<_$QuranContentDatabase, $AyahsTable, Ayah>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyahsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $AyahsTable,
      Ayah,
      $$AyahsTableFilterComposer,
      $$AyahsTableOrderingComposer,
      $$AyahsTableAnnotationComposer,
      $$AyahsTableCreateCompanionBuilder,
      $$AyahsTableUpdateCompanionBuilder,
      (Ayah, BaseReferences<_$QuranContentDatabase, $AyahsTable, Ayah>),
      Ayah,
      PrefetchHooks Function()
    >;
typedef $$QuranWordsTableCreateCompanionBuilder =
    QuranWordsCompanion Function({
      required int surahNumber,
      required int ayahNumber,
      required int position,
      required String arabic,
      required String arabicIndopak,
      Value<String?> arabicTajweed,
      Value<String?> transliteration,
      Value<String?> banglaMeaning,
      Value<String?> englishMeaning,
      Value<String?> root,
      Value<String?> lemma,
      Value<String?> grammar,
      Value<String?> audioRemotePath,
      Value<int> rowid,
    });
typedef $$QuranWordsTableUpdateCompanionBuilder =
    QuranWordsCompanion Function({
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<int> position,
      Value<String> arabic,
      Value<String> arabicIndopak,
      Value<String?> arabicTajweed,
      Value<String?> transliteration,
      Value<String?> banglaMeaning,
      Value<String?> englishMeaning,
      Value<String?> root,
      Value<String?> lemma,
      Value<String?> grammar,
      Value<String?> audioRemotePath,
      Value<int> rowid,
    });

class $$QuranWordsTableFilterComposer
    extends Composer<_$QuranContentDatabase, $QuranWordsTable> {
  $$QuranWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicIndopak => $composableBuilder(
    column: $table.arabicIndopak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicTajweed => $composableBuilder(
    column: $table.arabicTajweed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get banglaMeaning => $composableBuilder(
    column: $table.banglaMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishMeaning => $composableBuilder(
    column: $table.englishMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioRemotePath => $composableBuilder(
    column: $table.audioRemotePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranWordsTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $QuranWordsTable> {
  $$QuranWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicIndopak => $composableBuilder(
    column: $table.arabicIndopak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicTajweed => $composableBuilder(
    column: $table.arabicTajweed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get banglaMeaning => $composableBuilder(
    column: $table.banglaMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishMeaning => $composableBuilder(
    column: $table.englishMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioRemotePath => $composableBuilder(
    column: $table.audioRemotePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranWordsTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $QuranWordsTable> {
  $$QuranWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get arabic =>
      $composableBuilder(column: $table.arabic, builder: (column) => column);

  GeneratedColumn<String> get arabicIndopak => $composableBuilder(
    column: $table.arabicIndopak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arabicTajweed => $composableBuilder(
    column: $table.arabicTajweed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get banglaMeaning => $composableBuilder(
    column: $table.banglaMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishMeaning => $composableBuilder(
    column: $table.englishMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get grammar =>
      $composableBuilder(column: $table.grammar, builder: (column) => column);

  GeneratedColumn<String> get audioRemotePath => $composableBuilder(
    column: $table.audioRemotePath,
    builder: (column) => column,
  );
}

class $$QuranWordsTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $QuranWordsTable,
          QuranWordRecord,
          $$QuranWordsTableFilterComposer,
          $$QuranWordsTableOrderingComposer,
          $$QuranWordsTableAnnotationComposer,
          $$QuranWordsTableCreateCompanionBuilder,
          $$QuranWordsTableUpdateCompanionBuilder,
          (
            QuranWordRecord,
            BaseReferences<
              _$QuranContentDatabase,
              $QuranWordsTable,
              QuranWordRecord
            >,
          ),
          QuranWordRecord,
          PrefetchHooks Function()
        > {
  $$QuranWordsTableTableManager(
    _$QuranContentDatabase db,
    $QuranWordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> arabic = const Value.absent(),
                Value<String> arabicIndopak = const Value.absent(),
                Value<String?> arabicTajweed = const Value.absent(),
                Value<String?> transliteration = const Value.absent(),
                Value<String?> banglaMeaning = const Value.absent(),
                Value<String?> englishMeaning = const Value.absent(),
                Value<String?> root = const Value.absent(),
                Value<String?> lemma = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> audioRemotePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranWordsCompanion(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                position: position,
                arabic: arabic,
                arabicIndopak: arabicIndopak,
                arabicTajweed: arabicTajweed,
                transliteration: transliteration,
                banglaMeaning: banglaMeaning,
                englishMeaning: englishMeaning,
                root: root,
                lemma: lemma,
                grammar: grammar,
                audioRemotePath: audioRemotePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int surahNumber,
                required int ayahNumber,
                required int position,
                required String arabic,
                required String arabicIndopak,
                Value<String?> arabicTajweed = const Value.absent(),
                Value<String?> transliteration = const Value.absent(),
                Value<String?> banglaMeaning = const Value.absent(),
                Value<String?> englishMeaning = const Value.absent(),
                Value<String?> root = const Value.absent(),
                Value<String?> lemma = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> audioRemotePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranWordsCompanion.insert(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                position: position,
                arabic: arabic,
                arabicIndopak: arabicIndopak,
                arabicTajweed: arabicTajweed,
                transliteration: transliteration,
                banglaMeaning: banglaMeaning,
                englishMeaning: englishMeaning,
                root: root,
                lemma: lemma,
                grammar: grammar,
                audioRemotePath: audioRemotePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranWordsTable, QuranWordRecord>(table),
                  BaseReferences<
                    _$QuranContentDatabase,
                    $QuranWordsTable,
                    QuranWordRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $QuranWordsTable,
      QuranWordRecord,
      $$QuranWordsTableFilterComposer,
      $$QuranWordsTableOrderingComposer,
      $$QuranWordsTableAnnotationComposer,
      $$QuranWordsTableCreateCompanionBuilder,
      $$QuranWordsTableUpdateCompanionBuilder,
      (
        QuranWordRecord,
        BaseReferences<
          _$QuranContentDatabase,
          $QuranWordsTable,
          QuranWordRecord
        >,
      ),
      QuranWordRecord,
      PrefetchHooks Function()
    >;
typedef $$TranslationsTableCreateCompanionBuilder =
    TranslationsCompanion Function({
      required int resourceId,
      required int surahNumber,
      required int ayahNumber,
      required String language,
      required String textValue,
      Value<int> rowid,
    });
typedef $$TranslationsTableUpdateCompanionBuilder =
    TranslationsCompanion Function({
      Value<int> resourceId,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<String> language,
      Value<String> textValue,
      Value<int> rowid,
    });

class $$TranslationsTableFilterComposer
    extends Composer<_$QuranContentDatabase, $TranslationsTable> {
  $$TranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranslationsTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $TranslationsTable> {
  $$TranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranslationsTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $TranslationsTable> {
  $$TranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);
}

class $$TranslationsTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $TranslationsTable,
          TranslationRecord,
          $$TranslationsTableFilterComposer,
          $$TranslationsTableOrderingComposer,
          $$TranslationsTableAnnotationComposer,
          $$TranslationsTableCreateCompanionBuilder,
          $$TranslationsTableUpdateCompanionBuilder,
          (
            TranslationRecord,
            BaseReferences<
              _$QuranContentDatabase,
              $TranslationsTable,
              TranslationRecord
            >,
          ),
          TranslationRecord,
          PrefetchHooks Function()
        > {
  $$TranslationsTableTableManager(
    _$QuranContentDatabase db,
    $TranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion(
                resourceId: resourceId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                language: language,
                textValue: textValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int resourceId,
                required int surahNumber,
                required int ayahNumber,
                required String language,
                required String textValue,
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion.insert(
                resourceId: resourceId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                language: language,
                textValue: textValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranslationsTable, TranslationRecord>(table),
                  BaseReferences<
                    _$QuranContentDatabase,
                    $TranslationsTable,
                    TranslationRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $TranslationsTable,
      TranslationRecord,
      $$TranslationsTableFilterComposer,
      $$TranslationsTableOrderingComposer,
      $$TranslationsTableAnnotationComposer,
      $$TranslationsTableCreateCompanionBuilder,
      $$TranslationsTableUpdateCompanionBuilder,
      (
        TranslationRecord,
        BaseReferences<
          _$QuranContentDatabase,
          $TranslationsTable,
          TranslationRecord
        >,
      ),
      TranslationRecord,
      PrefetchHooks Function()
    >;
typedef $$QuranMetadataTableCreateCompanionBuilder =
    QuranMetadataCompanion Function({
      required String metadataKey,
      required String metadataValue,
      Value<int> rowid,
    });
typedef $$QuranMetadataTableUpdateCompanionBuilder =
    QuranMetadataCompanion Function({
      Value<String> metadataKey,
      Value<String> metadataValue,
      Value<int> rowid,
    });

class $$QuranMetadataTableFilterComposer
    extends Composer<_$QuranContentDatabase, $QuranMetadataTable> {
  $$QuranMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metadataKey => $composableBuilder(
    column: $table.metadataKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataValue => $composableBuilder(
    column: $table.metadataValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranMetadataTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $QuranMetadataTable> {
  $$QuranMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metadataKey => $composableBuilder(
    column: $table.metadataKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataValue => $composableBuilder(
    column: $table.metadataValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranMetadataTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $QuranMetadataTable> {
  $$QuranMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metadataKey => $composableBuilder(
    column: $table.metadataKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataValue => $composableBuilder(
    column: $table.metadataValue,
    builder: (column) => column,
  );
}

class $$QuranMetadataTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $QuranMetadataTable,
          QuranMetadataRecord,
          $$QuranMetadataTableFilterComposer,
          $$QuranMetadataTableOrderingComposer,
          $$QuranMetadataTableAnnotationComposer,
          $$QuranMetadataTableCreateCompanionBuilder,
          $$QuranMetadataTableUpdateCompanionBuilder,
          (
            QuranMetadataRecord,
            BaseReferences<
              _$QuranContentDatabase,
              $QuranMetadataTable,
              QuranMetadataRecord
            >,
          ),
          QuranMetadataRecord,
          PrefetchHooks Function()
        > {
  $$QuranMetadataTableTableManager(
    _$QuranContentDatabase db,
    $QuranMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> metadataKey = const Value.absent(),
                Value<String> metadataValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranMetadataCompanion(
                metadataKey: metadataKey,
                metadataValue: metadataValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String metadataKey,
                required String metadataValue,
                Value<int> rowid = const Value.absent(),
              }) => QuranMetadataCompanion.insert(
                metadataKey: metadataKey,
                metadataValue: metadataValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranMetadataTable, QuranMetadataRecord>(table),
                  BaseReferences<
                    _$QuranContentDatabase,
                    $QuranMetadataTable,
                    QuranMetadataRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $QuranMetadataTable,
      QuranMetadataRecord,
      $$QuranMetadataTableFilterComposer,
      $$QuranMetadataTableOrderingComposer,
      $$QuranMetadataTableAnnotationComposer,
      $$QuranMetadataTableCreateCompanionBuilder,
      $$QuranMetadataTableUpdateCompanionBuilder,
      (
        QuranMetadataRecord,
        BaseReferences<
          _$QuranContentDatabase,
          $QuranMetadataTable,
          QuranMetadataRecord
        >,
      ),
      QuranMetadataRecord,
      PrefetchHooks Function()
    >;
typedef $$MushafLinesTableCreateCompanionBuilder =
    MushafLinesCompanion Function({
      required int pageNumber,
      required int lineNumber,
      required String lineType,
      required bool isCentered,
      Value<int?> surahNumber,
      Value<String?> firstWordLocation,
      Value<String?> lastWordLocation,
      Value<int> rowid,
    });
typedef $$MushafLinesTableUpdateCompanionBuilder =
    MushafLinesCompanion Function({
      Value<int> pageNumber,
      Value<int> lineNumber,
      Value<String> lineType,
      Value<bool> isCentered,
      Value<int?> surahNumber,
      Value<String?> firstWordLocation,
      Value<String?> lastWordLocation,
      Value<int> rowid,
    });

class $$MushafLinesTableFilterComposer
    extends Composer<_$QuranContentDatabase, $MushafLinesTable> {
  $$MushafLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineType => $composableBuilder(
    column: $table.lineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCentered => $composableBuilder(
    column: $table.isCentered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstWordLocation => $composableBuilder(
    column: $table.firstWordLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastWordLocation => $composableBuilder(
    column: $table.lastWordLocation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MushafLinesTableOrderingComposer
    extends Composer<_$QuranContentDatabase, $MushafLinesTable> {
  $$MushafLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineType => $composableBuilder(
    column: $table.lineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCentered => $composableBuilder(
    column: $table.isCentered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstWordLocation => $composableBuilder(
    column: $table.firstWordLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastWordLocation => $composableBuilder(
    column: $table.lastWordLocation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MushafLinesTableAnnotationComposer
    extends Composer<_$QuranContentDatabase, $MushafLinesTable> {
  $$MushafLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lineType =>
      $composableBuilder(column: $table.lineType, builder: (column) => column);

  GeneratedColumn<bool> get isCentered => $composableBuilder(
    column: $table.isCentered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstWordLocation => $composableBuilder(
    column: $table.firstWordLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastWordLocation => $composableBuilder(
    column: $table.lastWordLocation,
    builder: (column) => column,
  );
}

class $$MushafLinesTableTableManager
    extends
        RootTableManager<
          _$QuranContentDatabase,
          $MushafLinesTable,
          MushafLine,
          $$MushafLinesTableFilterComposer,
          $$MushafLinesTableOrderingComposer,
          $$MushafLinesTableAnnotationComposer,
          $$MushafLinesTableCreateCompanionBuilder,
          $$MushafLinesTableUpdateCompanionBuilder,
          (
            MushafLine,
            BaseReferences<
              _$QuranContentDatabase,
              $MushafLinesTable,
              MushafLine
            >,
          ),
          MushafLine,
          PrefetchHooks Function()
        > {
  $$MushafLinesTableTableManager(
    _$QuranContentDatabase db,
    $MushafLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MushafLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MushafLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MushafLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pageNumber = const Value.absent(),
                Value<int> lineNumber = const Value.absent(),
                Value<String> lineType = const Value.absent(),
                Value<bool> isCentered = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<String?> firstWordLocation = const Value.absent(),
                Value<String?> lastWordLocation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafLinesCompanion(
                pageNumber: pageNumber,
                lineNumber: lineNumber,
                lineType: lineType,
                isCentered: isCentered,
                surahNumber: surahNumber,
                firstWordLocation: firstWordLocation,
                lastWordLocation: lastWordLocation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pageNumber,
                required int lineNumber,
                required String lineType,
                required bool isCentered,
                Value<int?> surahNumber = const Value.absent(),
                Value<String?> firstWordLocation = const Value.absent(),
                Value<String?> lastWordLocation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafLinesCompanion.insert(
                pageNumber: pageNumber,
                lineNumber: lineNumber,
                lineType: lineType,
                isCentered: isCentered,
                surahNumber: surahNumber,
                firstWordLocation: firstWordLocation,
                lastWordLocation: lastWordLocation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MushafLinesTable, MushafLine>(table),
                  BaseReferences<
                    _$QuranContentDatabase,
                    $MushafLinesTable,
                    MushafLine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MushafLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranContentDatabase,
      $MushafLinesTable,
      MushafLine,
      $$MushafLinesTableFilterComposer,
      $$MushafLinesTableOrderingComposer,
      $$MushafLinesTableAnnotationComposer,
      $$MushafLinesTableCreateCompanionBuilder,
      $$MushafLinesTableUpdateCompanionBuilder,
      (
        MushafLine,
        BaseReferences<_$QuranContentDatabase, $MushafLinesTable, MushafLine>,
      ),
      MushafLine,
      PrefetchHooks Function()
    >;

class $QuranContentDatabaseManager {
  final _$QuranContentDatabase _db;
  $QuranContentDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$AyahsTableTableManager get ayahs =>
      $$AyahsTableTableManager(_db, _db.ayahs);
  $$QuranWordsTableTableManager get quranWords =>
      $$QuranWordsTableTableManager(_db, _db.quranWords);
  $$TranslationsTableTableManager get translations =>
      $$TranslationsTableTableManager(_db, _db.translations);
  $$QuranMetadataTableTableManager get quranMetadata =>
      $$QuranMetadataTableTableManager(_db, _db.quranMetadata);
  $$MushafLinesTableTableManager get mushafLines =>
      $$MushafLinesTableTableManager(_db, _db.mushafLines);
}
