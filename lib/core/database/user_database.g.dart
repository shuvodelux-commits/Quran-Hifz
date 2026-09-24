// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $AudioFilesTable extends AudioFiles
    with TableInfo<$AudioFilesTable, AudioFileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _audioKeyMeta = const VerificationMeta(
    'audioKey',
  );
  @override
  late final GeneratedColumn<String> audioKey = GeneratedColumn<String>(
    'audio_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioTypeMeta = const VerificationMeta(
    'audioType',
  );
  @override
  late final GeneratedColumn<String> audioType = GeneratedColumn<String>(
    'audio_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<int> reciterId = GeneratedColumn<int>(
    'reciter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordPositionMeta = const VerificationMeta(
    'wordPosition',
  );
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
    'word_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('remote'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    audioKey,
    audioType,
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    remoteUrl,
    localPath,
    format,
    fileSize,
    downloadedBytes,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioFileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audio_key')) {
      context.handle(
        _audioKeyMeta,
        audioKey.isAcceptableOrUnknown(data['audio_key']!, _audioKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_audioKeyMeta);
    }
    if (data.containsKey('audio_type')) {
      context.handle(
        _audioTypeMeta,
        audioType.isAcceptableOrUnknown(data['audio_type']!, _audioTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_audioTypeMeta);
    }
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
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
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    }
    if (data.containsKey('word_position')) {
      context.handle(
        _wordPositionMeta,
        wordPosition.isAcceptableOrUnknown(
          data['word_position']!,
          _wordPositionMeta,
        ),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {audioKey};
  @override
  AudioFileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioFileRecord(
      audioKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_key'],
      )!,
      audioType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_type'],
      )!,
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reciter_id'],
      ),
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      ),
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      ),
      wordPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_position'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AudioFilesTable createAlias(String alias) {
    return $AudioFilesTable(attachedDatabase, alias);
  }
}

class AudioFileRecord extends DataClass implements Insertable<AudioFileRecord> {
  final String audioKey;
  final String audioType;
  final int? reciterId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? wordPosition;
  final String remoteUrl;
  final String? localPath;
  final String? format;
  final int? fileSize;
  final int downloadedBytes;
  final String status;
  final int updatedAt;
  const AudioFileRecord({
    required this.audioKey,
    required this.audioType,
    this.reciterId,
    this.surahNumber,
    this.ayahNumber,
    this.wordPosition,
    required this.remoteUrl,
    this.localPath,
    this.format,
    this.fileSize,
    required this.downloadedBytes,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audio_key'] = Variable<String>(audioKey);
    map['audio_type'] = Variable<String>(audioType);
    if (!nullToAbsent || reciterId != null) {
      map['reciter_id'] = Variable<int>(reciterId);
    }
    if (!nullToAbsent || surahNumber != null) {
      map['surah_number'] = Variable<int>(surahNumber);
    }
    if (!nullToAbsent || ayahNumber != null) {
      map['ayah_number'] = Variable<int>(ayahNumber);
    }
    if (!nullToAbsent || wordPosition != null) {
      map['word_position'] = Variable<int>(wordPosition);
    }
    map['remote_url'] = Variable<String>(remoteUrl);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AudioFilesCompanion toCompanion(bool nullToAbsent) {
    return AudioFilesCompanion(
      audioKey: Value(audioKey),
      audioType: Value(audioType),
      reciterId: reciterId == null && nullToAbsent
          ? const Value.absent()
          : Value(reciterId),
      surahNumber: surahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(surahNumber),
      ayahNumber: ayahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ayahNumber),
      wordPosition: wordPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(wordPosition),
      remoteUrl: Value(remoteUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      downloadedBytes: Value(downloadedBytes),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioFileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioFileRecord(
      audioKey: serializer.fromJson<String>(json['audioKey']),
      audioType: serializer.fromJson<String>(json['audioType']),
      reciterId: serializer.fromJson<int?>(json['reciterId']),
      surahNumber: serializer.fromJson<int?>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int?>(json['ayahNumber']),
      wordPosition: serializer.fromJson<int?>(json['wordPosition']),
      remoteUrl: serializer.fromJson<String>(json['remoteUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      format: serializer.fromJson<String?>(json['format']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'audioKey': serializer.toJson<String>(audioKey),
      'audioType': serializer.toJson<String>(audioType),
      'reciterId': serializer.toJson<int?>(reciterId),
      'surahNumber': serializer.toJson<int?>(surahNumber),
      'ayahNumber': serializer.toJson<int?>(ayahNumber),
      'wordPosition': serializer.toJson<int?>(wordPosition),
      'remoteUrl': serializer.toJson<String>(remoteUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'format': serializer.toJson<String?>(format),
      'fileSize': serializer.toJson<int?>(fileSize),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AudioFileRecord copyWith({
    String? audioKey,
    String? audioType,
    Value<int?> reciterId = const Value.absent(),
    Value<int?> surahNumber = const Value.absent(),
    Value<int?> ayahNumber = const Value.absent(),
    Value<int?> wordPosition = const Value.absent(),
    String? remoteUrl,
    Value<String?> localPath = const Value.absent(),
    Value<String?> format = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    int? downloadedBytes,
    String? status,
    int? updatedAt,
  }) => AudioFileRecord(
    audioKey: audioKey ?? this.audioKey,
    audioType: audioType ?? this.audioType,
    reciterId: reciterId.present ? reciterId.value : this.reciterId,
    surahNumber: surahNumber.present ? surahNumber.value : this.surahNumber,
    ayahNumber: ayahNumber.present ? ayahNumber.value : this.ayahNumber,
    wordPosition: wordPosition.present ? wordPosition.value : this.wordPosition,
    remoteUrl: remoteUrl ?? this.remoteUrl,
    localPath: localPath.present ? localPath.value : this.localPath,
    format: format.present ? format.value : this.format,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AudioFileRecord copyWithCompanion(AudioFilesCompanion data) {
    return AudioFileRecord(
      audioKey: data.audioKey.present ? data.audioKey.value : this.audioKey,
      audioType: data.audioType.present ? data.audioType.value : this.audioType,
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      format: data.format.present ? data.format.value : this.format,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioFileRecord(')
          ..write('audioKey: $audioKey, ')
          ..write('audioType: $audioType, ')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('format: $format, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    audioKey,
    audioType,
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    remoteUrl,
    localPath,
    format,
    fileSize,
    downloadedBytes,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioFileRecord &&
          other.audioKey == this.audioKey &&
          other.audioType == this.audioType &&
          other.reciterId == this.reciterId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.wordPosition == this.wordPosition &&
          other.remoteUrl == this.remoteUrl &&
          other.localPath == this.localPath &&
          other.format == this.format &&
          other.fileSize == this.fileSize &&
          other.downloadedBytes == this.downloadedBytes &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class AudioFilesCompanion extends UpdateCompanion<AudioFileRecord> {
  final Value<String> audioKey;
  final Value<String> audioType;
  final Value<int?> reciterId;
  final Value<int?> surahNumber;
  final Value<int?> ayahNumber;
  final Value<int?> wordPosition;
  final Value<String> remoteUrl;
  final Value<String?> localPath;
  final Value<String?> format;
  final Value<int?> fileSize;
  final Value<int> downloadedBytes;
  final Value<String> status;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AudioFilesCompanion({
    this.audioKey = const Value.absent(),
    this.audioType = const Value.absent(),
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.format = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioFilesCompanion.insert({
    required String audioKey,
    required String audioType,
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    required String remoteUrl,
    this.localPath = const Value.absent(),
    this.format = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : audioKey = Value(audioKey),
       audioType = Value(audioType),
       remoteUrl = Value(remoteUrl),
       updatedAt = Value(updatedAt);
  static Insertable<AudioFileRecord> custom({
    Expression<String>? audioKey,
    Expression<String>? audioType,
    Expression<int>? reciterId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? wordPosition,
    Expression<String>? remoteUrl,
    Expression<String>? localPath,
    Expression<String>? format,
    Expression<int>? fileSize,
    Expression<int>? downloadedBytes,
    Expression<String>? status,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (audioKey != null) 'audio_key': audioKey,
      if (audioType != null) 'audio_type': audioType,
      if (reciterId != null) 'reciter_id': reciterId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (wordPosition != null) 'word_position': wordPosition,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (localPath != null) 'local_path': localPath,
      if (format != null) 'format': format,
      if (fileSize != null) 'file_size': fileSize,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioFilesCompanion copyWith({
    Value<String>? audioKey,
    Value<String>? audioType,
    Value<int?>? reciterId,
    Value<int?>? surahNumber,
    Value<int?>? ayahNumber,
    Value<int?>? wordPosition,
    Value<String>? remoteUrl,
    Value<String?>? localPath,
    Value<String?>? format,
    Value<int?>? fileSize,
    Value<int>? downloadedBytes,
    Value<String>? status,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AudioFilesCompanion(
      audioKey: audioKey ?? this.audioKey,
      audioType: audioType ?? this.audioType,
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      wordPosition: wordPosition ?? this.wordPosition,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (audioKey.present) {
      map['audio_key'] = Variable<String>(audioKey.value);
    }
    if (audioType.present) {
      map['audio_type'] = Variable<String>(audioType.value);
    }
    if (reciterId.present) {
      map['reciter_id'] = Variable<int>(reciterId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesCompanion(')
          ..write('audioKey: $audioKey, ')
          ..write('audioType: $audioType, ')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('format: $format, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AyahTimingsTable extends AyahTimings
    with TableInfo<$AyahTimingsTable, AyahTimingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahTimingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<int> reciterId = GeneratedColumn<int>(
    'reciter_id',
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
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    reciterId,
    surahNumber,
    ayahNumber,
    verseKey,
    startMs,
    endMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_timings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahTimingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterIdMeta);
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
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reciterId, surahNumber, ayahNumber};
  @override
  AyahTimingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahTimingRecord(
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reciter_id'],
      )!,
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
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
    );
  }

  @override
  $AyahTimingsTable createAlias(String alias) {
    return $AyahTimingsTable(attachedDatabase, alias);
  }
}

class AyahTimingRecord extends DataClass
    implements Insertable<AyahTimingRecord> {
  final int reciterId;
  final int surahNumber;
  final int ayahNumber;
  final String verseKey;
  final int startMs;
  final int endMs;
  const AyahTimingRecord({
    required this.reciterId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.startMs,
    required this.endMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reciter_id'] = Variable<int>(reciterId);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['verse_key'] = Variable<String>(verseKey);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    return map;
  }

  AyahTimingsCompanion toCompanion(bool nullToAbsent) {
    return AyahTimingsCompanion(
      reciterId: Value(reciterId),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      verseKey: Value(verseKey),
      startMs: Value(startMs),
      endMs: Value(endMs),
    );
  }

  factory AyahTimingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahTimingRecord(
      reciterId: serializer.fromJson<int>(json['reciterId']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reciterId': serializer.toJson<int>(reciterId),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'verseKey': serializer.toJson<String>(verseKey),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
    };
  }

  AyahTimingRecord copyWith({
    int? reciterId,
    int? surahNumber,
    int? ayahNumber,
    String? verseKey,
    int? startMs,
    int? endMs,
  }) => AyahTimingRecord(
    reciterId: reciterId ?? this.reciterId,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    verseKey: verseKey ?? this.verseKey,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
  );
  AyahTimingRecord copyWithCompanion(AyahTimingsCompanion data) {
    return AyahTimingRecord(
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahTimingRecord(')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(reciterId, surahNumber, ayahNumber, verseKey, startMs, endMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahTimingRecord &&
          other.reciterId == this.reciterId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.verseKey == this.verseKey &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs);
}

class AyahTimingsCompanion extends UpdateCompanion<AyahTimingRecord> {
  final Value<int> reciterId;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> verseKey;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<int> rowid;
  const AyahTimingsCompanion({
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahTimingsCompanion.insert({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
    required String verseKey,
    required int startMs,
    required int endMs,
    this.rowid = const Value.absent(),
  }) : reciterId = Value(reciterId),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       verseKey = Value(verseKey),
       startMs = Value(startMs),
       endMs = Value(endMs);
  static Insertable<AyahTimingRecord> custom({
    Expression<int>? reciterId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? verseKey,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reciterId != null) 'reciter_id': reciterId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (verseKey != null) 'verse_key': verseKey,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahTimingsCompanion copyWith({
    Value<int>? reciterId,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<String>? verseKey,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<int>? rowid,
  }) {
    return AyahTimingsCompanion(
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      verseKey: verseKey ?? this.verseKey,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reciterId.present) {
      map['reciter_id'] = Variable<int>(reciterId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahTimingsCompanion(')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordTimingsTable extends WordTimings
    with TableInfo<$WordTimingsTable, WordTimingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordTimingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<int> reciterId = GeneratedColumn<int>(
    'reciter_id',
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
  static const VerificationMeta _wordPositionMeta = const VerificationMeta(
    'wordPosition',
  );
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
    'word_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    startMs,
    endMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_timings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordTimingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterIdMeta);
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
    if (data.containsKey('word_position')) {
      context.handle(
        _wordPositionMeta,
        wordPosition.isAcceptableOrUnknown(
          data['word_position']!,
          _wordPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordPositionMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
  };
  @override
  WordTimingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordTimingRecord(
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reciter_id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      wordPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_position'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
    );
  }

  @override
  $WordTimingsTable createAlias(String alias) {
    return $WordTimingsTable(attachedDatabase, alias);
  }
}

class WordTimingRecord extends DataClass
    implements Insertable<WordTimingRecord> {
  final int reciterId;
  final int surahNumber;
  final int ayahNumber;
  final int wordPosition;
  final int startMs;
  final int endMs;
  const WordTimingRecord({
    required this.reciterId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordPosition,
    required this.startMs,
    required this.endMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reciter_id'] = Variable<int>(reciterId);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['word_position'] = Variable<int>(wordPosition);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    return map;
  }

  WordTimingsCompanion toCompanion(bool nullToAbsent) {
    return WordTimingsCompanion(
      reciterId: Value(reciterId),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      wordPosition: Value(wordPosition),
      startMs: Value(startMs),
      endMs: Value(endMs),
    );
  }

  factory WordTimingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordTimingRecord(
      reciterId: serializer.fromJson<int>(json['reciterId']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      wordPosition: serializer.fromJson<int>(json['wordPosition']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reciterId': serializer.toJson<int>(reciterId),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'wordPosition': serializer.toJson<int>(wordPosition),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
    };
  }

  WordTimingRecord copyWith({
    int? reciterId,
    int? surahNumber,
    int? ayahNumber,
    int? wordPosition,
    int? startMs,
    int? endMs,
  }) => WordTimingRecord(
    reciterId: reciterId ?? this.reciterId,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    wordPosition: wordPosition ?? this.wordPosition,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
  );
  WordTimingRecord copyWithCompanion(WordTimingsCompanion data) {
    return WordTimingRecord(
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordTimingRecord(')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    startMs,
    endMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordTimingRecord &&
          other.reciterId == this.reciterId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.wordPosition == this.wordPosition &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs);
}

class WordTimingsCompanion extends UpdateCompanion<WordTimingRecord> {
  final Value<int> reciterId;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<int> wordPosition;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<int> rowid;
  const WordTimingsCompanion({
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordTimingsCompanion.insert({
    required int reciterId,
    required int surahNumber,
    required int ayahNumber,
    required int wordPosition,
    required int startMs,
    required int endMs,
    this.rowid = const Value.absent(),
  }) : reciterId = Value(reciterId),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       wordPosition = Value(wordPosition),
       startMs = Value(startMs),
       endMs = Value(endMs);
  static Insertable<WordTimingRecord> custom({
    Expression<int>? reciterId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? wordPosition,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reciterId != null) 'reciter_id': reciterId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (wordPosition != null) 'word_position': wordPosition,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordTimingsCompanion copyWith({
    Value<int>? reciterId,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<int>? wordPosition,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<int>? rowid,
  }) {
    return WordTimingsCompanion(
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      wordPosition: wordPosition ?? this.wordPosition,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reciterId.present) {
      map['reciter_id'] = Variable<int>(reciterId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordTimingsCompanion(')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadJobsTable extends DownloadJobs
    with TableInfo<$DownloadJobsTable, DownloadJobRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _audioKeyMeta = const VerificationMeta(
    'audioKey',
  );
  @override
  late final GeneratedColumn<String> audioKey = GeneratedColumn<String>(
    'audio_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioTypeMeta = const VerificationMeta(
    'audioType',
  );
  @override
  late final GeneratedColumn<String> audioType = GeneratedColumn<String>(
    'audio_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedBytesMeta = const VerificationMeta(
    'expectedBytes',
  );
  @override
  late final GeneratedColumn<int> expectedBytes = GeneratedColumn<int>(
    'expected_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<int> reciterId = GeneratedColumn<int>(
    'reciter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordPositionMeta = const VerificationMeta(
    'wordPosition',
  );
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
    'word_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    audioKey,
    audioType,
    remoteUrl,
    relativePath,
    status,
    downloadedBytes,
    expectedBytes,
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    format,
    localPath,
    errorCode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadJobRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audio_key')) {
      context.handle(
        _audioKeyMeta,
        audioKey.isAcceptableOrUnknown(data['audio_key']!, _audioKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_audioKeyMeta);
    }
    if (data.containsKey('audio_type')) {
      context.handle(
        _audioTypeMeta,
        audioType.isAcceptableOrUnknown(data['audio_type']!, _audioTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_audioTypeMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteUrlMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('expected_bytes')) {
      context.handle(
        _expectedBytesMeta,
        expectedBytes.isAcceptableOrUnknown(
          data['expected_bytes']!,
          _expectedBytesMeta,
        ),
      );
    }
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
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
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    }
    if (data.containsKey('word_position')) {
      context.handle(
        _wordPositionMeta,
        wordPosition.isAcceptableOrUnknown(
          data['word_position']!,
          _wordPositionMeta,
        ),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {audioKey};
  @override
  DownloadJobRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadJobRecord(
      audioKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_key'],
      )!,
      audioType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_type'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      expectedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_bytes'],
      ),
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reciter_id'],
      ),
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      ),
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      ),
      wordPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_position'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadJobsTable createAlias(String alias) {
    return $DownloadJobsTable(attachedDatabase, alias);
  }
}

class DownloadJobRecord extends DataClass
    implements Insertable<DownloadJobRecord> {
  final String audioKey;
  final String audioType;
  final String remoteUrl;
  final String relativePath;
  final String status;
  final int downloadedBytes;
  final int? expectedBytes;
  final int? reciterId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? wordPosition;
  final String? format;
  final String? localPath;
  final String? errorCode;
  final int updatedAt;
  const DownloadJobRecord({
    required this.audioKey,
    required this.audioType,
    required this.remoteUrl,
    required this.relativePath,
    required this.status,
    required this.downloadedBytes,
    this.expectedBytes,
    this.reciterId,
    this.surahNumber,
    this.ayahNumber,
    this.wordPosition,
    this.format,
    this.localPath,
    this.errorCode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audio_key'] = Variable<String>(audioKey);
    map['audio_type'] = Variable<String>(audioType);
    map['remote_url'] = Variable<String>(remoteUrl);
    map['relative_path'] = Variable<String>(relativePath);
    map['status'] = Variable<String>(status);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    if (!nullToAbsent || expectedBytes != null) {
      map['expected_bytes'] = Variable<int>(expectedBytes);
    }
    if (!nullToAbsent || reciterId != null) {
      map['reciter_id'] = Variable<int>(reciterId);
    }
    if (!nullToAbsent || surahNumber != null) {
      map['surah_number'] = Variable<int>(surahNumber);
    }
    if (!nullToAbsent || ayahNumber != null) {
      map['ayah_number'] = Variable<int>(ayahNumber);
    }
    if (!nullToAbsent || wordPosition != null) {
      map['word_position'] = Variable<int>(wordPosition);
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DownloadJobsCompanion toCompanion(bool nullToAbsent) {
    return DownloadJobsCompanion(
      audioKey: Value(audioKey),
      audioType: Value(audioType),
      remoteUrl: Value(remoteUrl),
      relativePath: Value(relativePath),
      status: Value(status),
      downloadedBytes: Value(downloadedBytes),
      expectedBytes: expectedBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedBytes),
      reciterId: reciterId == null && nullToAbsent
          ? const Value.absent()
          : Value(reciterId),
      surahNumber: surahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(surahNumber),
      ayahNumber: ayahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ayahNumber),
      wordPosition: wordPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(wordPosition),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadJobRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadJobRecord(
      audioKey: serializer.fromJson<String>(json['audioKey']),
      audioType: serializer.fromJson<String>(json['audioType']),
      remoteUrl: serializer.fromJson<String>(json['remoteUrl']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      status: serializer.fromJson<String>(json['status']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      expectedBytes: serializer.fromJson<int?>(json['expectedBytes']),
      reciterId: serializer.fromJson<int?>(json['reciterId']),
      surahNumber: serializer.fromJson<int?>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int?>(json['ayahNumber']),
      wordPosition: serializer.fromJson<int?>(json['wordPosition']),
      format: serializer.fromJson<String?>(json['format']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'audioKey': serializer.toJson<String>(audioKey),
      'audioType': serializer.toJson<String>(audioType),
      'remoteUrl': serializer.toJson<String>(remoteUrl),
      'relativePath': serializer.toJson<String>(relativePath),
      'status': serializer.toJson<String>(status),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'expectedBytes': serializer.toJson<int?>(expectedBytes),
      'reciterId': serializer.toJson<int?>(reciterId),
      'surahNumber': serializer.toJson<int?>(surahNumber),
      'ayahNumber': serializer.toJson<int?>(ayahNumber),
      'wordPosition': serializer.toJson<int?>(wordPosition),
      'format': serializer.toJson<String?>(format),
      'localPath': serializer.toJson<String?>(localPath),
      'errorCode': serializer.toJson<String?>(errorCode),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DownloadJobRecord copyWith({
    String? audioKey,
    String? audioType,
    String? remoteUrl,
    String? relativePath,
    String? status,
    int? downloadedBytes,
    Value<int?> expectedBytes = const Value.absent(),
    Value<int?> reciterId = const Value.absent(),
    Value<int?> surahNumber = const Value.absent(),
    Value<int?> ayahNumber = const Value.absent(),
    Value<int?> wordPosition = const Value.absent(),
    Value<String?> format = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    int? updatedAt,
  }) => DownloadJobRecord(
    audioKey: audioKey ?? this.audioKey,
    audioType: audioType ?? this.audioType,
    remoteUrl: remoteUrl ?? this.remoteUrl,
    relativePath: relativePath ?? this.relativePath,
    status: status ?? this.status,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    expectedBytes: expectedBytes.present
        ? expectedBytes.value
        : this.expectedBytes,
    reciterId: reciterId.present ? reciterId.value : this.reciterId,
    surahNumber: surahNumber.present ? surahNumber.value : this.surahNumber,
    ayahNumber: ayahNumber.present ? ayahNumber.value : this.ayahNumber,
    wordPosition: wordPosition.present ? wordPosition.value : this.wordPosition,
    format: format.present ? format.value : this.format,
    localPath: localPath.present ? localPath.value : this.localPath,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadJobRecord copyWithCompanion(DownloadJobsCompanion data) {
    return DownloadJobRecord(
      audioKey: data.audioKey.present ? data.audioKey.value : this.audioKey,
      audioType: data.audioType.present ? data.audioType.value : this.audioType,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      status: data.status.present ? data.status.value : this.status,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      expectedBytes: data.expectedBytes.present
          ? data.expectedBytes.value
          : this.expectedBytes,
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      format: data.format.present ? data.format.value : this.format,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobRecord(')
          ..write('audioKey: $audioKey, ')
          ..write('audioType: $audioType, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('relativePath: $relativePath, ')
          ..write('status: $status, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('expectedBytes: $expectedBytes, ')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('format: $format, ')
          ..write('localPath: $localPath, ')
          ..write('errorCode: $errorCode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    audioKey,
    audioType,
    remoteUrl,
    relativePath,
    status,
    downloadedBytes,
    expectedBytes,
    reciterId,
    surahNumber,
    ayahNumber,
    wordPosition,
    format,
    localPath,
    errorCode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadJobRecord &&
          other.audioKey == this.audioKey &&
          other.audioType == this.audioType &&
          other.remoteUrl == this.remoteUrl &&
          other.relativePath == this.relativePath &&
          other.status == this.status &&
          other.downloadedBytes == this.downloadedBytes &&
          other.expectedBytes == this.expectedBytes &&
          other.reciterId == this.reciterId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.wordPosition == this.wordPosition &&
          other.format == this.format &&
          other.localPath == this.localPath &&
          other.errorCode == this.errorCode &&
          other.updatedAt == this.updatedAt);
}

class DownloadJobsCompanion extends UpdateCompanion<DownloadJobRecord> {
  final Value<String> audioKey;
  final Value<String> audioType;
  final Value<String> remoteUrl;
  final Value<String> relativePath;
  final Value<String> status;
  final Value<int> downloadedBytes;
  final Value<int?> expectedBytes;
  final Value<int?> reciterId;
  final Value<int?> surahNumber;
  final Value<int?> ayahNumber;
  final Value<int?> wordPosition;
  final Value<String?> format;
  final Value<String?> localPath;
  final Value<String?> errorCode;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DownloadJobsCompanion({
    this.audioKey = const Value.absent(),
    this.audioType = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.expectedBytes = const Value.absent(),
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.format = const Value.absent(),
    this.localPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadJobsCompanion.insert({
    required String audioKey,
    required String audioType,
    required String remoteUrl,
    required String relativePath,
    required String status,
    this.downloadedBytes = const Value.absent(),
    this.expectedBytes = const Value.absent(),
    this.reciterId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.format = const Value.absent(),
    this.localPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : audioKey = Value(audioKey),
       audioType = Value(audioType),
       remoteUrl = Value(remoteUrl),
       relativePath = Value(relativePath),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadJobRecord> custom({
    Expression<String>? audioKey,
    Expression<String>? audioType,
    Expression<String>? remoteUrl,
    Expression<String>? relativePath,
    Expression<String>? status,
    Expression<int>? downloadedBytes,
    Expression<int>? expectedBytes,
    Expression<int>? reciterId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? wordPosition,
    Expression<String>? format,
    Expression<String>? localPath,
    Expression<String>? errorCode,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (audioKey != null) 'audio_key': audioKey,
      if (audioType != null) 'audio_type': audioType,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (relativePath != null) 'relative_path': relativePath,
      if (status != null) 'status': status,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (expectedBytes != null) 'expected_bytes': expectedBytes,
      if (reciterId != null) 'reciter_id': reciterId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (wordPosition != null) 'word_position': wordPosition,
      if (format != null) 'format': format,
      if (localPath != null) 'local_path': localPath,
      if (errorCode != null) 'error_code': errorCode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadJobsCompanion copyWith({
    Value<String>? audioKey,
    Value<String>? audioType,
    Value<String>? remoteUrl,
    Value<String>? relativePath,
    Value<String>? status,
    Value<int>? downloadedBytes,
    Value<int?>? expectedBytes,
    Value<int?>? reciterId,
    Value<int?>? surahNumber,
    Value<int?>? ayahNumber,
    Value<int?>? wordPosition,
    Value<String?>? format,
    Value<String?>? localPath,
    Value<String?>? errorCode,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadJobsCompanion(
      audioKey: audioKey ?? this.audioKey,
      audioType: audioType ?? this.audioType,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      relativePath: relativePath ?? this.relativePath,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      expectedBytes: expectedBytes ?? this.expectedBytes,
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      wordPosition: wordPosition ?? this.wordPosition,
      format: format ?? this.format,
      localPath: localPath ?? this.localPath,
      errorCode: errorCode ?? this.errorCode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (audioKey.present) {
      map['audio_key'] = Variable<String>(audioKey.value);
    }
    if (audioType.present) {
      map['audio_type'] = Variable<String>(audioType.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (expectedBytes.present) {
      map['expected_bytes'] = Variable<int>(expectedBytes.value);
    }
    if (reciterId.present) {
      map['reciter_id'] = Variable<int>(reciterId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobsCompanion(')
          ..write('audioKey: $audioKey, ')
          ..write('audioType: $audioType, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('relativePath: $relativePath, ')
          ..write('status: $status, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('expectedBytes: $expectedBytes, ')
          ..write('reciterId: $reciterId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('format: $format, ')
          ..write('localPath: $localPath, ')
          ..write('errorCode: $errorCode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HifzProgressEntriesTable extends HifzProgressEntries
    with TableInfo<$HifzProgressEntriesTable, HifzProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HifzProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthScoreMeta = const VerificationMeta(
    'strengthScore',
  );
  @override
  late final GeneratedColumn<int> strengthScore = GeneratedColumn<int>(
    'strength_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mistakeCountMeta = const VerificationMeta(
    'mistakeCount',
  );
  @override
  late final GeneratedColumn<int> mistakeCount = GeneratedColumn<int>(
    'mistake_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionIntervalIndexMeta =
      const VerificationMeta('revisionIntervalIndex');
  @override
  late final GeneratedColumn<int> revisionIntervalIndex = GeneratedColumn<int>(
    'revision_interval_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memorizedAtMeta = const VerificationMeta(
    'memorizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> memorizedAt = GeneratedColumn<DateTime>(
    'memorized_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    surahNumber,
    ayahNumber,
    status,
    strengthScore,
    reviewCount,
    mistakeCount,
    revisionIntervalIndex,
    startedAt,
    memorizedAt,
    lastReviewedAt,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hifz_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HifzProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('strength_score')) {
      context.handle(
        _strengthScoreMeta,
        strengthScore.isAcceptableOrUnknown(
          data['strength_score']!,
          _strengthScoreMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    if (data.containsKey('mistake_count')) {
      context.handle(
        _mistakeCountMeta,
        mistakeCount.isAcceptableOrUnknown(
          data['mistake_count']!,
          _mistakeCountMeta,
        ),
      );
    }
    if (data.containsKey('revision_interval_index')) {
      context.handle(
        _revisionIntervalIndexMeta,
        revisionIntervalIndex.isAcceptableOrUnknown(
          data['revision_interval_index']!,
          _revisionIntervalIndexMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('memorized_at')) {
      context.handle(
        _memorizedAtMeta,
        memorizedAt.isAcceptableOrUnknown(
          data['memorized_at']!,
          _memorizedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey, surahNumber, ayahNumber};
  @override
  HifzProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HifzProgressRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      strengthScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strength_score'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      mistakeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistake_count'],
      )!,
      revisionIntervalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_interval_index'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      memorizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}memorized_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
    );
  }

  @override
  $HifzProgressEntriesTable createAlias(String alias) {
    return $HifzProgressEntriesTable(attachedDatabase, alias);
  }
}

class HifzProgressRow extends DataClass implements Insertable<HifzProgressRow> {
  final String profileKey;
  final int surahNumber;
  final int ayahNumber;
  final String status;
  final int strengthScore;
  final int reviewCount;
  final int mistakeCount;
  final int revisionIntervalIndex;
  final DateTime? startedAt;
  final DateTime? memorizedAt;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  const HifzProgressRow({
    required this.profileKey,
    required this.surahNumber,
    required this.ayahNumber,
    required this.status,
    required this.strengthScore,
    required this.reviewCount,
    required this.mistakeCount,
    required this.revisionIntervalIndex,
    this.startedAt,
    this.memorizedAt,
    this.lastReviewedAt,
    this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['status'] = Variable<String>(status);
    map['strength_score'] = Variable<int>(strengthScore);
    map['review_count'] = Variable<int>(reviewCount);
    map['mistake_count'] = Variable<int>(mistakeCount);
    map['revision_interval_index'] = Variable<int>(revisionIntervalIndex);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || memorizedAt != null) {
      map['memorized_at'] = Variable<DateTime>(memorizedAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    return map;
  }

  HifzProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return HifzProgressEntriesCompanion(
      profileKey: Value(profileKey),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      status: Value(status),
      strengthScore: Value(strengthScore),
      reviewCount: Value(reviewCount),
      mistakeCount: Value(mistakeCount),
      revisionIntervalIndex: Value(revisionIntervalIndex),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      memorizedAt: memorizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(memorizedAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
    );
  }

  factory HifzProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HifzProgressRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      status: serializer.fromJson<String>(json['status']),
      strengthScore: serializer.fromJson<int>(json['strengthScore']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      mistakeCount: serializer.fromJson<int>(json['mistakeCount']),
      revisionIntervalIndex: serializer.fromJson<int>(
        json['revisionIntervalIndex'],
      ),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      memorizedAt: serializer.fromJson<DateTime?>(json['memorizedAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'status': serializer.toJson<String>(status),
      'strengthScore': serializer.toJson<int>(strengthScore),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'mistakeCount': serializer.toJson<int>(mistakeCount),
      'revisionIntervalIndex': serializer.toJson<int>(revisionIntervalIndex),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'memorizedAt': serializer.toJson<DateTime?>(memorizedAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
    };
  }

  HifzProgressRow copyWith({
    String? profileKey,
    int? surahNumber,
    int? ayahNumber,
    String? status,
    int? strengthScore,
    int? reviewCount,
    int? mistakeCount,
    int? revisionIntervalIndex,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> memorizedAt = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<DateTime?> nextReviewAt = const Value.absent(),
  }) => HifzProgressRow(
    profileKey: profileKey ?? this.profileKey,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    status: status ?? this.status,
    strengthScore: strengthScore ?? this.strengthScore,
    reviewCount: reviewCount ?? this.reviewCount,
    mistakeCount: mistakeCount ?? this.mistakeCount,
    revisionIntervalIndex: revisionIntervalIndex ?? this.revisionIntervalIndex,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    memorizedAt: memorizedAt.present ? memorizedAt.value : this.memorizedAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
  );
  HifzProgressRow copyWithCompanion(HifzProgressEntriesCompanion data) {
    return HifzProgressRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      status: data.status.present ? data.status.value : this.status,
      strengthScore: data.strengthScore.present
          ? data.strengthScore.value
          : this.strengthScore,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      mistakeCount: data.mistakeCount.present
          ? data.mistakeCount.value
          : this.mistakeCount,
      revisionIntervalIndex: data.revisionIntervalIndex.present
          ? data.revisionIntervalIndex.value
          : this.revisionIntervalIndex,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      memorizedAt: data.memorizedAt.present
          ? data.memorizedAt.value
          : this.memorizedAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HifzProgressRow(')
          ..write('profileKey: $profileKey, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('status: $status, ')
          ..write('strengthScore: $strengthScore, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('mistakeCount: $mistakeCount, ')
          ..write('revisionIntervalIndex: $revisionIntervalIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('memorizedAt: $memorizedAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    surahNumber,
    ayahNumber,
    status,
    strengthScore,
    reviewCount,
    mistakeCount,
    revisionIntervalIndex,
    startedAt,
    memorizedAt,
    lastReviewedAt,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HifzProgressRow &&
          other.profileKey == this.profileKey &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.status == this.status &&
          other.strengthScore == this.strengthScore &&
          other.reviewCount == this.reviewCount &&
          other.mistakeCount == this.mistakeCount &&
          other.revisionIntervalIndex == this.revisionIntervalIndex &&
          other.startedAt == this.startedAt &&
          other.memorizedAt == this.memorizedAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt);
}

class HifzProgressEntriesCompanion extends UpdateCompanion<HifzProgressRow> {
  final Value<String> profileKey;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> status;
  final Value<int> strengthScore;
  final Value<int> reviewCount;
  final Value<int> mistakeCount;
  final Value<int> revisionIntervalIndex;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> memorizedAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> nextReviewAt;
  final Value<int> rowid;
  const HifzProgressEntriesCompanion({
    this.profileKey = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.strengthScore = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.mistakeCount = const Value.absent(),
    this.revisionIntervalIndex = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.memorizedAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HifzProgressEntriesCompanion.insert({
    required String profileKey,
    required int surahNumber,
    required int ayahNumber,
    required String status,
    this.strengthScore = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.mistakeCount = const Value.absent(),
    this.revisionIntervalIndex = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.memorizedAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       status = Value(status);
  static Insertable<HifzProgressRow> custom({
    Expression<String>? profileKey,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? status,
    Expression<int>? strengthScore,
    Expression<int>? reviewCount,
    Expression<int>? mistakeCount,
    Expression<int>? revisionIntervalIndex,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? memorizedAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (status != null) 'status': status,
      if (strengthScore != null) 'strength_score': strengthScore,
      if (reviewCount != null) 'review_count': reviewCount,
      if (mistakeCount != null) 'mistake_count': mistakeCount,
      if (revisionIntervalIndex != null)
        'revision_interval_index': revisionIntervalIndex,
      if (startedAt != null) 'started_at': startedAt,
      if (memorizedAt != null) 'memorized_at': memorizedAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HifzProgressEntriesCompanion copyWith({
    Value<String>? profileKey,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<String>? status,
    Value<int>? strengthScore,
    Value<int>? reviewCount,
    Value<int>? mistakeCount,
    Value<int>? revisionIntervalIndex,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? memorizedAt,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? nextReviewAt,
    Value<int>? rowid,
  }) {
    return HifzProgressEntriesCompanion(
      profileKey: profileKey ?? this.profileKey,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      status: status ?? this.status,
      strengthScore: strengthScore ?? this.strengthScore,
      reviewCount: reviewCount ?? this.reviewCount,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      revisionIntervalIndex:
          revisionIntervalIndex ?? this.revisionIntervalIndex,
      startedAt: startedAt ?? this.startedAt,
      memorizedAt: memorizedAt ?? this.memorizedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (strengthScore.present) {
      map['strength_score'] = Variable<int>(strengthScore.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (mistakeCount.present) {
      map['mistake_count'] = Variable<int>(mistakeCount.value);
    }
    if (revisionIntervalIndex.present) {
      map['revision_interval_index'] = Variable<int>(
        revisionIntervalIndex.value,
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (memorizedAt.present) {
      map['memorized_at'] = Variable<DateTime>(memorizedAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HifzProgressEntriesCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('status: $status, ')
          ..write('strengthScore: $strengthScore, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('mistakeCount: $mistakeCount, ')
          ..write('revisionIntervalIndex: $revisionIntervalIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('memorizedAt: $memorizedAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HifzReviewHistoryRowsTable extends HifzReviewHistoryRows
    with TableInfo<$HifzReviewHistoryRowsTable, HifzReviewHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HifzReviewHistoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStatusMeta = const VerificationMeta(
    'previousStatus',
  );
  @override
  late final GeneratedColumn<String> previousStatus = GeneratedColumn<String>(
    'previous_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStatusMeta = const VerificationMeta(
    'newStatus',
  );
  @override
  late final GeneratedColumn<String> newStatus = GeneratedColumn<String>(
    'new_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousIntervalIndexMeta =
      const VerificationMeta('previousIntervalIndex');
  @override
  late final GeneratedColumn<int> previousIntervalIndex = GeneratedColumn<int>(
    'previous_interval_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newIntervalIndexMeta = const VerificationMeta(
    'newIntervalIndex',
  );
  @override
  late final GeneratedColumn<int> newIntervalIndex = GeneratedColumn<int>(
    'new_interval_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStrengthScoreMeta =
      const VerificationMeta('previousStrengthScore');
  @override
  late final GeneratedColumn<int> previousStrengthScore = GeneratedColumn<int>(
    'previous_strength_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStrengthScoreMeta = const VerificationMeta(
    'newStrengthScore',
  );
  @override
  late final GeneratedColumn<int> newStrengthScore = GeneratedColumn<int>(
    'new_strength_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileKey,
    surahNumber,
    ayahNumber,
    reviewedAt,
    result,
    previousStatus,
    newStatus,
    previousIntervalIndex,
    newIntervalIndex,
    previousStrengthScore,
    newStrengthScore,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hifz_review_history_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<HifzReviewHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
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
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('previous_status')) {
      context.handle(
        _previousStatusMeta,
        previousStatus.isAcceptableOrUnknown(
          data['previous_status']!,
          _previousStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStatusMeta);
    }
    if (data.containsKey('new_status')) {
      context.handle(
        _newStatusMeta,
        newStatus.isAcceptableOrUnknown(data['new_status']!, _newStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_newStatusMeta);
    }
    if (data.containsKey('previous_interval_index')) {
      context.handle(
        _previousIntervalIndexMeta,
        previousIntervalIndex.isAcceptableOrUnknown(
          data['previous_interval_index']!,
          _previousIntervalIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousIntervalIndexMeta);
    }
    if (data.containsKey('new_interval_index')) {
      context.handle(
        _newIntervalIndexMeta,
        newIntervalIndex.isAcceptableOrUnknown(
          data['new_interval_index']!,
          _newIntervalIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newIntervalIndexMeta);
    }
    if (data.containsKey('previous_strength_score')) {
      context.handle(
        _previousStrengthScoreMeta,
        previousStrengthScore.isAcceptableOrUnknown(
          data['previous_strength_score']!,
          _previousStrengthScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStrengthScoreMeta);
    }
    if (data.containsKey('new_strength_score')) {
      context.handle(
        _newStrengthScoreMeta,
        newStrengthScore.isAcceptableOrUnknown(
          data['new_strength_score']!,
          _newStrengthScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newStrengthScoreMeta);
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HifzReviewHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HifzReviewHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      previousStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_status'],
      )!,
      newStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_status'],
      )!,
      previousIntervalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_interval_index'],
      )!,
      newIntervalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_interval_index'],
      )!,
      previousStrengthScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_strength_score'],
      )!,
      newStrengthScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_strength_score'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
    );
  }

  @override
  $HifzReviewHistoryRowsTable createAlias(String alias) {
    return $HifzReviewHistoryRowsTable(attachedDatabase, alias);
  }
}

class HifzReviewHistoryRow extends DataClass
    implements Insertable<HifzReviewHistoryRow> {
  final int id;
  final String profileKey;
  final int surahNumber;
  final int ayahNumber;
  final DateTime reviewedAt;
  final String result;
  final String previousStatus;
  final String newStatus;
  final int previousIntervalIndex;
  final int newIntervalIndex;
  final int previousStrengthScore;
  final int newStrengthScore;
  final DateTime nextReviewAt;
  const HifzReviewHistoryRow({
    required this.id,
    required this.profileKey,
    required this.surahNumber,
    required this.ayahNumber,
    required this.reviewedAt,
    required this.result,
    required this.previousStatus,
    required this.newStatus,
    required this.previousIntervalIndex,
    required this.newIntervalIndex,
    required this.previousStrengthScore,
    required this.newStrengthScore,
    required this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_key'] = Variable<String>(profileKey);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['result'] = Variable<String>(result);
    map['previous_status'] = Variable<String>(previousStatus);
    map['new_status'] = Variable<String>(newStatus);
    map['previous_interval_index'] = Variable<int>(previousIntervalIndex);
    map['new_interval_index'] = Variable<int>(newIntervalIndex);
    map['previous_strength_score'] = Variable<int>(previousStrengthScore);
    map['new_strength_score'] = Variable<int>(newStrengthScore);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    return map;
  }

  HifzReviewHistoryRowsCompanion toCompanion(bool nullToAbsent) {
    return HifzReviewHistoryRowsCompanion(
      id: Value(id),
      profileKey: Value(profileKey),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      reviewedAt: Value(reviewedAt),
      result: Value(result),
      previousStatus: Value(previousStatus),
      newStatus: Value(newStatus),
      previousIntervalIndex: Value(previousIntervalIndex),
      newIntervalIndex: Value(newIntervalIndex),
      previousStrengthScore: Value(previousStrengthScore),
      newStrengthScore: Value(newStrengthScore),
      nextReviewAt: Value(nextReviewAt),
    );
  }

  factory HifzReviewHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HifzReviewHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      profileKey: serializer.fromJson<String>(json['profileKey']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      result: serializer.fromJson<String>(json['result']),
      previousStatus: serializer.fromJson<String>(json['previousStatus']),
      newStatus: serializer.fromJson<String>(json['newStatus']),
      previousIntervalIndex: serializer.fromJson<int>(
        json['previousIntervalIndex'],
      ),
      newIntervalIndex: serializer.fromJson<int>(json['newIntervalIndex']),
      previousStrengthScore: serializer.fromJson<int>(
        json['previousStrengthScore'],
      ),
      newStrengthScore: serializer.fromJson<int>(json['newStrengthScore']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileKey': serializer.toJson<String>(profileKey),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'result': serializer.toJson<String>(result),
      'previousStatus': serializer.toJson<String>(previousStatus),
      'newStatus': serializer.toJson<String>(newStatus),
      'previousIntervalIndex': serializer.toJson<int>(previousIntervalIndex),
      'newIntervalIndex': serializer.toJson<int>(newIntervalIndex),
      'previousStrengthScore': serializer.toJson<int>(previousStrengthScore),
      'newStrengthScore': serializer.toJson<int>(newStrengthScore),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
    };
  }

  HifzReviewHistoryRow copyWith({
    int? id,
    String? profileKey,
    int? surahNumber,
    int? ayahNumber,
    DateTime? reviewedAt,
    String? result,
    String? previousStatus,
    String? newStatus,
    int? previousIntervalIndex,
    int? newIntervalIndex,
    int? previousStrengthScore,
    int? newStrengthScore,
    DateTime? nextReviewAt,
  }) => HifzReviewHistoryRow(
    id: id ?? this.id,
    profileKey: profileKey ?? this.profileKey,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    result: result ?? this.result,
    previousStatus: previousStatus ?? this.previousStatus,
    newStatus: newStatus ?? this.newStatus,
    previousIntervalIndex: previousIntervalIndex ?? this.previousIntervalIndex,
    newIntervalIndex: newIntervalIndex ?? this.newIntervalIndex,
    previousStrengthScore: previousStrengthScore ?? this.previousStrengthScore,
    newStrengthScore: newStrengthScore ?? this.newStrengthScore,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
  HifzReviewHistoryRow copyWithCompanion(HifzReviewHistoryRowsCompanion data) {
    return HifzReviewHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      result: data.result.present ? data.result.value : this.result,
      previousStatus: data.previousStatus.present
          ? data.previousStatus.value
          : this.previousStatus,
      newStatus: data.newStatus.present ? data.newStatus.value : this.newStatus,
      previousIntervalIndex: data.previousIntervalIndex.present
          ? data.previousIntervalIndex.value
          : this.previousIntervalIndex,
      newIntervalIndex: data.newIntervalIndex.present
          ? data.newIntervalIndex.value
          : this.newIntervalIndex,
      previousStrengthScore: data.previousStrengthScore.present
          ? data.previousStrengthScore.value
          : this.previousStrengthScore,
      newStrengthScore: data.newStrengthScore.present
          ? data.newStrengthScore.value
          : this.newStrengthScore,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HifzReviewHistoryRow(')
          ..write('id: $id, ')
          ..write('profileKey: $profileKey, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('result: $result, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('previousIntervalIndex: $previousIntervalIndex, ')
          ..write('newIntervalIndex: $newIntervalIndex, ')
          ..write('previousStrengthScore: $previousStrengthScore, ')
          ..write('newStrengthScore: $newStrengthScore, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileKey,
    surahNumber,
    ayahNumber,
    reviewedAt,
    result,
    previousStatus,
    newStatus,
    previousIntervalIndex,
    newIntervalIndex,
    previousStrengthScore,
    newStrengthScore,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HifzReviewHistoryRow &&
          other.id == this.id &&
          other.profileKey == this.profileKey &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.reviewedAt == this.reviewedAt &&
          other.result == this.result &&
          other.previousStatus == this.previousStatus &&
          other.newStatus == this.newStatus &&
          other.previousIntervalIndex == this.previousIntervalIndex &&
          other.newIntervalIndex == this.newIntervalIndex &&
          other.previousStrengthScore == this.previousStrengthScore &&
          other.newStrengthScore == this.newStrengthScore &&
          other.nextReviewAt == this.nextReviewAt);
}

class HifzReviewHistoryRowsCompanion
    extends UpdateCompanion<HifzReviewHistoryRow> {
  final Value<int> id;
  final Value<String> profileKey;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<DateTime> reviewedAt;
  final Value<String> result;
  final Value<String> previousStatus;
  final Value<String> newStatus;
  final Value<int> previousIntervalIndex;
  final Value<int> newIntervalIndex;
  final Value<int> previousStrengthScore;
  final Value<int> newStrengthScore;
  final Value<DateTime> nextReviewAt;
  const HifzReviewHistoryRowsCompanion({
    this.id = const Value.absent(),
    this.profileKey = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.result = const Value.absent(),
    this.previousStatus = const Value.absent(),
    this.newStatus = const Value.absent(),
    this.previousIntervalIndex = const Value.absent(),
    this.newIntervalIndex = const Value.absent(),
    this.previousStrengthScore = const Value.absent(),
    this.newStrengthScore = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
  });
  HifzReviewHistoryRowsCompanion.insert({
    this.id = const Value.absent(),
    required String profileKey,
    required int surahNumber,
    required int ayahNumber,
    required DateTime reviewedAt,
    required String result,
    required String previousStatus,
    required String newStatus,
    required int previousIntervalIndex,
    required int newIntervalIndex,
    required int previousStrengthScore,
    required int newStrengthScore,
    required DateTime nextReviewAt,
  }) : profileKey = Value(profileKey),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       reviewedAt = Value(reviewedAt),
       result = Value(result),
       previousStatus = Value(previousStatus),
       newStatus = Value(newStatus),
       previousIntervalIndex = Value(previousIntervalIndex),
       newIntervalIndex = Value(newIntervalIndex),
       previousStrengthScore = Value(previousStrengthScore),
       newStrengthScore = Value(newStrengthScore),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<HifzReviewHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? profileKey,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<DateTime>? reviewedAt,
    Expression<String>? result,
    Expression<String>? previousStatus,
    Expression<String>? newStatus,
    Expression<int>? previousIntervalIndex,
    Expression<int>? newIntervalIndex,
    Expression<int>? previousStrengthScore,
    Expression<int>? newStrengthScore,
    Expression<DateTime>? nextReviewAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileKey != null) 'profile_key': profileKey,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (result != null) 'result': result,
      if (previousStatus != null) 'previous_status': previousStatus,
      if (newStatus != null) 'new_status': newStatus,
      if (previousIntervalIndex != null)
        'previous_interval_index': previousIntervalIndex,
      if (newIntervalIndex != null) 'new_interval_index': newIntervalIndex,
      if (previousStrengthScore != null)
        'previous_strength_score': previousStrengthScore,
      if (newStrengthScore != null) 'new_strength_score': newStrengthScore,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
    });
  }

  HifzReviewHistoryRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? profileKey,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<DateTime>? reviewedAt,
    Value<String>? result,
    Value<String>? previousStatus,
    Value<String>? newStatus,
    Value<int>? previousIntervalIndex,
    Value<int>? newIntervalIndex,
    Value<int>? previousStrengthScore,
    Value<int>? newStrengthScore,
    Value<DateTime>? nextReviewAt,
  }) {
    return HifzReviewHistoryRowsCompanion(
      id: id ?? this.id,
      profileKey: profileKey ?? this.profileKey,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      result: result ?? this.result,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      previousIntervalIndex:
          previousIntervalIndex ?? this.previousIntervalIndex,
      newIntervalIndex: newIntervalIndex ?? this.newIntervalIndex,
      previousStrengthScore:
          previousStrengthScore ?? this.previousStrengthScore,
      newStrengthScore: newStrengthScore ?? this.newStrengthScore,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (previousStatus.present) {
      map['previous_status'] = Variable<String>(previousStatus.value);
    }
    if (newStatus.present) {
      map['new_status'] = Variable<String>(newStatus.value);
    }
    if (previousIntervalIndex.present) {
      map['previous_interval_index'] = Variable<int>(
        previousIntervalIndex.value,
      );
    }
    if (newIntervalIndex.present) {
      map['new_interval_index'] = Variable<int>(newIntervalIndex.value);
    }
    if (previousStrengthScore.present) {
      map['previous_strength_score'] = Variable<int>(
        previousStrengthScore.value,
      );
    }
    if (newStrengthScore.present) {
      map['new_strength_score'] = Variable<int>(newStrengthScore.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HifzReviewHistoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('profileKey: $profileKey, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('result: $result, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('previousIntervalIndex: $previousIntervalIndex, ')
          ..write('newIntervalIndex: $newIntervalIndex, ')
          ..write('previousStrengthScore: $previousStrengthScore, ')
          ..write('newStrengthScore: $newStrengthScore, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }
}

class $HifzSessionCheckpointsTable extends HifzSessionCheckpoints
    with TableInfo<$HifzSessionCheckpointsTable, HifzSessionCheckpointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HifzSessionCheckpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSurahMeta = const VerificationMeta(
    'startSurah',
  );
  @override
  late final GeneratedColumn<int> startSurah = GeneratedColumn<int>(
    'start_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAyahMeta = const VerificationMeta(
    'startAyah',
  );
  @override
  late final GeneratedColumn<int> startAyah = GeneratedColumn<int>(
    'start_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endSurahMeta = const VerificationMeta(
    'endSurah',
  );
  @override
  late final GeneratedColumn<int> endSurah = GeneratedColumn<int>(
    'end_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAyahMeta = const VerificationMeta(
    'endAyah',
  );
  @override
  late final GeneratedColumn<int> endAyah = GeneratedColumn<int>(
    'end_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextStepIndexMeta = const VerificationMeta(
    'nextStepIndex',
  );
  @override
  late final GeneratedColumn<int> nextStepIndex = GeneratedColumn<int>(
    'next_step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    presetId,
    nextStepIndex,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hifz_session_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<HifzSessionCheckpointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('start_surah')) {
      context.handle(
        _startSurahMeta,
        startSurah.isAcceptableOrUnknown(data['start_surah']!, _startSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_startSurahMeta);
    }
    if (data.containsKey('start_ayah')) {
      context.handle(
        _startAyahMeta,
        startAyah.isAcceptableOrUnknown(data['start_ayah']!, _startAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_startAyahMeta);
    }
    if (data.containsKey('end_surah')) {
      context.handle(
        _endSurahMeta,
        endSurah.isAcceptableOrUnknown(data['end_surah']!, _endSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_endSurahMeta);
    }
    if (data.containsKey('end_ayah')) {
      context.handle(
        _endAyahMeta,
        endAyah.isAcceptableOrUnknown(data['end_ayah']!, _endAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_endAyahMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('next_step_index')) {
      context.handle(
        _nextStepIndexMeta,
        nextStepIndex.isAcceptableOrUnknown(
          data['next_step_index']!,
          _nextStepIndexMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey};
  @override
  HifzSessionCheckpointRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HifzSessionCheckpointRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      startSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_surah'],
      )!,
      startAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ayah'],
      )!,
      endSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_surah'],
      )!,
      endAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ayah'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      nextStepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_step_index'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HifzSessionCheckpointsTable createAlias(String alias) {
    return $HifzSessionCheckpointsTable(attachedDatabase, alias);
  }
}

class HifzSessionCheckpointRow extends DataClass
    implements Insertable<HifzSessionCheckpointRow> {
  final String profileKey;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final String presetId;
  final int nextStepIndex;
  final String status;
  final DateTime updatedAt;
  const HifzSessionCheckpointRow({
    required this.profileKey,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.presetId,
    required this.nextStepIndex,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['start_surah'] = Variable<int>(startSurah);
    map['start_ayah'] = Variable<int>(startAyah);
    map['end_surah'] = Variable<int>(endSurah);
    map['end_ayah'] = Variable<int>(endAyah);
    map['preset_id'] = Variable<String>(presetId);
    map['next_step_index'] = Variable<int>(nextStepIndex);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HifzSessionCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return HifzSessionCheckpointsCompanion(
      profileKey: Value(profileKey),
      startSurah: Value(startSurah),
      startAyah: Value(startAyah),
      endSurah: Value(endSurah),
      endAyah: Value(endAyah),
      presetId: Value(presetId),
      nextStepIndex: Value(nextStepIndex),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory HifzSessionCheckpointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HifzSessionCheckpointRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      startSurah: serializer.fromJson<int>(json['startSurah']),
      startAyah: serializer.fromJson<int>(json['startAyah']),
      endSurah: serializer.fromJson<int>(json['endSurah']),
      endAyah: serializer.fromJson<int>(json['endAyah']),
      presetId: serializer.fromJson<String>(json['presetId']),
      nextStepIndex: serializer.fromJson<int>(json['nextStepIndex']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'startSurah': serializer.toJson<int>(startSurah),
      'startAyah': serializer.toJson<int>(startAyah),
      'endSurah': serializer.toJson<int>(endSurah),
      'endAyah': serializer.toJson<int>(endAyah),
      'presetId': serializer.toJson<String>(presetId),
      'nextStepIndex': serializer.toJson<int>(nextStepIndex),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HifzSessionCheckpointRow copyWith({
    String? profileKey,
    int? startSurah,
    int? startAyah,
    int? endSurah,
    int? endAyah,
    String? presetId,
    int? nextStepIndex,
    String? status,
    DateTime? updatedAt,
  }) => HifzSessionCheckpointRow(
    profileKey: profileKey ?? this.profileKey,
    startSurah: startSurah ?? this.startSurah,
    startAyah: startAyah ?? this.startAyah,
    endSurah: endSurah ?? this.endSurah,
    endAyah: endAyah ?? this.endAyah,
    presetId: presetId ?? this.presetId,
    nextStepIndex: nextStepIndex ?? this.nextStepIndex,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HifzSessionCheckpointRow copyWithCompanion(
    HifzSessionCheckpointsCompanion data,
  ) {
    return HifzSessionCheckpointRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      startSurah: data.startSurah.present
          ? data.startSurah.value
          : this.startSurah,
      startAyah: data.startAyah.present ? data.startAyah.value : this.startAyah,
      endSurah: data.endSurah.present ? data.endSurah.value : this.endSurah,
      endAyah: data.endAyah.present ? data.endAyah.value : this.endAyah,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      nextStepIndex: data.nextStepIndex.present
          ? data.nextStepIndex.value
          : this.nextStepIndex,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HifzSessionCheckpointRow(')
          ..write('profileKey: $profileKey, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('presetId: $presetId, ')
          ..write('nextStepIndex: $nextStepIndex, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    presetId,
    nextStepIndex,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HifzSessionCheckpointRow &&
          other.profileKey == this.profileKey &&
          other.startSurah == this.startSurah &&
          other.startAyah == this.startAyah &&
          other.endSurah == this.endSurah &&
          other.endAyah == this.endAyah &&
          other.presetId == this.presetId &&
          other.nextStepIndex == this.nextStepIndex &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class HifzSessionCheckpointsCompanion
    extends UpdateCompanion<HifzSessionCheckpointRow> {
  final Value<String> profileKey;
  final Value<int> startSurah;
  final Value<int> startAyah;
  final Value<int> endSurah;
  final Value<int> endAyah;
  final Value<String> presetId;
  final Value<int> nextStepIndex;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HifzSessionCheckpointsCompanion({
    this.profileKey = const Value.absent(),
    this.startSurah = const Value.absent(),
    this.startAyah = const Value.absent(),
    this.endSurah = const Value.absent(),
    this.endAyah = const Value.absent(),
    this.presetId = const Value.absent(),
    this.nextStepIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HifzSessionCheckpointsCompanion.insert({
    required String profileKey,
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
    required String presetId,
    this.nextStepIndex = const Value.absent(),
    required String status,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       startSurah = Value(startSurah),
       startAyah = Value(startAyah),
       endSurah = Value(endSurah),
       endAyah = Value(endAyah),
       presetId = Value(presetId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<HifzSessionCheckpointRow> custom({
    Expression<String>? profileKey,
    Expression<int>? startSurah,
    Expression<int>? startAyah,
    Expression<int>? endSurah,
    Expression<int>? endAyah,
    Expression<String>? presetId,
    Expression<int>? nextStepIndex,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (startSurah != null) 'start_surah': startSurah,
      if (startAyah != null) 'start_ayah': startAyah,
      if (endSurah != null) 'end_surah': endSurah,
      if (endAyah != null) 'end_ayah': endAyah,
      if (presetId != null) 'preset_id': presetId,
      if (nextStepIndex != null) 'next_step_index': nextStepIndex,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HifzSessionCheckpointsCompanion copyWith({
    Value<String>? profileKey,
    Value<int>? startSurah,
    Value<int>? startAyah,
    Value<int>? endSurah,
    Value<int>? endAyah,
    Value<String>? presetId,
    Value<int>? nextStepIndex,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HifzSessionCheckpointsCompanion(
      profileKey: profileKey ?? this.profileKey,
      startSurah: startSurah ?? this.startSurah,
      startAyah: startAyah ?? this.startAyah,
      endSurah: endSurah ?? this.endSurah,
      endAyah: endAyah ?? this.endAyah,
      presetId: presetId ?? this.presetId,
      nextStepIndex: nextStepIndex ?? this.nextStepIndex,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (startSurah.present) {
      map['start_surah'] = Variable<int>(startSurah.value);
    }
    if (startAyah.present) {
      map['start_ayah'] = Variable<int>(startAyah.value);
    }
    if (endSurah.present) {
      map['end_surah'] = Variable<int>(endSurah.value);
    }
    if (endAyah.present) {
      map['end_ayah'] = Variable<int>(endAyah.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (nextStepIndex.present) {
      map['next_step_index'] = Variable<int>(nextStepIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HifzSessionCheckpointsCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('presetId: $presetId, ')
          ..write('nextStepIndex: $nextStepIndex, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HifzPlansTable extends HifzPlans
    with TableInfo<$HifzPlansTable, HifzPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HifzPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSurahMeta = const VerificationMeta(
    'startSurah',
  );
  @override
  late final GeneratedColumn<int> startSurah = GeneratedColumn<int>(
    'start_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAyahMeta = const VerificationMeta(
    'startAyah',
  );
  @override
  late final GeneratedColumn<int> startAyah = GeneratedColumn<int>(
    'start_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endSurahMeta = const VerificationMeta(
    'endSurah',
  );
  @override
  late final GeneratedColumn<int> endSurah = GeneratedColumn<int>(
    'end_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAyahMeta = const VerificationMeta(
    'endAyah',
  );
  @override
  late final GeneratedColumn<int> endAyah = GeneratedColumn<int>(
    'end_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileKey,
    title,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    startPage,
    presetId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hifz_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<HifzPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_surah')) {
      context.handle(
        _startSurahMeta,
        startSurah.isAcceptableOrUnknown(data['start_surah']!, _startSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_startSurahMeta);
    }
    if (data.containsKey('start_ayah')) {
      context.handle(
        _startAyahMeta,
        startAyah.isAcceptableOrUnknown(data['start_ayah']!, _startAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_startAyahMeta);
    }
    if (data.containsKey('end_surah')) {
      context.handle(
        _endSurahMeta,
        endSurah.isAcceptableOrUnknown(data['end_surah']!, _endSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_endSurahMeta);
    }
    if (data.containsKey('end_ayah')) {
      context.handle(
        _endAyahMeta,
        endAyah.isAcceptableOrUnknown(data['end_ayah']!, _endAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_endAyahMeta);
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    } else if (isInserting) {
      context.missing(_startPageMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HifzPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HifzPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_surah'],
      )!,
      startAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ayah'],
      )!,
      endSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_surah'],
      )!,
      endAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ayah'],
      )!,
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HifzPlansTable createAlias(String alias) {
    return $HifzPlansTable(attachedDatabase, alias);
  }
}

class HifzPlanRow extends DataClass implements Insertable<HifzPlanRow> {
  final int id;
  final String profileKey;
  final String title;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int startPage;
  final String presetId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HifzPlanRow({
    required this.id,
    required this.profileKey,
    required this.title,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.startPage,
    required this.presetId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_key'] = Variable<String>(profileKey);
    map['title'] = Variable<String>(title);
    map['start_surah'] = Variable<int>(startSurah);
    map['start_ayah'] = Variable<int>(startAyah);
    map['end_surah'] = Variable<int>(endSurah);
    map['end_ayah'] = Variable<int>(endAyah);
    map['start_page'] = Variable<int>(startPage);
    map['preset_id'] = Variable<String>(presetId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HifzPlansCompanion toCompanion(bool nullToAbsent) {
    return HifzPlansCompanion(
      id: Value(id),
      profileKey: Value(profileKey),
      title: Value(title),
      startSurah: Value(startSurah),
      startAyah: Value(startAyah),
      endSurah: Value(endSurah),
      endAyah: Value(endAyah),
      startPage: Value(startPage),
      presetId: Value(presetId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HifzPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HifzPlanRow(
      id: serializer.fromJson<int>(json['id']),
      profileKey: serializer.fromJson<String>(json['profileKey']),
      title: serializer.fromJson<String>(json['title']),
      startSurah: serializer.fromJson<int>(json['startSurah']),
      startAyah: serializer.fromJson<int>(json['startAyah']),
      endSurah: serializer.fromJson<int>(json['endSurah']),
      endAyah: serializer.fromJson<int>(json['endAyah']),
      startPage: serializer.fromJson<int>(json['startPage']),
      presetId: serializer.fromJson<String>(json['presetId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileKey': serializer.toJson<String>(profileKey),
      'title': serializer.toJson<String>(title),
      'startSurah': serializer.toJson<int>(startSurah),
      'startAyah': serializer.toJson<int>(startAyah),
      'endSurah': serializer.toJson<int>(endSurah),
      'endAyah': serializer.toJson<int>(endAyah),
      'startPage': serializer.toJson<int>(startPage),
      'presetId': serializer.toJson<String>(presetId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HifzPlanRow copyWith({
    int? id,
    String? profileKey,
    String? title,
    int? startSurah,
    int? startAyah,
    int? endSurah,
    int? endAyah,
    int? startPage,
    String? presetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HifzPlanRow(
    id: id ?? this.id,
    profileKey: profileKey ?? this.profileKey,
    title: title ?? this.title,
    startSurah: startSurah ?? this.startSurah,
    startAyah: startAyah ?? this.startAyah,
    endSurah: endSurah ?? this.endSurah,
    endAyah: endAyah ?? this.endAyah,
    startPage: startPage ?? this.startPage,
    presetId: presetId ?? this.presetId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HifzPlanRow copyWithCompanion(HifzPlansCompanion data) {
    return HifzPlanRow(
      id: data.id.present ? data.id.value : this.id,
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      title: data.title.present ? data.title.value : this.title,
      startSurah: data.startSurah.present
          ? data.startSurah.value
          : this.startSurah,
      startAyah: data.startAyah.present ? data.startAyah.value : this.startAyah,
      endSurah: data.endSurah.present ? data.endSurah.value : this.endSurah,
      endAyah: data.endAyah.present ? data.endAyah.value : this.endAyah,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HifzPlanRow(')
          ..write('id: $id, ')
          ..write('profileKey: $profileKey, ')
          ..write('title: $title, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('startPage: $startPage, ')
          ..write('presetId: $presetId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileKey,
    title,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    startPage,
    presetId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HifzPlanRow &&
          other.id == this.id &&
          other.profileKey == this.profileKey &&
          other.title == this.title &&
          other.startSurah == this.startSurah &&
          other.startAyah == this.startAyah &&
          other.endSurah == this.endSurah &&
          other.endAyah == this.endAyah &&
          other.startPage == this.startPage &&
          other.presetId == this.presetId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HifzPlansCompanion extends UpdateCompanion<HifzPlanRow> {
  final Value<int> id;
  final Value<String> profileKey;
  final Value<String> title;
  final Value<int> startSurah;
  final Value<int> startAyah;
  final Value<int> endSurah;
  final Value<int> endAyah;
  final Value<int> startPage;
  final Value<String> presetId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HifzPlansCompanion({
    this.id = const Value.absent(),
    this.profileKey = const Value.absent(),
    this.title = const Value.absent(),
    this.startSurah = const Value.absent(),
    this.startAyah = const Value.absent(),
    this.endSurah = const Value.absent(),
    this.endAyah = const Value.absent(),
    this.startPage = const Value.absent(),
    this.presetId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HifzPlansCompanion.insert({
    this.id = const Value.absent(),
    required String profileKey,
    required String title,
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
    required int startPage,
    required String presetId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : profileKey = Value(profileKey),
       title = Value(title),
       startSurah = Value(startSurah),
       startAyah = Value(startAyah),
       endSurah = Value(endSurah),
       endAyah = Value(endAyah),
       startPage = Value(startPage),
       presetId = Value(presetId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HifzPlanRow> custom({
    Expression<int>? id,
    Expression<String>? profileKey,
    Expression<String>? title,
    Expression<int>? startSurah,
    Expression<int>? startAyah,
    Expression<int>? endSurah,
    Expression<int>? endAyah,
    Expression<int>? startPage,
    Expression<String>? presetId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileKey != null) 'profile_key': profileKey,
      if (title != null) 'title': title,
      if (startSurah != null) 'start_surah': startSurah,
      if (startAyah != null) 'start_ayah': startAyah,
      if (endSurah != null) 'end_surah': endSurah,
      if (endAyah != null) 'end_ayah': endAyah,
      if (startPage != null) 'start_page': startPage,
      if (presetId != null) 'preset_id': presetId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HifzPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? profileKey,
    Value<String>? title,
    Value<int>? startSurah,
    Value<int>? startAyah,
    Value<int>? endSurah,
    Value<int>? endAyah,
    Value<int>? startPage,
    Value<String>? presetId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HifzPlansCompanion(
      id: id ?? this.id,
      profileKey: profileKey ?? this.profileKey,
      title: title ?? this.title,
      startSurah: startSurah ?? this.startSurah,
      startAyah: startAyah ?? this.startAyah,
      endSurah: endSurah ?? this.endSurah,
      endAyah: endAyah ?? this.endAyah,
      startPage: startPage ?? this.startPage,
      presetId: presetId ?? this.presetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startSurah.present) {
      map['start_surah'] = Variable<int>(startSurah.value);
    }
    if (startAyah.present) {
      map['start_ayah'] = Variable<int>(startAyah.value);
    }
    if (endSurah.present) {
      map['end_surah'] = Variable<int>(endSurah.value);
    }
    if (endAyah.present) {
      map['end_ayah'] = Variable<int>(endAyah.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HifzPlansCompanion(')
          ..write('id: $id, ')
          ..write('profileKey: $profileKey, ')
          ..write('title: $title, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('startPage: $startPage, ')
          ..write('presetId: $presetId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncKeyMeta = const VerificationMeta(
    'syncKey',
  );
  @override
  late final GeneratedColumn<String> syncKey = GeneratedColumn<String>(
    'sync_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncTokenMeta = const VerificationMeta(
    'syncToken',
  );
  @override
  late final GeneratedColumn<String> syncToken = GeneratedColumn<String>(
    'sync_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [syncKey, syncToken, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_key')) {
      context.handle(
        _syncKeyMeta,
        syncKey.isAcceptableOrUnknown(data['sync_key']!, _syncKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_syncKeyMeta);
    }
    if (data.containsKey('sync_token')) {
      context.handle(
        _syncTokenMeta,
        syncToken.isAcceptableOrUnknown(data['sync_token']!, _syncTokenMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncKey};
  @override
  SyncStateRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRecord(
      syncKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_key'],
      )!,
      syncToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_token'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRecord extends DataClass implements Insertable<SyncStateRecord> {
  final String syncKey;
  final String? syncToken;
  final int updatedAt;
  const SyncStateRecord({
    required this.syncKey,
    this.syncToken,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_key'] = Variable<String>(syncKey);
    if (!nullToAbsent || syncToken != null) {
      map['sync_token'] = Variable<String>(syncToken);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      syncKey: Value(syncKey),
      syncToken: syncToken == null && nullToAbsent
          ? const Value.absent()
          : Value(syncToken),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncStateRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRecord(
      syncKey: serializer.fromJson<String>(json['syncKey']),
      syncToken: serializer.fromJson<String?>(json['syncToken']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncKey': serializer.toJson<String>(syncKey),
      'syncToken': serializer.toJson<String?>(syncToken),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SyncStateRecord copyWith({
    String? syncKey,
    Value<String?> syncToken = const Value.absent(),
    int? updatedAt,
  }) => SyncStateRecord(
    syncKey: syncKey ?? this.syncKey,
    syncToken: syncToken.present ? syncToken.value : this.syncToken,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncStateRecord copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRecord(
      syncKey: data.syncKey.present ? data.syncKey.value : this.syncKey,
      syncToken: data.syncToken.present ? data.syncToken.value : this.syncToken,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRecord(')
          ..write('syncKey: $syncKey, ')
          ..write('syncToken: $syncToken, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(syncKey, syncToken, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRecord &&
          other.syncKey == this.syncKey &&
          other.syncToken == this.syncToken &&
          other.updatedAt == this.updatedAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRecord> {
  final Value<String> syncKey;
  final Value<String?> syncToken;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.syncKey = const Value.absent(),
    this.syncToken = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String syncKey,
    this.syncToken = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : syncKey = Value(syncKey),
       updatedAt = Value(updatedAt);
  static Insertable<SyncStateRecord> custom({
    Expression<String>? syncKey,
    Expression<String>? syncToken,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncKey != null) 'sync_key': syncKey,
      if (syncToken != null) 'sync_token': syncToken,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? syncKey,
    Value<String?>? syncToken,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      syncKey: syncKey ?? this.syncKey,
      syncToken: syncToken ?? this.syncToken,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncKey.present) {
      map['sync_key'] = Variable<String>(syncKey.value);
    }
    if (syncToken.present) {
      map['sync_token'] = Variable<String>(syncToken.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('syncKey: $syncKey, ')
          ..write('syncToken: $syncToken, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingPageVisitsTable extends ReadingPageVisits
    with TableInfo<$ReadingPageVisitsTable, ReadingPageVisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPageVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    dayKey,
    pageNumber,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_page_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingPageVisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey, dayKey, pageNumber};
  @override
  ReadingPageVisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPageVisitRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $ReadingPageVisitsTable createAlias(String alias) {
    return $ReadingPageVisitsTable(attachedDatabase, alias);
  }
}

class ReadingPageVisitRow extends DataClass
    implements Insertable<ReadingPageVisitRow> {
  final String profileKey;
  final String dayKey;
  final int pageNumber;
  final DateTime readAt;
  const ReadingPageVisitRow({
    required this.profileKey,
    required this.dayKey,
    required this.pageNumber,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['day_key'] = Variable<String>(dayKey);
    map['page_number'] = Variable<int>(pageNumber);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  ReadingPageVisitsCompanion toCompanion(bool nullToAbsent) {
    return ReadingPageVisitsCompanion(
      profileKey: Value(profileKey),
      dayKey: Value(dayKey),
      pageNumber: Value(pageNumber),
      readAt: Value(readAt),
    );
  }

  factory ReadingPageVisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPageVisitRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'dayKey': serializer.toJson<String>(dayKey),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  ReadingPageVisitRow copyWith({
    String? profileKey,
    String? dayKey,
    int? pageNumber,
    DateTime? readAt,
  }) => ReadingPageVisitRow(
    profileKey: profileKey ?? this.profileKey,
    dayKey: dayKey ?? this.dayKey,
    pageNumber: pageNumber ?? this.pageNumber,
    readAt: readAt ?? this.readAt,
  );
  ReadingPageVisitRow copyWithCompanion(ReadingPageVisitsCompanion data) {
    return ReadingPageVisitRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPageVisitRow(')
          ..write('profileKey: $profileKey, ')
          ..write('dayKey: $dayKey, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileKey, dayKey, pageNumber, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPageVisitRow &&
          other.profileKey == this.profileKey &&
          other.dayKey == this.dayKey &&
          other.pageNumber == this.pageNumber &&
          other.readAt == this.readAt);
}

class ReadingPageVisitsCompanion extends UpdateCompanion<ReadingPageVisitRow> {
  final Value<String> profileKey;
  final Value<String> dayKey;
  final Value<int> pageNumber;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const ReadingPageVisitsCompanion({
    this.profileKey = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingPageVisitsCompanion.insert({
    required String profileKey,
    required String dayKey,
    required int pageNumber,
    required DateTime readAt,
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       dayKey = Value(dayKey),
       pageNumber = Value(pageNumber),
       readAt = Value(readAt);
  static Insertable<ReadingPageVisitRow> custom({
    Expression<String>? profileKey,
    Expression<String>? dayKey,
    Expression<int>? pageNumber,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (dayKey != null) 'day_key': dayKey,
      if (pageNumber != null) 'page_number': pageNumber,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingPageVisitsCompanion copyWith({
    Value<String>? profileKey,
    Value<String>? dayKey,
    Value<int>? pageNumber,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return ReadingPageVisitsCompanion(
      profileKey: profileKey ?? this.profileKey,
      dayKey: dayKey ?? this.dayKey,
      pageNumber: pageNumber ?? this.pageNumber,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPageVisitsCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('dayKey: $dayKey, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTable extends DailyGoals
    with TableInfo<$DailyGoalsTable, DailyGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newHifzAyahsTargetMeta =
      const VerificationMeta('newHifzAyahsTarget');
  @override
  late final GeneratedColumn<int> newHifzAyahsTarget = GeneratedColumn<int>(
    'new_hifz_ayahs_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionAyahsTargetMeta =
      const VerificationMeta('revisionAyahsTarget');
  @override
  late final GeneratedColumn<int> revisionAyahsTarget = GeneratedColumn<int>(
    'revision_ayahs_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readingPagesTargetMeta =
      const VerificationMeta('readingPagesTarget');
  @override
  late final GeneratedColumn<int> readingPagesTarget = GeneratedColumn<int>(
    'reading_pages_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    dayKey,
    newHifzAyahsTarget,
    revisionAyahsTarget,
    readingPagesTarget,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('new_hifz_ayahs_target')) {
      context.handle(
        _newHifzAyahsTargetMeta,
        newHifzAyahsTarget.isAcceptableOrUnknown(
          data['new_hifz_ayahs_target']!,
          _newHifzAyahsTargetMeta,
        ),
      );
    }
    if (data.containsKey('revision_ayahs_target')) {
      context.handle(
        _revisionAyahsTargetMeta,
        revisionAyahsTarget.isAcceptableOrUnknown(
          data['revision_ayahs_target']!,
          _revisionAyahsTargetMeta,
        ),
      );
    }
    if (data.containsKey('reading_pages_target')) {
      context.handle(
        _readingPagesTargetMeta,
        readingPagesTarget.isAcceptableOrUnknown(
          data['reading_pages_target']!,
          _readingPagesTargetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey, dayKey};
  @override
  DailyGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoalRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      newHifzAyahsTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_hifz_ayahs_target'],
      )!,
      revisionAyahsTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_ayahs_target'],
      )!,
      readingPagesTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_pages_target'],
      )!,
    );
  }

  @override
  $DailyGoalsTable createAlias(String alias) {
    return $DailyGoalsTable(attachedDatabase, alias);
  }
}

class DailyGoalRow extends DataClass implements Insertable<DailyGoalRow> {
  final String profileKey;
  final String dayKey;
  final int newHifzAyahsTarget;
  final int revisionAyahsTarget;
  final int readingPagesTarget;
  const DailyGoalRow({
    required this.profileKey,
    required this.dayKey,
    required this.newHifzAyahsTarget,
    required this.revisionAyahsTarget,
    required this.readingPagesTarget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['day_key'] = Variable<String>(dayKey);
    map['new_hifz_ayahs_target'] = Variable<int>(newHifzAyahsTarget);
    map['revision_ayahs_target'] = Variable<int>(revisionAyahsTarget);
    map['reading_pages_target'] = Variable<int>(readingPagesTarget);
    return map;
  }

  DailyGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsCompanion(
      profileKey: Value(profileKey),
      dayKey: Value(dayKey),
      newHifzAyahsTarget: Value(newHifzAyahsTarget),
      revisionAyahsTarget: Value(revisionAyahsTarget),
      readingPagesTarget: Value(readingPagesTarget),
    );
  }

  factory DailyGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoalRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      newHifzAyahsTarget: serializer.fromJson<int>(json['newHifzAyahsTarget']),
      revisionAyahsTarget: serializer.fromJson<int>(
        json['revisionAyahsTarget'],
      ),
      readingPagesTarget: serializer.fromJson<int>(json['readingPagesTarget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'dayKey': serializer.toJson<String>(dayKey),
      'newHifzAyahsTarget': serializer.toJson<int>(newHifzAyahsTarget),
      'revisionAyahsTarget': serializer.toJson<int>(revisionAyahsTarget),
      'readingPagesTarget': serializer.toJson<int>(readingPagesTarget),
    };
  }

  DailyGoalRow copyWith({
    String? profileKey,
    String? dayKey,
    int? newHifzAyahsTarget,
    int? revisionAyahsTarget,
    int? readingPagesTarget,
  }) => DailyGoalRow(
    profileKey: profileKey ?? this.profileKey,
    dayKey: dayKey ?? this.dayKey,
    newHifzAyahsTarget: newHifzAyahsTarget ?? this.newHifzAyahsTarget,
    revisionAyahsTarget: revisionAyahsTarget ?? this.revisionAyahsTarget,
    readingPagesTarget: readingPagesTarget ?? this.readingPagesTarget,
  );
  DailyGoalRow copyWithCompanion(DailyGoalsCompanion data) {
    return DailyGoalRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      newHifzAyahsTarget: data.newHifzAyahsTarget.present
          ? data.newHifzAyahsTarget.value
          : this.newHifzAyahsTarget,
      revisionAyahsTarget: data.revisionAyahsTarget.present
          ? data.revisionAyahsTarget.value
          : this.revisionAyahsTarget,
      readingPagesTarget: data.readingPagesTarget.present
          ? data.readingPagesTarget.value
          : this.readingPagesTarget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalRow(')
          ..write('profileKey: $profileKey, ')
          ..write('dayKey: $dayKey, ')
          ..write('newHifzAyahsTarget: $newHifzAyahsTarget, ')
          ..write('revisionAyahsTarget: $revisionAyahsTarget, ')
          ..write('readingPagesTarget: $readingPagesTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    dayKey,
    newHifzAyahsTarget,
    revisionAyahsTarget,
    readingPagesTarget,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoalRow &&
          other.profileKey == this.profileKey &&
          other.dayKey == this.dayKey &&
          other.newHifzAyahsTarget == this.newHifzAyahsTarget &&
          other.revisionAyahsTarget == this.revisionAyahsTarget &&
          other.readingPagesTarget == this.readingPagesTarget);
}

class DailyGoalsCompanion extends UpdateCompanion<DailyGoalRow> {
  final Value<String> profileKey;
  final Value<String> dayKey;
  final Value<int> newHifzAyahsTarget;
  final Value<int> revisionAyahsTarget;
  final Value<int> readingPagesTarget;
  final Value<int> rowid;
  const DailyGoalsCompanion({
    this.profileKey = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.newHifzAyahsTarget = const Value.absent(),
    this.revisionAyahsTarget = const Value.absent(),
    this.readingPagesTarget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyGoalsCompanion.insert({
    required String profileKey,
    required String dayKey,
    this.newHifzAyahsTarget = const Value.absent(),
    this.revisionAyahsTarget = const Value.absent(),
    this.readingPagesTarget = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       dayKey = Value(dayKey);
  static Insertable<DailyGoalRow> custom({
    Expression<String>? profileKey,
    Expression<String>? dayKey,
    Expression<int>? newHifzAyahsTarget,
    Expression<int>? revisionAyahsTarget,
    Expression<int>? readingPagesTarget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (dayKey != null) 'day_key': dayKey,
      if (newHifzAyahsTarget != null)
        'new_hifz_ayahs_target': newHifzAyahsTarget,
      if (revisionAyahsTarget != null)
        'revision_ayahs_target': revisionAyahsTarget,
      if (readingPagesTarget != null)
        'reading_pages_target': readingPagesTarget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyGoalsCompanion copyWith({
    Value<String>? profileKey,
    Value<String>? dayKey,
    Value<int>? newHifzAyahsTarget,
    Value<int>? revisionAyahsTarget,
    Value<int>? readingPagesTarget,
    Value<int>? rowid,
  }) {
    return DailyGoalsCompanion(
      profileKey: profileKey ?? this.profileKey,
      dayKey: dayKey ?? this.dayKey,
      newHifzAyahsTarget: newHifzAyahsTarget ?? this.newHifzAyahsTarget,
      revisionAyahsTarget: revisionAyahsTarget ?? this.revisionAyahsTarget,
      readingPagesTarget: readingPagesTarget ?? this.readingPagesTarget,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (newHifzAyahsTarget.present) {
      map['new_hifz_ayahs_target'] = Variable<int>(newHifzAyahsTarget.value);
    }
    if (revisionAyahsTarget.present) {
      map['revision_ayahs_target'] = Variable<int>(revisionAyahsTarget.value);
    }
    if (readingPagesTarget.present) {
      map['reading_pages_target'] = Variable<int>(readingPagesTarget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('dayKey: $dayKey, ')
          ..write('newHifzAyahsTarget: $newHifzAyahsTarget, ')
          ..write('revisionAyahsTarget: $revisionAyahsTarget, ')
          ..write('readingPagesTarget: $readingPagesTarget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyBookmarksTable extends StudyBookmarks
    with TableInfo<$StudyBookmarksTable, StudyBookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetKeyMeta = const VerificationMeta(
    'targetKey',
  );
  @override
  late final GeneratedColumn<String> targetKey = GeneratedColumn<String>(
    'target_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _wordPositionMeta = const VerificationMeta(
    'wordPosition',
  );
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
    'word_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    targetKey,
    targetType,
    surahNumber,
    ayahNumber,
    wordPosition,
    category,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyBookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('target_key')) {
      context.handle(
        _targetKeyMeta,
        targetKey.isAcceptableOrUnknown(data['target_key']!, _targetKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_targetKeyMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
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
    if (data.containsKey('word_position')) {
      context.handle(
        _wordPositionMeta,
        wordPosition.isAcceptableOrUnknown(
          data['word_position']!,
          _wordPositionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey, targetKey};
  @override
  StudyBookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyBookmarkRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      targetKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_key'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      wordPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_position'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudyBookmarksTable createAlias(String alias) {
    return $StudyBookmarksTable(attachedDatabase, alias);
  }
}

class StudyBookmarkRow extends DataClass
    implements Insertable<StudyBookmarkRow> {
  final String profileKey;
  final String targetKey;
  final String targetType;
  final int surahNumber;
  final int ayahNumber;
  final int? wordPosition;
  final String category;
  final DateTime createdAt;
  const StudyBookmarkRow({
    required this.profileKey,
    required this.targetKey,
    required this.targetType,
    required this.surahNumber,
    required this.ayahNumber,
    this.wordPosition,
    required this.category,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['target_key'] = Variable<String>(targetKey);
    map['target_type'] = Variable<String>(targetType);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    if (!nullToAbsent || wordPosition != null) {
      map['word_position'] = Variable<int>(wordPosition);
    }
    map['category'] = Variable<String>(category);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudyBookmarksCompanion toCompanion(bool nullToAbsent) {
    return StudyBookmarksCompanion(
      profileKey: Value(profileKey),
      targetKey: Value(targetKey),
      targetType: Value(targetType),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      wordPosition: wordPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(wordPosition),
      category: Value(category),
      createdAt: Value(createdAt),
    );
  }

  factory StudyBookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyBookmarkRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      targetKey: serializer.fromJson<String>(json['targetKey']),
      targetType: serializer.fromJson<String>(json['targetType']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      wordPosition: serializer.fromJson<int?>(json['wordPosition']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'targetKey': serializer.toJson<String>(targetKey),
      'targetType': serializer.toJson<String>(targetType),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'wordPosition': serializer.toJson<int?>(wordPosition),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StudyBookmarkRow copyWith({
    String? profileKey,
    String? targetKey,
    String? targetType,
    int? surahNumber,
    int? ayahNumber,
    Value<int?> wordPosition = const Value.absent(),
    String? category,
    DateTime? createdAt,
  }) => StudyBookmarkRow(
    profileKey: profileKey ?? this.profileKey,
    targetKey: targetKey ?? this.targetKey,
    targetType: targetType ?? this.targetType,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    wordPosition: wordPosition.present ? wordPosition.value : this.wordPosition,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
  );
  StudyBookmarkRow copyWithCompanion(StudyBookmarksCompanion data) {
    return StudyBookmarkRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      targetKey: data.targetKey.present ? data.targetKey.value : this.targetKey,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyBookmarkRow(')
          ..write('profileKey: $profileKey, ')
          ..write('targetKey: $targetKey, ')
          ..write('targetType: $targetType, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    targetKey,
    targetType,
    surahNumber,
    ayahNumber,
    wordPosition,
    category,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyBookmarkRow &&
          other.profileKey == this.profileKey &&
          other.targetKey == this.targetKey &&
          other.targetType == this.targetType &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.wordPosition == this.wordPosition &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class StudyBookmarksCompanion extends UpdateCompanion<StudyBookmarkRow> {
  final Value<String> profileKey;
  final Value<String> targetKey;
  final Value<String> targetType;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<int?> wordPosition;
  final Value<String> category;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StudyBookmarksCompanion({
    this.profileKey = const Value.absent(),
    this.targetKey = const Value.absent(),
    this.targetType = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyBookmarksCompanion.insert({
    required String profileKey,
    required String targetKey,
    required String targetType,
    required int surahNumber,
    required int ayahNumber,
    this.wordPosition = const Value.absent(),
    required String category,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       targetKey = Value(targetKey),
       targetType = Value(targetType),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<StudyBookmarkRow> custom({
    Expression<String>? profileKey,
    Expression<String>? targetKey,
    Expression<String>? targetType,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? wordPosition,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (targetKey != null) 'target_key': targetKey,
      if (targetType != null) 'target_type': targetType,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (wordPosition != null) 'word_position': wordPosition,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyBookmarksCompanion copyWith({
    Value<String>? profileKey,
    Value<String>? targetKey,
    Value<String>? targetType,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<int?>? wordPosition,
    Value<String>? category,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StudyBookmarksCompanion(
      profileKey: profileKey ?? this.profileKey,
      targetKey: targetKey ?? this.targetKey,
      targetType: targetType ?? this.targetType,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      wordPosition: wordPosition ?? this.wordPosition,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (targetKey.present) {
      map['target_key'] = Variable<String>(targetKey.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyBookmarksCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('targetKey: $targetKey, ')
          ..write('targetType: $targetType, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyNotesTable extends StudyNotes
    with TableInfo<$StudyNotesTable, StudyNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetKeyMeta = const VerificationMeta(
    'targetKey',
  );
  @override
  late final GeneratedColumn<String> targetKey = GeneratedColumn<String>(
    'target_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _wordPositionMeta = const VerificationMeta(
    'wordPosition',
  );
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
    'word_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    targetKey,
    targetType,
    surahNumber,
    ayahNumber,
    wordPosition,
    noteText,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('target_key')) {
      context.handle(
        _targetKeyMeta,
        targetKey.isAcceptableOrUnknown(data['target_key']!, _targetKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_targetKeyMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
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
    if (data.containsKey('word_position')) {
      context.handle(
        _wordPositionMeta,
        wordPosition.isAcceptableOrUnknown(
          data['word_position']!,
          _wordPositionMeta,
        ),
      );
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTextMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey, targetKey};
  @override
  StudyNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyNoteRow(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      targetKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_key'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      wordPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_position'],
      ),
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StudyNotesTable createAlias(String alias) {
    return $StudyNotesTable(attachedDatabase, alias);
  }
}

class StudyNoteRow extends DataClass implements Insertable<StudyNoteRow> {
  final String profileKey;
  final String targetKey;
  final String targetType;
  final int surahNumber;
  final int ayahNumber;
  final int? wordPosition;
  final String noteText;
  final DateTime updatedAt;
  const StudyNoteRow({
    required this.profileKey,
    required this.targetKey,
    required this.targetType,
    required this.surahNumber,
    required this.ayahNumber,
    this.wordPosition,
    required this.noteText,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['target_key'] = Variable<String>(targetKey);
    map['target_type'] = Variable<String>(targetType);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    if (!nullToAbsent || wordPosition != null) {
      map['word_position'] = Variable<int>(wordPosition);
    }
    map['note_text'] = Variable<String>(noteText);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudyNotesCompanion toCompanion(bool nullToAbsent) {
    return StudyNotesCompanion(
      profileKey: Value(profileKey),
      targetKey: Value(targetKey),
      targetType: Value(targetType),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      wordPosition: wordPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(wordPosition),
      noteText: Value(noteText),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudyNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyNoteRow(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      targetKey: serializer.fromJson<String>(json['targetKey']),
      targetType: serializer.fromJson<String>(json['targetType']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      wordPosition: serializer.fromJson<int?>(json['wordPosition']),
      noteText: serializer.fromJson<String>(json['noteText']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'targetKey': serializer.toJson<String>(targetKey),
      'targetType': serializer.toJson<String>(targetType),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'wordPosition': serializer.toJson<int?>(wordPosition),
      'noteText': serializer.toJson<String>(noteText),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudyNoteRow copyWith({
    String? profileKey,
    String? targetKey,
    String? targetType,
    int? surahNumber,
    int? ayahNumber,
    Value<int?> wordPosition = const Value.absent(),
    String? noteText,
    DateTime? updatedAt,
  }) => StudyNoteRow(
    profileKey: profileKey ?? this.profileKey,
    targetKey: targetKey ?? this.targetKey,
    targetType: targetType ?? this.targetType,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    wordPosition: wordPosition.present ? wordPosition.value : this.wordPosition,
    noteText: noteText ?? this.noteText,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StudyNoteRow copyWithCompanion(StudyNotesCompanion data) {
    return StudyNoteRow(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      targetKey: data.targetKey.present ? data.targetKey.value : this.targetKey,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyNoteRow(')
          ..write('profileKey: $profileKey, ')
          ..write('targetKey: $targetKey, ')
          ..write('targetType: $targetType, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('noteText: $noteText, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    targetKey,
    targetType,
    surahNumber,
    ayahNumber,
    wordPosition,
    noteText,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyNoteRow &&
          other.profileKey == this.profileKey &&
          other.targetKey == this.targetKey &&
          other.targetType == this.targetType &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.wordPosition == this.wordPosition &&
          other.noteText == this.noteText &&
          other.updatedAt == this.updatedAt);
}

class StudyNotesCompanion extends UpdateCompanion<StudyNoteRow> {
  final Value<String> profileKey;
  final Value<String> targetKey;
  final Value<String> targetType;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<int?> wordPosition;
  final Value<String> noteText;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudyNotesCompanion({
    this.profileKey = const Value.absent(),
    this.targetKey = const Value.absent(),
    this.targetType = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.noteText = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyNotesCompanion.insert({
    required String profileKey,
    required String targetKey,
    required String targetType,
    required int surahNumber,
    required int ayahNumber,
    this.wordPosition = const Value.absent(),
    required String noteText,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       targetKey = Value(targetKey),
       targetType = Value(targetType),
       surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       noteText = Value(noteText),
       updatedAt = Value(updatedAt);
  static Insertable<StudyNoteRow> custom({
    Expression<String>? profileKey,
    Expression<String>? targetKey,
    Expression<String>? targetType,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? wordPosition,
    Expression<String>? noteText,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (targetKey != null) 'target_key': targetKey,
      if (targetType != null) 'target_type': targetType,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (wordPosition != null) 'word_position': wordPosition,
      if (noteText != null) 'note_text': noteText,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyNotesCompanion copyWith({
    Value<String>? profileKey,
    Value<String>? targetKey,
    Value<String>? targetType,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<int?>? wordPosition,
    Value<String>? noteText,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudyNotesCompanion(
      profileKey: profileKey ?? this.profileKey,
      targetKey: targetKey ?? this.targetKey,
      targetType: targetType ?? this.targetType,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      wordPosition: wordPosition ?? this.wordPosition,
      noteText: noteText ?? this.noteText,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (targetKey.present) {
      map['target_key'] = Variable<String>(targetKey.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyNotesCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('targetKey: $targetKey, ')
          ..write('targetType: $targetType, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('noteText: $noteText, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstalledTafsirPackagesTable extends InstalledTafsirPackages
    with
        TableInfo<$InstalledTafsirPackagesTable, InstalledTafsirPackageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledTafsirPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  @override
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    name,
    language,
    version,
    localPath,
    sha256,
    attribution,
    license,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_tafsir_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledTafsirPackageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  InstalledTafsirPackageRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledTafsirPackageRecord(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $InstalledTafsirPackagesTable createAlias(String alias) {
    return $InstalledTafsirPackagesTable(attachedDatabase, alias);
  }
}

class InstalledTafsirPackageRecord extends DataClass
    implements Insertable<InstalledTafsirPackageRecord> {
  final String sourceId;
  final String name;
  final String language;
  final String version;
  final String localPath;
  final String sha256;
  final String? attribution;
  final String? license;
  final DateTime installedAt;
  const InstalledTafsirPackageRecord({
    required this.sourceId,
    required this.name,
    required this.language,
    required this.version,
    required this.localPath,
    required this.sha256,
    this.attribution,
    this.license,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    map['version'] = Variable<String>(version);
    map['local_path'] = Variable<String>(localPath);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || attribution != null) {
      map['attribution'] = Variable<String>(attribution);
    }
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  InstalledTafsirPackagesCompanion toCompanion(bool nullToAbsent) {
    return InstalledTafsirPackagesCompanion(
      sourceId: Value(sourceId),
      name: Value(name),
      language: Value(language),
      version: Value(version),
      localPath: Value(localPath),
      sha256: Value(sha256),
      attribution: attribution == null && nullToAbsent
          ? const Value.absent()
          : Value(attribution),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      installedAt: Value(installedAt),
    );
  }

  factory InstalledTafsirPackageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledTafsirPackageRecord(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      version: serializer.fromJson<String>(json['version']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      attribution: serializer.fromJson<String?>(json['attribution']),
      license: serializer.fromJson<String?>(json['license']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'version': serializer.toJson<String>(version),
      'localPath': serializer.toJson<String>(localPath),
      'sha256': serializer.toJson<String>(sha256),
      'attribution': serializer.toJson<String?>(attribution),
      'license': serializer.toJson<String?>(license),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  InstalledTafsirPackageRecord copyWith({
    String? sourceId,
    String? name,
    String? language,
    String? version,
    String? localPath,
    String? sha256,
    Value<String?> attribution = const Value.absent(),
    Value<String?> license = const Value.absent(),
    DateTime? installedAt,
  }) => InstalledTafsirPackageRecord(
    sourceId: sourceId ?? this.sourceId,
    name: name ?? this.name,
    language: language ?? this.language,
    version: version ?? this.version,
    localPath: localPath ?? this.localPath,
    sha256: sha256 ?? this.sha256,
    attribution: attribution.present ? attribution.value : this.attribution,
    license: license.present ? license.value : this.license,
    installedAt: installedAt ?? this.installedAt,
  );
  InstalledTafsirPackageRecord copyWithCompanion(
    InstalledTafsirPackagesCompanion data,
  ) {
    return InstalledTafsirPackageRecord(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      version: data.version.present ? data.version.value : this.version,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
      license: data.license.present ? data.license.value : this.license,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledTafsirPackageRecord(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('attribution: $attribution, ')
          ..write('license: $license, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    name,
    language,
    version,
    localPath,
    sha256,
    attribution,
    license,
    installedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledTafsirPackageRecord &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.language == this.language &&
          other.version == this.version &&
          other.localPath == this.localPath &&
          other.sha256 == this.sha256 &&
          other.attribution == this.attribution &&
          other.license == this.license &&
          other.installedAt == this.installedAt);
}

class InstalledTafsirPackagesCompanion
    extends UpdateCompanion<InstalledTafsirPackageRecord> {
  final Value<String> sourceId;
  final Value<String> name;
  final Value<String> language;
  final Value<String> version;
  final Value<String> localPath;
  final Value<String> sha256;
  final Value<String?> attribution;
  final Value<String?> license;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const InstalledTafsirPackagesCompanion({
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.version = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.attribution = const Value.absent(),
    this.license = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledTafsirPackagesCompanion.insert({
    required String sourceId,
    required String name,
    required String language,
    required String version,
    required String localPath,
    required String sha256,
    this.attribution = const Value.absent(),
    this.license = const Value.absent(),
    required DateTime installedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       name = Value(name),
       language = Value(language),
       version = Value(version),
       localPath = Value(localPath),
       sha256 = Value(sha256),
       installedAt = Value(installedAt);
  static Insertable<InstalledTafsirPackageRecord> custom({
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? version,
    Expression<String>? localPath,
    Expression<String>? sha256,
    Expression<String>? attribution,
    Expression<String>? license,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (version != null) 'version': version,
      if (localPath != null) 'local_path': localPath,
      if (sha256 != null) 'sha256': sha256,
      if (attribution != null) 'attribution': attribution,
      if (license != null) 'license': license,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledTafsirPackagesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? name,
    Value<String>? language,
    Value<String>? version,
    Value<String>? localPath,
    Value<String>? sha256,
    Value<String?>? attribution,
    Value<String?>? license,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return InstalledTafsirPackagesCompanion(
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      language: language ?? this.language,
      version: version ?? this.version,
      localPath: localPath ?? this.localPath,
      sha256: sha256 ?? this.sha256,
      attribution: attribution ?? this.attribution,
      license: license ?? this.license,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledTafsirPackagesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('attribution: $attribution, ')
          ..write('license: $license, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileKeyMeta = const VerificationMeta(
    'profileKey',
  );
  @override
  late final GeneratedColumn<String> profileKey = GeneratedColumn<String>(
    'profile_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSurahMeta = const VerificationMeta(
    'lastSurah',
  );
  @override
  late final GeneratedColumn<int> lastSurah = GeneratedColumn<int>(
    'last_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAyahMeta = const VerificationMeta(
    'lastAyah',
  );
  @override
  late final GeneratedColumn<int> lastAyah = GeneratedColumn<int>(
    'last_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileKey,
    lastSurah,
    lastAyah,
    lastPage,
    lastReadAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_key')) {
      context.handle(
        _profileKeyMeta,
        profileKey.isAcceptableOrUnknown(data['profile_key']!, _profileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_profileKeyMeta);
    }
    if (data.containsKey('last_surah')) {
      context.handle(
        _lastSurahMeta,
        lastSurah.isAcceptableOrUnknown(data['last_surah']!, _lastSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSurahMeta);
    }
    if (data.containsKey('last_ayah')) {
      context.handle(
        _lastAyahMeta,
        lastAyah.isAcceptableOrUnknown(data['last_ayah']!, _lastAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAyahMeta);
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    } else if (isInserting) {
      context.missing(_lastPageMeta);
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileKey};
  @override
  ReadingProgressRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressRecord(
      profileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_key'],
      )!,
      lastSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_surah'],
      )!,
      lastAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ayah'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      )!,
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      ),
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressRecord extends DataClass
    implements Insertable<ReadingProgressRecord> {
  final String profileKey;
  final int lastSurah;
  final int lastAyah;
  final int lastPage;
  final DateTime? lastReadAt;
  const ReadingProgressRecord({
    required this.profileKey,
    required this.lastSurah,
    required this.lastAyah,
    required this.lastPage,
    this.lastReadAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_key'] = Variable<String>(profileKey);
    map['last_surah'] = Variable<int>(lastSurah);
    map['last_ayah'] = Variable<int>(lastAyah);
    map['last_page'] = Variable<int>(lastPage);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      profileKey: Value(profileKey),
      lastSurah: Value(lastSurah),
      lastAyah: Value(lastAyah),
      lastPage: Value(lastPage),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
    );
  }

  factory ReadingProgressRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressRecord(
      profileKey: serializer.fromJson<String>(json['profileKey']),
      lastSurah: serializer.fromJson<int>(json['lastSurah']),
      lastAyah: serializer.fromJson<int>(json['lastAyah']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileKey': serializer.toJson<String>(profileKey),
      'lastSurah': serializer.toJson<int>(lastSurah),
      'lastAyah': serializer.toJson<int>(lastAyah),
      'lastPage': serializer.toJson<int>(lastPage),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
    };
  }

  ReadingProgressRecord copyWith({
    String? profileKey,
    int? lastSurah,
    int? lastAyah,
    int? lastPage,
    Value<DateTime?> lastReadAt = const Value.absent(),
  }) => ReadingProgressRecord(
    profileKey: profileKey ?? this.profileKey,
    lastSurah: lastSurah ?? this.lastSurah,
    lastAyah: lastAyah ?? this.lastAyah,
    lastPage: lastPage ?? this.lastPage,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
  );
  ReadingProgressRecord copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressRecord(
      profileKey: data.profileKey.present
          ? data.profileKey.value
          : this.profileKey,
      lastSurah: data.lastSurah.present ? data.lastSurah.value : this.lastSurah,
      lastAyah: data.lastAyah.present ? data.lastAyah.value : this.lastAyah,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressRecord(')
          ..write('profileKey: $profileKey, ')
          ..write('lastSurah: $lastSurah, ')
          ..write('lastAyah: $lastAyah, ')
          ..write('lastPage: $lastPage, ')
          ..write('lastReadAt: $lastReadAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileKey, lastSurah, lastAyah, lastPage, lastReadAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressRecord &&
          other.profileKey == this.profileKey &&
          other.lastSurah == this.lastSurah &&
          other.lastAyah == this.lastAyah &&
          other.lastPage == this.lastPage &&
          other.lastReadAt == this.lastReadAt);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressRecord> {
  final Value<String> profileKey;
  final Value<int> lastSurah;
  final Value<int> lastAyah;
  final Value<int> lastPage;
  final Value<DateTime?> lastReadAt;
  final Value<int> rowid;
  const ReadingProgressCompanion({
    this.profileKey = const Value.absent(),
    this.lastSurah = const Value.absent(),
    this.lastAyah = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    required String profileKey,
    required int lastSurah,
    required int lastAyah,
    required int lastPage,
    this.lastReadAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileKey = Value(profileKey),
       lastSurah = Value(lastSurah),
       lastAyah = Value(lastAyah),
       lastPage = Value(lastPage);
  static Insertable<ReadingProgressRecord> custom({
    Expression<String>? profileKey,
    Expression<int>? lastSurah,
    Expression<int>? lastAyah,
    Expression<int>? lastPage,
    Expression<DateTime>? lastReadAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileKey != null) 'profile_key': profileKey,
      if (lastSurah != null) 'last_surah': lastSurah,
      if (lastAyah != null) 'last_ayah': lastAyah,
      if (lastPage != null) 'last_page': lastPage,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<String>? profileKey,
    Value<int>? lastSurah,
    Value<int>? lastAyah,
    Value<int>? lastPage,
    Value<DateTime?>? lastReadAt,
    Value<int>? rowid,
  }) {
    return ReadingProgressCompanion(
      profileKey: profileKey ?? this.profileKey,
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      lastPage: lastPage ?? this.lastPage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileKey.present) {
      map['profile_key'] = Variable<String>(profileKey.value);
    }
    if (lastSurah.present) {
      map['last_surah'] = Variable<int>(lastSurah.value);
    }
    if (lastAyah.present) {
      map['last_ayah'] = Variable<int>(lastAyah.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('profileKey: $profileKey, ')
          ..write('lastSurah: $lastSurah, ')
          ..write('lastAyah: $lastAyah, ')
          ..write('lastPage: $lastPage, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSettingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRecord(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRecord extends DataClass
    implements Insertable<AppSettingRecord> {
  final String settingKey;
  final String settingValue;
  const AppSettingRecord({
    required this.settingKey,
    required this.settingValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory AppSettingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRecord(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  AppSettingRecord copyWith({String? settingKey, String? settingValue}) =>
      AppSettingRecord(
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
      );
  AppSettingRecord copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRecord(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRecord(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRecord &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRecord> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<AppSettingRecord> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $AudioFilesTable audioFiles = $AudioFilesTable(this);
  late final $AyahTimingsTable ayahTimings = $AyahTimingsTable(this);
  late final $WordTimingsTable wordTimings = $WordTimingsTable(this);
  late final $DownloadJobsTable downloadJobs = $DownloadJobsTable(this);
  late final $HifzProgressEntriesTable hifzProgressEntries =
      $HifzProgressEntriesTable(this);
  late final $HifzReviewHistoryRowsTable hifzReviewHistoryRows =
      $HifzReviewHistoryRowsTable(this);
  late final $HifzSessionCheckpointsTable hifzSessionCheckpoints =
      $HifzSessionCheckpointsTable(this);
  late final $HifzPlansTable hifzPlans = $HifzPlansTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $ReadingPageVisitsTable readingPageVisits =
      $ReadingPageVisitsTable(this);
  late final $DailyGoalsTable dailyGoals = $DailyGoalsTable(this);
  late final $StudyBookmarksTable studyBookmarks = $StudyBookmarksTable(this);
  late final $StudyNotesTable studyNotes = $StudyNotesTable(this);
  late final $InstalledTafsirPackagesTable installedTafsirPackages =
      $InstalledTafsirPackagesTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index hifzProgressDueIdx = Index(
    'hifz_progress_due_idx',
    'CREATE INDEX hifz_progress_due_idx ON hifz_progress_entries (profile_key, next_review_at)',
  );
  late final Index hifzReviewDateIdx = Index(
    'hifz_review_date_idx',
    'CREATE INDEX hifz_review_date_idx ON hifz_review_history_rows (profile_key, reviewed_at)',
  );
  late final Index hifzPlansProfileIdx = Index(
    'hifz_plans_profile_idx',
    'CREATE INDEX hifz_plans_profile_idx ON hifz_plans (profile_key, updated_at)',
  );
  late final Index readingPageVisitDateIdx = Index(
    'reading_page_visit_date_idx',
    'CREATE INDEX reading_page_visit_date_idx ON reading_page_visits (profile_key, read_at)',
  );
  late final Index dailyGoalEffectiveIdx = Index(
    'daily_goal_effective_idx',
    'CREATE INDEX daily_goal_effective_idx ON daily_goals (profile_key, day_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    audioFiles,
    ayahTimings,
    wordTimings,
    downloadJobs,
    hifzProgressEntries,
    hifzReviewHistoryRows,
    hifzSessionCheckpoints,
    hifzPlans,
    syncStates,
    readingPageVisits,
    dailyGoals,
    studyBookmarks,
    studyNotes,
    installedTafsirPackages,
    readingProgress,
    appSettings,
    hifzProgressDueIdx,
    hifzReviewDateIdx,
    hifzPlansProfileIdx,
    readingPageVisitDateIdx,
    dailyGoalEffectiveIdx,
  ];
}

typedef $$AudioFilesTableCreateCompanionBuilder =
    AudioFilesCompanion Function({
      required String audioKey,
      required String audioType,
      Value<int?> reciterId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> wordPosition,
      required String remoteUrl,
      Value<String?> localPath,
      Value<String?> format,
      Value<int?> fileSize,
      Value<int> downloadedBytes,
      Value<String> status,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AudioFilesTableUpdateCompanionBuilder =
    AudioFilesCompanion Function({
      Value<String> audioKey,
      Value<String> audioType,
      Value<int?> reciterId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> wordPosition,
      Value<String> remoteUrl,
      Value<String?> localPath,
      Value<String?> format,
      Value<int?> fileSize,
      Value<int> downloadedBytes,
      Value<String> status,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AudioFilesTableFilterComposer
    extends Composer<_$UserDatabase, $AudioFilesTable> {
  $$AudioFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get audioKey => $composableBuilder(
    column: $table.audioKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioType => $composableBuilder(
    column: $table.audioType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnFilters<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioFilesTableOrderingComposer
    extends Composer<_$UserDatabase, $AudioFilesTable> {
  $$AudioFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get audioKey => $composableBuilder(
    column: $table.audioKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioType => $composableBuilder(
    column: $table.audioType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnOrderings<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioFilesTableAnnotationComposer
    extends Composer<_$UserDatabase, $AudioFilesTable> {
  $$AudioFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get audioKey =>
      $composableBuilder(column: $table.audioKey, builder: (column) => column);

  GeneratedColumn<String> get audioType =>
      $composableBuilder(column: $table.audioType, builder: (column) => column);

  GeneratedColumn<int> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioFilesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AudioFilesTable,
          AudioFileRecord,
          $$AudioFilesTableFilterComposer,
          $$AudioFilesTableOrderingComposer,
          $$AudioFilesTableAnnotationComposer,
          $$AudioFilesTableCreateCompanionBuilder,
          $$AudioFilesTableUpdateCompanionBuilder,
          (
            AudioFileRecord,
            BaseReferences<_$UserDatabase, $AudioFilesTable, AudioFileRecord>,
          ),
          AudioFileRecord,
          PrefetchHooks Function()
        > {
  $$AudioFilesTableTableManager(_$UserDatabase db, $AudioFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> audioKey = const Value.absent(),
                Value<String> audioType = const Value.absent(),
                Value<int?> reciterId = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                Value<String> remoteUrl = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioFilesCompanion(
                audioKey: audioKey,
                audioType: audioType,
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                remoteUrl: remoteUrl,
                localPath: localPath,
                format: format,
                fileSize: fileSize,
                downloadedBytes: downloadedBytes,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String audioKey,
                required String audioType,
                Value<int?> reciterId = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                required String remoteUrl,
                Value<String?> localPath = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AudioFilesCompanion.insert(
                audioKey: audioKey,
                audioType: audioType,
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                remoteUrl: remoteUrl,
                localPath: localPath,
                format: format,
                fileSize: fileSize,
                downloadedBytes: downloadedBytes,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioFilesTable, AudioFileRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $AudioFilesTable,
                    AudioFileRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AudioFilesTable,
      AudioFileRecord,
      $$AudioFilesTableFilterComposer,
      $$AudioFilesTableOrderingComposer,
      $$AudioFilesTableAnnotationComposer,
      $$AudioFilesTableCreateCompanionBuilder,
      $$AudioFilesTableUpdateCompanionBuilder,
      (
        AudioFileRecord,
        BaseReferences<_$UserDatabase, $AudioFilesTable, AudioFileRecord>,
      ),
      AudioFileRecord,
      PrefetchHooks Function()
    >;
typedef $$AyahTimingsTableCreateCompanionBuilder =
    AyahTimingsCompanion Function({
      required int reciterId,
      required int surahNumber,
      required int ayahNumber,
      required String verseKey,
      required int startMs,
      required int endMs,
      Value<int> rowid,
    });
typedef $$AyahTimingsTableUpdateCompanionBuilder =
    AyahTimingsCompanion Function({
      Value<int> reciterId,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<String> verseKey,
      Value<int> startMs,
      Value<int> endMs,
      Value<int> rowid,
    });

class $$AyahTimingsTableFilterComposer
    extends Composer<_$UserDatabase, $AyahTimingsTable> {
  $$AyahTimingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyahTimingsTableOrderingComposer
    extends Composer<_$UserDatabase, $AyahTimingsTable> {
  $$AyahTimingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyahTimingsTableAnnotationComposer
    extends Composer<_$UserDatabase, $AyahTimingsTable> {
  $$AyahTimingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

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

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);
}

class $$AyahTimingsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AyahTimingsTable,
          AyahTimingRecord,
          $$AyahTimingsTableFilterComposer,
          $$AyahTimingsTableOrderingComposer,
          $$AyahTimingsTableAnnotationComposer,
          $$AyahTimingsTableCreateCompanionBuilder,
          $$AyahTimingsTableUpdateCompanionBuilder,
          (
            AyahTimingRecord,
            BaseReferences<_$UserDatabase, $AyahTimingsTable, AyahTimingRecord>,
          ),
          AyahTimingRecord,
          PrefetchHooks Function()
        > {
  $$AyahTimingsTableTableManager(_$UserDatabase db, $AyahTimingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahTimingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahTimingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahTimingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> reciterId = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahTimingsCompanion(
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                startMs: startMs,
                endMs: endMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int reciterId,
                required int surahNumber,
                required int ayahNumber,
                required String verseKey,
                required int startMs,
                required int endMs,
                Value<int> rowid = const Value.absent(),
              }) => AyahTimingsCompanion.insert(
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                startMs: startMs,
                endMs: endMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AyahTimingsTable, AyahTimingRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $AyahTimingsTable,
                    AyahTimingRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyahTimingsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AyahTimingsTable,
      AyahTimingRecord,
      $$AyahTimingsTableFilterComposer,
      $$AyahTimingsTableOrderingComposer,
      $$AyahTimingsTableAnnotationComposer,
      $$AyahTimingsTableCreateCompanionBuilder,
      $$AyahTimingsTableUpdateCompanionBuilder,
      (
        AyahTimingRecord,
        BaseReferences<_$UserDatabase, $AyahTimingsTable, AyahTimingRecord>,
      ),
      AyahTimingRecord,
      PrefetchHooks Function()
    >;
typedef $$WordTimingsTableCreateCompanionBuilder =
    WordTimingsCompanion Function({
      required int reciterId,
      required int surahNumber,
      required int ayahNumber,
      required int wordPosition,
      required int startMs,
      required int endMs,
      Value<int> rowid,
    });
typedef $$WordTimingsTableUpdateCompanionBuilder =
    WordTimingsCompanion Function({
      Value<int> reciterId,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<int> wordPosition,
      Value<int> startMs,
      Value<int> endMs,
      Value<int> rowid,
    });

class $$WordTimingsTableFilterComposer
    extends Composer<_$UserDatabase, $WordTimingsTable> {
  $$WordTimingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnFilters<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordTimingsTableOrderingComposer
    extends Composer<_$UserDatabase, $WordTimingsTable> {
  $$WordTimingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnOrderings<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordTimingsTableAnnotationComposer
    extends Composer<_$UserDatabase, $WordTimingsTable> {
  $$WordTimingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);
}

class $$WordTimingsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $WordTimingsTable,
          WordTimingRecord,
          $$WordTimingsTableFilterComposer,
          $$WordTimingsTableOrderingComposer,
          $$WordTimingsTableAnnotationComposer,
          $$WordTimingsTableCreateCompanionBuilder,
          $$WordTimingsTableUpdateCompanionBuilder,
          (
            WordTimingRecord,
            BaseReferences<_$UserDatabase, $WordTimingsTable, WordTimingRecord>,
          ),
          WordTimingRecord,
          PrefetchHooks Function()
        > {
  $$WordTimingsTableTableManager(_$UserDatabase db, $WordTimingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordTimingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordTimingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordTimingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> reciterId = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int> wordPosition = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordTimingsCompanion(
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                startMs: startMs,
                endMs: endMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int reciterId,
                required int surahNumber,
                required int ayahNumber,
                required int wordPosition,
                required int startMs,
                required int endMs,
                Value<int> rowid = const Value.absent(),
              }) => WordTimingsCompanion.insert(
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                startMs: startMs,
                endMs: endMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordTimingsTable, WordTimingRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $WordTimingsTable,
                    WordTimingRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordTimingsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $WordTimingsTable,
      WordTimingRecord,
      $$WordTimingsTableFilterComposer,
      $$WordTimingsTableOrderingComposer,
      $$WordTimingsTableAnnotationComposer,
      $$WordTimingsTableCreateCompanionBuilder,
      $$WordTimingsTableUpdateCompanionBuilder,
      (
        WordTimingRecord,
        BaseReferences<_$UserDatabase, $WordTimingsTable, WordTimingRecord>,
      ),
      WordTimingRecord,
      PrefetchHooks Function()
    >;
typedef $$DownloadJobsTableCreateCompanionBuilder =
    DownloadJobsCompanion Function({
      required String audioKey,
      required String audioType,
      required String remoteUrl,
      required String relativePath,
      required String status,
      Value<int> downloadedBytes,
      Value<int?> expectedBytes,
      Value<int?> reciterId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> wordPosition,
      Value<String?> format,
      Value<String?> localPath,
      Value<String?> errorCode,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadJobsTableUpdateCompanionBuilder =
    DownloadJobsCompanion Function({
      Value<String> audioKey,
      Value<String> audioType,
      Value<String> remoteUrl,
      Value<String> relativePath,
      Value<String> status,
      Value<int> downloadedBytes,
      Value<int?> expectedBytes,
      Value<int?> reciterId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> wordPosition,
      Value<String?> format,
      Value<String?> localPath,
      Value<String?> errorCode,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$DownloadJobsTableFilterComposer
    extends Composer<_$UserDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get audioKey => $composableBuilder(
    column: $table.audioKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioType => $composableBuilder(
    column: $table.audioType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedBytes => $composableBuilder(
    column: $table.expectedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnFilters<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadJobsTableOrderingComposer
    extends Composer<_$UserDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get audioKey => $composableBuilder(
    column: $table.audioKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioType => $composableBuilder(
    column: $table.audioType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedBytes => $composableBuilder(
    column: $table.expectedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
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

  ColumnOrderings<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadJobsTableAnnotationComposer
    extends Composer<_$UserDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get audioKey =>
      $composableBuilder(column: $table.audioKey, builder: (column) => column);

  GeneratedColumn<String> get audioType =>
      $composableBuilder(column: $table.audioType, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedBytes => $composableBuilder(
    column: $table.expectedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadJobsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $DownloadJobsTable,
          DownloadJobRecord,
          $$DownloadJobsTableFilterComposer,
          $$DownloadJobsTableOrderingComposer,
          $$DownloadJobsTableAnnotationComposer,
          $$DownloadJobsTableCreateCompanionBuilder,
          $$DownloadJobsTableUpdateCompanionBuilder,
          (
            DownloadJobRecord,
            BaseReferences<
              _$UserDatabase,
              $DownloadJobsTable,
              DownloadJobRecord
            >,
          ),
          DownloadJobRecord,
          PrefetchHooks Function()
        > {
  $$DownloadJobsTableTableManager(_$UserDatabase db, $DownloadJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> audioKey = const Value.absent(),
                Value<String> audioType = const Value.absent(),
                Value<String> remoteUrl = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int?> expectedBytes = const Value.absent(),
                Value<int?> reciterId = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion(
                audioKey: audioKey,
                audioType: audioType,
                remoteUrl: remoteUrl,
                relativePath: relativePath,
                status: status,
                downloadedBytes: downloadedBytes,
                expectedBytes: expectedBytes,
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                format: format,
                localPath: localPath,
                errorCode: errorCode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String audioKey,
                required String audioType,
                required String remoteUrl,
                required String relativePath,
                required String status,
                Value<int> downloadedBytes = const Value.absent(),
                Value<int?> expectedBytes = const Value.absent(),
                Value<int?> reciterId = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion.insert(
                audioKey: audioKey,
                audioType: audioType,
                remoteUrl: remoteUrl,
                relativePath: relativePath,
                status: status,
                downloadedBytes: downloadedBytes,
                expectedBytes: expectedBytes,
                reciterId: reciterId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                format: format,
                localPath: localPath,
                errorCode: errorCode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadJobsTable, DownloadJobRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $DownloadJobsTable,
                    DownloadJobRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $DownloadJobsTable,
      DownloadJobRecord,
      $$DownloadJobsTableFilterComposer,
      $$DownloadJobsTableOrderingComposer,
      $$DownloadJobsTableAnnotationComposer,
      $$DownloadJobsTableCreateCompanionBuilder,
      $$DownloadJobsTableUpdateCompanionBuilder,
      (
        DownloadJobRecord,
        BaseReferences<_$UserDatabase, $DownloadJobsTable, DownloadJobRecord>,
      ),
      DownloadJobRecord,
      PrefetchHooks Function()
    >;
typedef $$HifzProgressEntriesTableCreateCompanionBuilder =
    HifzProgressEntriesCompanion Function({
      required String profileKey,
      required int surahNumber,
      required int ayahNumber,
      required String status,
      Value<int> strengthScore,
      Value<int> reviewCount,
      Value<int> mistakeCount,
      Value<int> revisionIntervalIndex,
      Value<DateTime?> startedAt,
      Value<DateTime?> memorizedAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<int> rowid,
    });
typedef $$HifzProgressEntriesTableUpdateCompanionBuilder =
    HifzProgressEntriesCompanion Function({
      Value<String> profileKey,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<String> status,
      Value<int> strengthScore,
      Value<int> reviewCount,
      Value<int> mistakeCount,
      Value<int> revisionIntervalIndex,
      Value<DateTime?> startedAt,
      Value<DateTime?> memorizedAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<int> rowid,
    });

class $$HifzProgressEntriesTableFilterComposer
    extends Composer<_$UserDatabase, $HifzProgressEntriesTable> {
  $$HifzProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strengthScore => $composableBuilder(
    column: $table.strengthScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionIntervalIndex => $composableBuilder(
    column: $table.revisionIntervalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get memorizedAt => $composableBuilder(
    column: $table.memorizedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HifzProgressEntriesTableOrderingComposer
    extends Composer<_$UserDatabase, $HifzProgressEntriesTable> {
  $$HifzProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strengthScore => $composableBuilder(
    column: $table.strengthScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionIntervalIndex => $composableBuilder(
    column: $table.revisionIntervalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get memorizedAt => $composableBuilder(
    column: $table.memorizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HifzProgressEntriesTableAnnotationComposer
    extends Composer<_$UserDatabase, $HifzProgressEntriesTable> {
  $$HifzProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get strengthScore => $composableBuilder(
    column: $table.strengthScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revisionIntervalIndex => $composableBuilder(
    column: $table.revisionIntervalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get memorizedAt => $composableBuilder(
    column: $table.memorizedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$HifzProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $HifzProgressEntriesTable,
          HifzProgressRow,
          $$HifzProgressEntriesTableFilterComposer,
          $$HifzProgressEntriesTableOrderingComposer,
          $$HifzProgressEntriesTableAnnotationComposer,
          $$HifzProgressEntriesTableCreateCompanionBuilder,
          $$HifzProgressEntriesTableUpdateCompanionBuilder,
          (
            HifzProgressRow,
            BaseReferences<
              _$UserDatabase,
              $HifzProgressEntriesTable,
              HifzProgressRow
            >,
          ),
          HifzProgressRow,
          PrefetchHooks Function()
        > {
  $$HifzProgressEntriesTableTableManager(
    _$UserDatabase db,
    $HifzProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HifzProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HifzProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HifzProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> strengthScore = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> mistakeCount = const Value.absent(),
                Value<int> revisionIntervalIndex = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> memorizedAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HifzProgressEntriesCompanion(
                profileKey: profileKey,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                status: status,
                strengthScore: strengthScore,
                reviewCount: reviewCount,
                mistakeCount: mistakeCount,
                revisionIntervalIndex: revisionIntervalIndex,
                startedAt: startedAt,
                memorizedAt: memorizedAt,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required int surahNumber,
                required int ayahNumber,
                required String status,
                Value<int> strengthScore = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> mistakeCount = const Value.absent(),
                Value<int> revisionIntervalIndex = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> memorizedAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HifzProgressEntriesCompanion.insert(
                profileKey: profileKey,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                status: status,
                strengthScore: strengthScore,
                reviewCount: reviewCount,
                mistakeCount: mistakeCount,
                revisionIntervalIndex: revisionIntervalIndex,
                startedAt: startedAt,
                memorizedAt: memorizedAt,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HifzProgressEntriesTable, HifzProgressRow>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    $HifzProgressEntriesTable,
                    HifzProgressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HifzProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $HifzProgressEntriesTable,
      HifzProgressRow,
      $$HifzProgressEntriesTableFilterComposer,
      $$HifzProgressEntriesTableOrderingComposer,
      $$HifzProgressEntriesTableAnnotationComposer,
      $$HifzProgressEntriesTableCreateCompanionBuilder,
      $$HifzProgressEntriesTableUpdateCompanionBuilder,
      (
        HifzProgressRow,
        BaseReferences<
          _$UserDatabase,
          $HifzProgressEntriesTable,
          HifzProgressRow
        >,
      ),
      HifzProgressRow,
      PrefetchHooks Function()
    >;
typedef $$HifzReviewHistoryRowsTableCreateCompanionBuilder =
    HifzReviewHistoryRowsCompanion Function({
      Value<int> id,
      required String profileKey,
      required int surahNumber,
      required int ayahNumber,
      required DateTime reviewedAt,
      required String result,
      required String previousStatus,
      required String newStatus,
      required int previousIntervalIndex,
      required int newIntervalIndex,
      required int previousStrengthScore,
      required int newStrengthScore,
      required DateTime nextReviewAt,
    });
typedef $$HifzReviewHistoryRowsTableUpdateCompanionBuilder =
    HifzReviewHistoryRowsCompanion Function({
      Value<int> id,
      Value<String> profileKey,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<DateTime> reviewedAt,
      Value<String> result,
      Value<String> previousStatus,
      Value<String> newStatus,
      Value<int> previousIntervalIndex,
      Value<int> newIntervalIndex,
      Value<int> previousStrengthScore,
      Value<int> newStrengthScore,
      Value<DateTime> nextReviewAt,
    });

class $$HifzReviewHistoryRowsTableFilterComposer
    extends Composer<_$UserDatabase, $HifzReviewHistoryRowsTable> {
  $$HifzReviewHistoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousIntervalIndex => $composableBuilder(
    column: $table.previousIntervalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newIntervalIndex => $composableBuilder(
    column: $table.newIntervalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousStrengthScore => $composableBuilder(
    column: $table.previousStrengthScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newStrengthScore => $composableBuilder(
    column: $table.newStrengthScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HifzReviewHistoryRowsTableOrderingComposer
    extends Composer<_$UserDatabase, $HifzReviewHistoryRowsTable> {
  $$HifzReviewHistoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousIntervalIndex => $composableBuilder(
    column: $table.previousIntervalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newIntervalIndex => $composableBuilder(
    column: $table.newIntervalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousStrengthScore => $composableBuilder(
    column: $table.previousStrengthScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newStrengthScore => $composableBuilder(
    column: $table.newStrengthScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HifzReviewHistoryRowsTableAnnotationComposer
    extends Composer<_$UserDatabase, $HifzReviewHistoryRowsTable> {
  $$HifzReviewHistoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
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

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newStatus =>
      $composableBuilder(column: $table.newStatus, builder: (column) => column);

  GeneratedColumn<int> get previousIntervalIndex => $composableBuilder(
    column: $table.previousIntervalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newIntervalIndex => $composableBuilder(
    column: $table.newIntervalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousStrengthScore => $composableBuilder(
    column: $table.previousStrengthScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newStrengthScore => $composableBuilder(
    column: $table.newStrengthScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$HifzReviewHistoryRowsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $HifzReviewHistoryRowsTable,
          HifzReviewHistoryRow,
          $$HifzReviewHistoryRowsTableFilterComposer,
          $$HifzReviewHistoryRowsTableOrderingComposer,
          $$HifzReviewHistoryRowsTableAnnotationComposer,
          $$HifzReviewHistoryRowsTableCreateCompanionBuilder,
          $$HifzReviewHistoryRowsTableUpdateCompanionBuilder,
          (
            HifzReviewHistoryRow,
            BaseReferences<
              _$UserDatabase,
              $HifzReviewHistoryRowsTable,
              HifzReviewHistoryRow
            >,
          ),
          HifzReviewHistoryRow,
          PrefetchHooks Function()
        > {
  $$HifzReviewHistoryRowsTableTableManager(
    _$UserDatabase db,
    $HifzReviewHistoryRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HifzReviewHistoryRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HifzReviewHistoryRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HifzReviewHistoryRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileKey = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> previousStatus = const Value.absent(),
                Value<String> newStatus = const Value.absent(),
                Value<int> previousIntervalIndex = const Value.absent(),
                Value<int> newIntervalIndex = const Value.absent(),
                Value<int> previousStrengthScore = const Value.absent(),
                Value<int> newStrengthScore = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
              }) => HifzReviewHistoryRowsCompanion(
                id: id,
                profileKey: profileKey,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                reviewedAt: reviewedAt,
                result: result,
                previousStatus: previousStatus,
                newStatus: newStatus,
                previousIntervalIndex: previousIntervalIndex,
                newIntervalIndex: newIntervalIndex,
                previousStrengthScore: previousStrengthScore,
                newStrengthScore: newStrengthScore,
                nextReviewAt: nextReviewAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileKey,
                required int surahNumber,
                required int ayahNumber,
                required DateTime reviewedAt,
                required String result,
                required String previousStatus,
                required String newStatus,
                required int previousIntervalIndex,
                required int newIntervalIndex,
                required int previousStrengthScore,
                required int newStrengthScore,
                required DateTime nextReviewAt,
              }) => HifzReviewHistoryRowsCompanion.insert(
                id: id,
                profileKey: profileKey,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                reviewedAt: reviewedAt,
                result: result,
                previousStatus: previousStatus,
                newStatus: newStatus,
                previousIntervalIndex: previousIntervalIndex,
                newIntervalIndex: newIntervalIndex,
                previousStrengthScore: previousStrengthScore,
                newStrengthScore: newStrengthScore,
                nextReviewAt: nextReviewAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $HifzReviewHistoryRowsTable,
                    HifzReviewHistoryRow
                  >(table),
                  BaseReferences<
                    _$UserDatabase,
                    $HifzReviewHistoryRowsTable,
                    HifzReviewHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HifzReviewHistoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $HifzReviewHistoryRowsTable,
      HifzReviewHistoryRow,
      $$HifzReviewHistoryRowsTableFilterComposer,
      $$HifzReviewHistoryRowsTableOrderingComposer,
      $$HifzReviewHistoryRowsTableAnnotationComposer,
      $$HifzReviewHistoryRowsTableCreateCompanionBuilder,
      $$HifzReviewHistoryRowsTableUpdateCompanionBuilder,
      (
        HifzReviewHistoryRow,
        BaseReferences<
          _$UserDatabase,
          $HifzReviewHistoryRowsTable,
          HifzReviewHistoryRow
        >,
      ),
      HifzReviewHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$HifzSessionCheckpointsTableCreateCompanionBuilder =
    HifzSessionCheckpointsCompanion Function({
      required String profileKey,
      required int startSurah,
      required int startAyah,
      required int endSurah,
      required int endAyah,
      required String presetId,
      Value<int> nextStepIndex,
      required String status,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HifzSessionCheckpointsTableUpdateCompanionBuilder =
    HifzSessionCheckpointsCompanion Function({
      Value<String> profileKey,
      Value<int> startSurah,
      Value<int> startAyah,
      Value<int> endSurah,
      Value<int> endAyah,
      Value<String> presetId,
      Value<int> nextStepIndex,
      Value<String> status,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HifzSessionCheckpointsTableFilterComposer
    extends Composer<_$UserDatabase, $HifzSessionCheckpointsTable> {
  $$HifzSessionCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextStepIndex => $composableBuilder(
    column: $table.nextStepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HifzSessionCheckpointsTableOrderingComposer
    extends Composer<_$UserDatabase, $HifzSessionCheckpointsTable> {
  $$HifzSessionCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextStepIndex => $composableBuilder(
    column: $table.nextStepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HifzSessionCheckpointsTableAnnotationComposer
    extends Composer<_$UserDatabase, $HifzSessionCheckpointsTable> {
  $$HifzSessionCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAyah =>
      $composableBuilder(column: $table.startAyah, builder: (column) => column);

  GeneratedColumn<int> get endSurah =>
      $composableBuilder(column: $table.endSurah, builder: (column) => column);

  GeneratedColumn<int> get endAyah =>
      $composableBuilder(column: $table.endAyah, builder: (column) => column);

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<int> get nextStepIndex => $composableBuilder(
    column: $table.nextStepIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HifzSessionCheckpointsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $HifzSessionCheckpointsTable,
          HifzSessionCheckpointRow,
          $$HifzSessionCheckpointsTableFilterComposer,
          $$HifzSessionCheckpointsTableOrderingComposer,
          $$HifzSessionCheckpointsTableAnnotationComposer,
          $$HifzSessionCheckpointsTableCreateCompanionBuilder,
          $$HifzSessionCheckpointsTableUpdateCompanionBuilder,
          (
            HifzSessionCheckpointRow,
            BaseReferences<
              _$UserDatabase,
              $HifzSessionCheckpointsTable,
              HifzSessionCheckpointRow
            >,
          ),
          HifzSessionCheckpointRow,
          PrefetchHooks Function()
        > {
  $$HifzSessionCheckpointsTableTableManager(
    _$UserDatabase db,
    $HifzSessionCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HifzSessionCheckpointsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HifzSessionCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HifzSessionCheckpointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<int> startSurah = const Value.absent(),
                Value<int> startAyah = const Value.absent(),
                Value<int> endSurah = const Value.absent(),
                Value<int> endAyah = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<int> nextStepIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HifzSessionCheckpointsCompanion(
                profileKey: profileKey,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                presetId: presetId,
                nextStepIndex: nextStepIndex,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required int startSurah,
                required int startAyah,
                required int endSurah,
                required int endAyah,
                required String presetId,
                Value<int> nextStepIndex = const Value.absent(),
                required String status,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HifzSessionCheckpointsCompanion.insert(
                profileKey: profileKey,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                presetId: presetId,
                nextStepIndex: nextStepIndex,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $HifzSessionCheckpointsTable,
                    HifzSessionCheckpointRow
                  >(table),
                  BaseReferences<
                    _$UserDatabase,
                    $HifzSessionCheckpointsTable,
                    HifzSessionCheckpointRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HifzSessionCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $HifzSessionCheckpointsTable,
      HifzSessionCheckpointRow,
      $$HifzSessionCheckpointsTableFilterComposer,
      $$HifzSessionCheckpointsTableOrderingComposer,
      $$HifzSessionCheckpointsTableAnnotationComposer,
      $$HifzSessionCheckpointsTableCreateCompanionBuilder,
      $$HifzSessionCheckpointsTableUpdateCompanionBuilder,
      (
        HifzSessionCheckpointRow,
        BaseReferences<
          _$UserDatabase,
          $HifzSessionCheckpointsTable,
          HifzSessionCheckpointRow
        >,
      ),
      HifzSessionCheckpointRow,
      PrefetchHooks Function()
    >;
typedef $$HifzPlansTableCreateCompanionBuilder =
    HifzPlansCompanion Function({
      Value<int> id,
      required String profileKey,
      required String title,
      required int startSurah,
      required int startAyah,
      required int endSurah,
      required int endAyah,
      required int startPage,
      required String presetId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$HifzPlansTableUpdateCompanionBuilder =
    HifzPlansCompanion Function({
      Value<int> id,
      Value<String> profileKey,
      Value<String> title,
      Value<int> startSurah,
      Value<int> startAyah,
      Value<int> endSurah,
      Value<int> endAyah,
      Value<int> startPage,
      Value<String> presetId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$HifzPlansTableFilterComposer
    extends Composer<_$UserDatabase, $HifzPlansTable> {
  $$HifzPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HifzPlansTableOrderingComposer
    extends Composer<_$UserDatabase, $HifzPlansTable> {
  $$HifzPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HifzPlansTableAnnotationComposer
    extends Composer<_$UserDatabase, $HifzPlansTable> {
  $$HifzPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAyah =>
      $composableBuilder(column: $table.startAyah, builder: (column) => column);

  GeneratedColumn<int> get endSurah =>
      $composableBuilder(column: $table.endSurah, builder: (column) => column);

  GeneratedColumn<int> get endAyah =>
      $composableBuilder(column: $table.endAyah, builder: (column) => column);

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HifzPlansTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $HifzPlansTable,
          HifzPlanRow,
          $$HifzPlansTableFilterComposer,
          $$HifzPlansTableOrderingComposer,
          $$HifzPlansTableAnnotationComposer,
          $$HifzPlansTableCreateCompanionBuilder,
          $$HifzPlansTableUpdateCompanionBuilder,
          (
            HifzPlanRow,
            BaseReferences<_$UserDatabase, $HifzPlansTable, HifzPlanRow>,
          ),
          HifzPlanRow,
          PrefetchHooks Function()
        > {
  $$HifzPlansTableTableManager(_$UserDatabase db, $HifzPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HifzPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HifzPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HifzPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startSurah = const Value.absent(),
                Value<int> startAyah = const Value.absent(),
                Value<int> endSurah = const Value.absent(),
                Value<int> endAyah = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HifzPlansCompanion(
                id: id,
                profileKey: profileKey,
                title: title,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                startPage: startPage,
                presetId: presetId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileKey,
                required String title,
                required int startSurah,
                required int startAyah,
                required int endSurah,
                required int endAyah,
                required int startPage,
                required String presetId,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => HifzPlansCompanion.insert(
                id: id,
                profileKey: profileKey,
                title: title,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                startPage: startPage,
                presetId: presetId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HifzPlansTable, HifzPlanRow>(table),
                  BaseReferences<_$UserDatabase, $HifzPlansTable, HifzPlanRow>(
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

typedef $$HifzPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $HifzPlansTable,
      HifzPlanRow,
      $$HifzPlansTableFilterComposer,
      $$HifzPlansTableOrderingComposer,
      $$HifzPlansTableAnnotationComposer,
      $$HifzPlansTableCreateCompanionBuilder,
      $$HifzPlansTableUpdateCompanionBuilder,
      (
        HifzPlanRow,
        BaseReferences<_$UserDatabase, $HifzPlansTable, HifzPlanRow>,
      ),
      HifzPlanRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      required String syncKey,
      Value<String?> syncToken,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<String> syncKey,
      Value<String?> syncToken,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$UserDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncKey => $composableBuilder(
    column: $table.syncKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncToken => $composableBuilder(
    column: $table.syncToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$UserDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncKey => $composableBuilder(
    column: $table.syncKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncToken => $composableBuilder(
    column: $table.syncToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$UserDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncKey =>
      $composableBuilder(column: $table.syncKey, builder: (column) => column);

  GeneratedColumn<String> get syncToken =>
      $composableBuilder(column: $table.syncToken, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SyncStatesTable,
          SyncStateRecord,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncStateRecord,
            BaseReferences<_$UserDatabase, $SyncStatesTable, SyncStateRecord>,
          ),
          SyncStateRecord,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$UserDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncKey = const Value.absent(),
                Value<String?> syncToken = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                syncKey: syncKey,
                syncToken: syncToken,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncKey,
                Value<String?> syncToken = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                syncKey: syncKey,
                syncToken: syncToken,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncStateRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $SyncStatesTable,
                    SyncStateRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SyncStatesTable,
      SyncStateRecord,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (
        SyncStateRecord,
        BaseReferences<_$UserDatabase, $SyncStatesTable, SyncStateRecord>,
      ),
      SyncStateRecord,
      PrefetchHooks Function()
    >;
typedef $$ReadingPageVisitsTableCreateCompanionBuilder =
    ReadingPageVisitsCompanion Function({
      required String profileKey,
      required String dayKey,
      required int pageNumber,
      required DateTime readAt,
      Value<int> rowid,
    });
typedef $$ReadingPageVisitsTableUpdateCompanionBuilder =
    ReadingPageVisitsCompanion Function({
      Value<String> profileKey,
      Value<String> dayKey,
      Value<int> pageNumber,
      Value<DateTime> readAt,
      Value<int> rowid,
    });

class $$ReadingPageVisitsTableFilterComposer
    extends Composer<_$UserDatabase, $ReadingPageVisitsTable> {
  $$ReadingPageVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingPageVisitsTableOrderingComposer
    extends Composer<_$UserDatabase, $ReadingPageVisitsTable> {
  $$ReadingPageVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingPageVisitsTableAnnotationComposer
    extends Composer<_$UserDatabase, $ReadingPageVisitsTable> {
  $$ReadingPageVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ReadingPageVisitsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadingPageVisitsTable,
          ReadingPageVisitRow,
          $$ReadingPageVisitsTableFilterComposer,
          $$ReadingPageVisitsTableOrderingComposer,
          $$ReadingPageVisitsTableAnnotationComposer,
          $$ReadingPageVisitsTableCreateCompanionBuilder,
          $$ReadingPageVisitsTableUpdateCompanionBuilder,
          (
            ReadingPageVisitRow,
            BaseReferences<
              _$UserDatabase,
              $ReadingPageVisitsTable,
              ReadingPageVisitRow
            >,
          ),
          ReadingPageVisitRow,
          PrefetchHooks Function()
        > {
  $$ReadingPageVisitsTableTableManager(
    _$UserDatabase db,
    $ReadingPageVisitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingPageVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingPageVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingPageVisitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingPageVisitsCompanion(
                profileKey: profileKey,
                dayKey: dayKey,
                pageNumber: pageNumber,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required String dayKey,
                required int pageNumber,
                required DateTime readAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingPageVisitsCompanion.insert(
                profileKey: profileKey,
                dayKey: dayKey,
                pageNumber: pageNumber,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingPageVisitsTable, ReadingPageVisitRow>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    $ReadingPageVisitsTable,
                    ReadingPageVisitRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingPageVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadingPageVisitsTable,
      ReadingPageVisitRow,
      $$ReadingPageVisitsTableFilterComposer,
      $$ReadingPageVisitsTableOrderingComposer,
      $$ReadingPageVisitsTableAnnotationComposer,
      $$ReadingPageVisitsTableCreateCompanionBuilder,
      $$ReadingPageVisitsTableUpdateCompanionBuilder,
      (
        ReadingPageVisitRow,
        BaseReferences<
          _$UserDatabase,
          $ReadingPageVisitsTable,
          ReadingPageVisitRow
        >,
      ),
      ReadingPageVisitRow,
      PrefetchHooks Function()
    >;
typedef $$DailyGoalsTableCreateCompanionBuilder =
    DailyGoalsCompanion Function({
      required String profileKey,
      required String dayKey,
      Value<int> newHifzAyahsTarget,
      Value<int> revisionAyahsTarget,
      Value<int> readingPagesTarget,
      Value<int> rowid,
    });
typedef $$DailyGoalsTableUpdateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<String> profileKey,
      Value<String> dayKey,
      Value<int> newHifzAyahsTarget,
      Value<int> revisionAyahsTarget,
      Value<int> readingPagesTarget,
      Value<int> rowid,
    });

class $$DailyGoalsTableFilterComposer
    extends Composer<_$UserDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newHifzAyahsTarget => $composableBuilder(
    column: $table.newHifzAyahsTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionAyahsTarget => $composableBuilder(
    column: $table.revisionAyahsTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingPagesTarget => $composableBuilder(
    column: $table.readingPagesTarget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyGoalsTableOrderingComposer
    extends Composer<_$UserDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newHifzAyahsTarget => $composableBuilder(
    column: $table.newHifzAyahsTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionAyahsTarget => $composableBuilder(
    column: $table.revisionAyahsTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingPagesTarget => $composableBuilder(
    column: $table.readingPagesTarget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyGoalsTableAnnotationComposer
    extends Composer<_$UserDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get newHifzAyahsTarget => $composableBuilder(
    column: $table.newHifzAyahsTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revisionAyahsTarget => $composableBuilder(
    column: $table.revisionAyahsTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readingPagesTarget => $composableBuilder(
    column: $table.readingPagesTarget,
    builder: (column) => column,
  );
}

class $$DailyGoalsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $DailyGoalsTable,
          DailyGoalRow,
          $$DailyGoalsTableFilterComposer,
          $$DailyGoalsTableOrderingComposer,
          $$DailyGoalsTableAnnotationComposer,
          $$DailyGoalsTableCreateCompanionBuilder,
          $$DailyGoalsTableUpdateCompanionBuilder,
          (
            DailyGoalRow,
            BaseReferences<_$UserDatabase, $DailyGoalsTable, DailyGoalRow>,
          ),
          DailyGoalRow,
          PrefetchHooks Function()
        > {
  $$DailyGoalsTableTableManager(_$UserDatabase db, $DailyGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<int> newHifzAyahsTarget = const Value.absent(),
                Value<int> revisionAyahsTarget = const Value.absent(),
                Value<int> readingPagesTarget = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyGoalsCompanion(
                profileKey: profileKey,
                dayKey: dayKey,
                newHifzAyahsTarget: newHifzAyahsTarget,
                revisionAyahsTarget: revisionAyahsTarget,
                readingPagesTarget: readingPagesTarget,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required String dayKey,
                Value<int> newHifzAyahsTarget = const Value.absent(),
                Value<int> revisionAyahsTarget = const Value.absent(),
                Value<int> readingPagesTarget = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyGoalsCompanion.insert(
                profileKey: profileKey,
                dayKey: dayKey,
                newHifzAyahsTarget: newHifzAyahsTarget,
                revisionAyahsTarget: revisionAyahsTarget,
                readingPagesTarget: readingPagesTarget,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyGoalsTable, DailyGoalRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $DailyGoalsTable,
                    DailyGoalRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $DailyGoalsTable,
      DailyGoalRow,
      $$DailyGoalsTableFilterComposer,
      $$DailyGoalsTableOrderingComposer,
      $$DailyGoalsTableAnnotationComposer,
      $$DailyGoalsTableCreateCompanionBuilder,
      $$DailyGoalsTableUpdateCompanionBuilder,
      (
        DailyGoalRow,
        BaseReferences<_$UserDatabase, $DailyGoalsTable, DailyGoalRow>,
      ),
      DailyGoalRow,
      PrefetchHooks Function()
    >;
typedef $$StudyBookmarksTableCreateCompanionBuilder =
    StudyBookmarksCompanion Function({
      required String profileKey,
      required String targetKey,
      required String targetType,
      required int surahNumber,
      required int ayahNumber,
      Value<int?> wordPosition,
      required String category,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StudyBookmarksTableUpdateCompanionBuilder =
    StudyBookmarksCompanion Function({
      Value<String> profileKey,
      Value<String> targetKey,
      Value<String> targetType,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<int?> wordPosition,
      Value<String> category,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StudyBookmarksTableFilterComposer
    extends Composer<_$UserDatabase, $StudyBookmarksTable> {
  $$StudyBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  ColumnFilters<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyBookmarksTableOrderingComposer
    extends Composer<_$UserDatabase, $StudyBookmarksTable> {
  $$StudyBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  ColumnOrderings<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyBookmarksTableAnnotationComposer
    extends Composer<_$UserDatabase, $StudyBookmarksTable> {
  $$StudyBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetKey =>
      $composableBuilder(column: $table.targetKey, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  GeneratedColumn<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudyBookmarksTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $StudyBookmarksTable,
          StudyBookmarkRow,
          $$StudyBookmarksTableFilterComposer,
          $$StudyBookmarksTableOrderingComposer,
          $$StudyBookmarksTableAnnotationComposer,
          $$StudyBookmarksTableCreateCompanionBuilder,
          $$StudyBookmarksTableUpdateCompanionBuilder,
          (
            StudyBookmarkRow,
            BaseReferences<
              _$UserDatabase,
              $StudyBookmarksTable,
              StudyBookmarkRow
            >,
          ),
          StudyBookmarkRow,
          PrefetchHooks Function()
        > {
  $$StudyBookmarksTableTableManager(
    _$UserDatabase db,
    $StudyBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<String> targetKey = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyBookmarksCompanion(
                profileKey: profileKey,
                targetKey: targetKey,
                targetType: targetType,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                category: category,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required String targetKey,
                required String targetType,
                required int surahNumber,
                required int ayahNumber,
                Value<int?> wordPosition = const Value.absent(),
                required String category,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyBookmarksCompanion.insert(
                profileKey: profileKey,
                targetKey: targetKey,
                targetType: targetType,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                category: category,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyBookmarksTable, StudyBookmarkRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $StudyBookmarksTable,
                    StudyBookmarkRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $StudyBookmarksTable,
      StudyBookmarkRow,
      $$StudyBookmarksTableFilterComposer,
      $$StudyBookmarksTableOrderingComposer,
      $$StudyBookmarksTableAnnotationComposer,
      $$StudyBookmarksTableCreateCompanionBuilder,
      $$StudyBookmarksTableUpdateCompanionBuilder,
      (
        StudyBookmarkRow,
        BaseReferences<_$UserDatabase, $StudyBookmarksTable, StudyBookmarkRow>,
      ),
      StudyBookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$StudyNotesTableCreateCompanionBuilder =
    StudyNotesCompanion Function({
      required String profileKey,
      required String targetKey,
      required String targetType,
      required int surahNumber,
      required int ayahNumber,
      Value<int?> wordPosition,
      required String noteText,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StudyNotesTableUpdateCompanionBuilder =
    StudyNotesCompanion Function({
      Value<String> profileKey,
      Value<String> targetKey,
      Value<String> targetType,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<int?> wordPosition,
      Value<String> noteText,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StudyNotesTableFilterComposer
    extends Composer<_$UserDatabase, $StudyNotesTable> {
  $$StudyNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  ColumnFilters<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyNotesTableOrderingComposer
    extends Composer<_$UserDatabase, $StudyNotesTable> {
  $$StudyNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  ColumnOrderings<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyNotesTableAnnotationComposer
    extends Composer<_$UserDatabase, $StudyNotesTable> {
  $$StudyNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetKey =>
      $composableBuilder(column: $table.targetKey, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
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

  GeneratedColumn<int> get wordPosition => $composableBuilder(
    column: $table.wordPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudyNotesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $StudyNotesTable,
          StudyNoteRow,
          $$StudyNotesTableFilterComposer,
          $$StudyNotesTableOrderingComposer,
          $$StudyNotesTableAnnotationComposer,
          $$StudyNotesTableCreateCompanionBuilder,
          $$StudyNotesTableUpdateCompanionBuilder,
          (
            StudyNoteRow,
            BaseReferences<_$UserDatabase, $StudyNotesTable, StudyNoteRow>,
          ),
          StudyNoteRow,
          PrefetchHooks Function()
        > {
  $$StudyNotesTableTableManager(_$UserDatabase db, $StudyNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<String> targetKey = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int?> wordPosition = const Value.absent(),
                Value<String> noteText = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyNotesCompanion(
                profileKey: profileKey,
                targetKey: targetKey,
                targetType: targetType,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                noteText: noteText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required String targetKey,
                required String targetType,
                required int surahNumber,
                required int ayahNumber,
                Value<int?> wordPosition = const Value.absent(),
                required String noteText,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyNotesCompanion.insert(
                profileKey: profileKey,
                targetKey: targetKey,
                targetType: targetType,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                wordPosition: wordPosition,
                noteText: noteText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyNotesTable, StudyNoteRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $StudyNotesTable,
                    StudyNoteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $StudyNotesTable,
      StudyNoteRow,
      $$StudyNotesTableFilterComposer,
      $$StudyNotesTableOrderingComposer,
      $$StudyNotesTableAnnotationComposer,
      $$StudyNotesTableCreateCompanionBuilder,
      $$StudyNotesTableUpdateCompanionBuilder,
      (
        StudyNoteRow,
        BaseReferences<_$UserDatabase, $StudyNotesTable, StudyNoteRow>,
      ),
      StudyNoteRow,
      PrefetchHooks Function()
    >;
typedef $$InstalledTafsirPackagesTableCreateCompanionBuilder =
    InstalledTafsirPackagesCompanion Function({
      required String sourceId,
      required String name,
      required String language,
      required String version,
      required String localPath,
      required String sha256,
      Value<String?> attribution,
      Value<String?> license,
      required DateTime installedAt,
      Value<int> rowid,
    });
typedef $$InstalledTafsirPackagesTableUpdateCompanionBuilder =
    InstalledTafsirPackagesCompanion Function({
      Value<String> sourceId,
      Value<String> name,
      Value<String> language,
      Value<String> version,
      Value<String> localPath,
      Value<String> sha256,
      Value<String?> attribution,
      Value<String?> license,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });

class $$InstalledTafsirPackagesTableFilterComposer
    extends Composer<_$UserDatabase, $InstalledTafsirPackagesTable> {
  $$InstalledTafsirPackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledTafsirPackagesTableOrderingComposer
    extends Composer<_$UserDatabase, $InstalledTafsirPackagesTable> {
  $$InstalledTafsirPackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledTafsirPackagesTableAnnotationComposer
    extends Composer<_$UserDatabase, $InstalledTafsirPackagesTable> {
  $$InstalledTafsirPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$InstalledTafsirPackagesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $InstalledTafsirPackagesTable,
          InstalledTafsirPackageRecord,
          $$InstalledTafsirPackagesTableFilterComposer,
          $$InstalledTafsirPackagesTableOrderingComposer,
          $$InstalledTafsirPackagesTableAnnotationComposer,
          $$InstalledTafsirPackagesTableCreateCompanionBuilder,
          $$InstalledTafsirPackagesTableUpdateCompanionBuilder,
          (
            InstalledTafsirPackageRecord,
            BaseReferences<
              _$UserDatabase,
              $InstalledTafsirPackagesTable,
              InstalledTafsirPackageRecord
            >,
          ),
          InstalledTafsirPackageRecord,
          PrefetchHooks Function()
        > {
  $$InstalledTafsirPackagesTableTableManager(
    _$UserDatabase db,
    $InstalledTafsirPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledTafsirPackagesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstalledTafsirPackagesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstalledTafsirPackagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledTafsirPackagesCompanion(
                sourceId: sourceId,
                name: name,
                language: language,
                version: version,
                localPath: localPath,
                sha256: sha256,
                attribution: attribution,
                license: license,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String name,
                required String language,
                required String version,
                required String localPath,
                required String sha256,
                Value<String?> attribution = const Value.absent(),
                Value<String?> license = const Value.absent(),
                required DateTime installedAt,
                Value<int> rowid = const Value.absent(),
              }) => InstalledTafsirPackagesCompanion.insert(
                sourceId: sourceId,
                name: name,
                language: language,
                version: version,
                localPath: localPath,
                sha256: sha256,
                attribution: attribution,
                license: license,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $InstalledTafsirPackagesTable,
                    InstalledTafsirPackageRecord
                  >(table),
                  BaseReferences<
                    _$UserDatabase,
                    $InstalledTafsirPackagesTable,
                    InstalledTafsirPackageRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledTafsirPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $InstalledTafsirPackagesTable,
      InstalledTafsirPackageRecord,
      $$InstalledTafsirPackagesTableFilterComposer,
      $$InstalledTafsirPackagesTableOrderingComposer,
      $$InstalledTafsirPackagesTableAnnotationComposer,
      $$InstalledTafsirPackagesTableCreateCompanionBuilder,
      $$InstalledTafsirPackagesTableUpdateCompanionBuilder,
      (
        InstalledTafsirPackageRecord,
        BaseReferences<
          _$UserDatabase,
          $InstalledTafsirPackagesTable,
          InstalledTafsirPackageRecord
        >,
      ),
      InstalledTafsirPackageRecord,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      required String profileKey,
      required int lastSurah,
      required int lastAyah,
      required int lastPage,
      Value<DateTime?> lastReadAt,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<String> profileKey,
      Value<int> lastSurah,
      Value<int> lastAyah,
      Value<int> lastPage,
      Value<DateTime?> lastReadAt,
      Value<int> rowid,
    });

class $$ReadingProgressTableFilterComposer
    extends Composer<_$UserDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSurah => $composableBuilder(
    column: $table.lastSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$UserDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSurah => $composableBuilder(
    column: $table.lastSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$UserDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileKey => $composableBuilder(
    column: $table.profileKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSurah =>
      $composableBuilder(column: $table.lastSurah, builder: (column) => column);

  GeneratedColumn<int> get lastAyah =>
      $composableBuilder(column: $table.lastAyah, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadingProgressTable,
          ReadingProgressRecord,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (
            ReadingProgressRecord,
            BaseReferences<
              _$UserDatabase,
              $ReadingProgressTable,
              ReadingProgressRecord
            >,
          ),
          ReadingProgressRecord,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableManager(
    _$UserDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileKey = const Value.absent(),
                Value<int> lastSurah = const Value.absent(),
                Value<int> lastAyah = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion(
                profileKey: profileKey,
                lastSurah: lastSurah,
                lastAyah: lastAyah,
                lastPage: lastPage,
                lastReadAt: lastReadAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileKey,
                required int lastSurah,
                required int lastAyah,
                required int lastPage,
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                profileKey: profileKey,
                lastSurah: lastSurah,
                lastAyah: lastAyah,
                lastPage: lastPage,
                lastReadAt: lastReadAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingProgressTable, ReadingProgressRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    $ReadingProgressTable,
                    ReadingProgressRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadingProgressTable,
      ReadingProgressRecord,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (
        ReadingProgressRecord,
        BaseReferences<
          _$UserDatabase,
          $ReadingProgressTable,
          ReadingProgressRecord
        >,
      ),
      ReadingProgressRecord,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$UserDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$UserDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$UserDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AppSettingsTable,
          AppSettingRecord,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRecord,
            BaseReferences<_$UserDatabase, $AppSettingsTable, AppSettingRecord>,
          ),
          AppSettingRecord,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$UserDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRecord>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $AppSettingsTable,
                    AppSettingRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AppSettingsTable,
      AppSettingRecord,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRecord,
        BaseReferences<_$UserDatabase, $AppSettingsTable, AppSettingRecord>,
      ),
      AppSettingRecord,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$AudioFilesTableTableManager get audioFiles =>
      $$AudioFilesTableTableManager(_db, _db.audioFiles);
  $$AyahTimingsTableTableManager get ayahTimings =>
      $$AyahTimingsTableTableManager(_db, _db.ayahTimings);
  $$WordTimingsTableTableManager get wordTimings =>
      $$WordTimingsTableTableManager(_db, _db.wordTimings);
  $$DownloadJobsTableTableManager get downloadJobs =>
      $$DownloadJobsTableTableManager(_db, _db.downloadJobs);
  $$HifzProgressEntriesTableTableManager get hifzProgressEntries =>
      $$HifzProgressEntriesTableTableManager(_db, _db.hifzProgressEntries);
  $$HifzReviewHistoryRowsTableTableManager get hifzReviewHistoryRows =>
      $$HifzReviewHistoryRowsTableTableManager(_db, _db.hifzReviewHistoryRows);
  $$HifzSessionCheckpointsTableTableManager get hifzSessionCheckpoints =>
      $$HifzSessionCheckpointsTableTableManager(
        _db,
        _db.hifzSessionCheckpoints,
      );
  $$HifzPlansTableTableManager get hifzPlans =>
      $$HifzPlansTableTableManager(_db, _db.hifzPlans);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$ReadingPageVisitsTableTableManager get readingPageVisits =>
      $$ReadingPageVisitsTableTableManager(_db, _db.readingPageVisits);
  $$DailyGoalsTableTableManager get dailyGoals =>
      $$DailyGoalsTableTableManager(_db, _db.dailyGoals);
  $$StudyBookmarksTableTableManager get studyBookmarks =>
      $$StudyBookmarksTableTableManager(_db, _db.studyBookmarks);
  $$StudyNotesTableTableManager get studyNotes =>
      $$StudyNotesTableTableManager(_db, _db.studyNotes);
  $$InstalledTafsirPackagesTableTableManager get installedTafsirPackages =>
      $$InstalledTafsirPackagesTableTableManager(
        _db,
        _db.installedTafsirPackages,
      );
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
