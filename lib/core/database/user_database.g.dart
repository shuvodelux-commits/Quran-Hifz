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

class $InstalledTranslationPackagesTable extends InstalledTranslationPackages
    with
        TableInfo<
          $InstalledTranslationPackagesTable,
          InstalledTranslationPackageRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledTranslationPackagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordCountMeta = const VerificationMeta(
    'recordCount',
  );
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
    'record_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    resourceId,
    name,
    language,
    version,
    localPath,
    author,
    recordCount,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_translation_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledTranslationPackageRecord> instance, {
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
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
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
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('record_count')) {
      context.handle(
        _recordCountMeta,
        recordCount.isAcceptableOrUnknown(
          data['record_count']!,
          _recordCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordCountMeta);
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
  InstalledTranslationPackageRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledTranslationPackageRecord(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
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
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      recordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_count'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $InstalledTranslationPackagesTable createAlias(String alias) {
    return $InstalledTranslationPackagesTable(attachedDatabase, alias);
  }
}

class InstalledTranslationPackageRecord extends DataClass
    implements Insertable<InstalledTranslationPackageRecord> {
  final String sourceId;
  final int resourceId;
  final String name;
  final String language;
  final String version;
  final String localPath;
  final String? author;
  final int recordCount;
  final DateTime installedAt;
  const InstalledTranslationPackageRecord({
    required this.sourceId,
    required this.resourceId,
    required this.name,
    required this.language,
    required this.version,
    required this.localPath,
    this.author,
    required this.recordCount,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['resource_id'] = Variable<int>(resourceId);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    map['version'] = Variable<String>(version);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['record_count'] = Variable<int>(recordCount);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  InstalledTranslationPackagesCompanion toCompanion(bool nullToAbsent) {
    return InstalledTranslationPackagesCompanion(
      sourceId: Value(sourceId),
      resourceId: Value(resourceId),
      name: Value(name),
      language: Value(language),
      version: Value(version),
      localPath: Value(localPath),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      recordCount: Value(recordCount),
      installedAt: Value(installedAt),
    );
  }

  factory InstalledTranslationPackageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledTranslationPackageRecord(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      version: serializer.fromJson<String>(json['version']),
      localPath: serializer.fromJson<String>(json['localPath']),
      author: serializer.fromJson<String?>(json['author']),
      recordCount: serializer.fromJson<int>(json['recordCount']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'resourceId': serializer.toJson<int>(resourceId),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'version': serializer.toJson<String>(version),
      'localPath': serializer.toJson<String>(localPath),
      'author': serializer.toJson<String?>(author),
      'recordCount': serializer.toJson<int>(recordCount),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  InstalledTranslationPackageRecord copyWith({
    String? sourceId,
    int? resourceId,
    String? name,
    String? language,
    String? version,
    String? localPath,
    Value<String?> author = const Value.absent(),
    int? recordCount,
    DateTime? installedAt,
  }) => InstalledTranslationPackageRecord(
    sourceId: sourceId ?? this.sourceId,
    resourceId: resourceId ?? this.resourceId,
    name: name ?? this.name,
    language: language ?? this.language,
    version: version ?? this.version,
    localPath: localPath ?? this.localPath,
    author: author.present ? author.value : this.author,
    recordCount: recordCount ?? this.recordCount,
    installedAt: installedAt ?? this.installedAt,
  );
  InstalledTranslationPackageRecord copyWithCompanion(
    InstalledTranslationPackagesCompanion data,
  ) {
    return InstalledTranslationPackageRecord(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      version: data.version.present ? data.version.value : this.version,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      author: data.author.present ? data.author.value : this.author,
      recordCount: data.recordCount.present
          ? data.recordCount.value
          : this.recordCount,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledTranslationPackageRecord(')
          ..write('sourceId: $sourceId, ')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('author: $author, ')
          ..write('recordCount: $recordCount, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    resourceId,
    name,
    language,
    version,
    localPath,
    author,
    recordCount,
    installedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledTranslationPackageRecord &&
          other.sourceId == this.sourceId &&
          other.resourceId == this.resourceId &&
          other.name == this.name &&
          other.language == this.language &&
          other.version == this.version &&
          other.localPath == this.localPath &&
          other.author == this.author &&
          other.recordCount == this.recordCount &&
          other.installedAt == this.installedAt);
}

class InstalledTranslationPackagesCompanion
    extends UpdateCompanion<InstalledTranslationPackageRecord> {
  final Value<String> sourceId;
  final Value<int> resourceId;
  final Value<String> name;
  final Value<String> language;
  final Value<String> version;
  final Value<String> localPath;
  final Value<String?> author;
  final Value<int> recordCount;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const InstalledTranslationPackagesCompanion({
    this.sourceId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.version = const Value.absent(),
    this.localPath = const Value.absent(),
    this.author = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledTranslationPackagesCompanion.insert({
    required String sourceId,
    required int resourceId,
    required String name,
    required String language,
    required String version,
    required String localPath,
    this.author = const Value.absent(),
    required int recordCount,
    required DateTime installedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       resourceId = Value(resourceId),
       name = Value(name),
       language = Value(language),
       version = Value(version),
       localPath = Value(localPath),
       recordCount = Value(recordCount),
       installedAt = Value(installedAt);
  static Insertable<InstalledTranslationPackageRecord> custom({
    Expression<String>? sourceId,
    Expression<int>? resourceId,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? version,
    Expression<String>? localPath,
    Expression<String>? author,
    Expression<int>? recordCount,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (resourceId != null) 'resource_id': resourceId,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (version != null) 'version': version,
      if (localPath != null) 'local_path': localPath,
      if (author != null) 'author': author,
      if (recordCount != null) 'record_count': recordCount,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledTranslationPackagesCompanion copyWith({
    Value<String>? sourceId,
    Value<int>? resourceId,
    Value<String>? name,
    Value<String>? language,
    Value<String>? version,
    Value<String>? localPath,
    Value<String?>? author,
    Value<int>? recordCount,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return InstalledTranslationPackagesCompanion(
      sourceId: sourceId ?? this.sourceId,
      resourceId: resourceId ?? this.resourceId,
      name: name ?? this.name,
      language: language ?? this.language,
      version: version ?? this.version,
      localPath: localPath ?? this.localPath,
      author: author ?? this.author,
      recordCount: recordCount ?? this.recordCount,
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
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
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
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
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
    return (StringBuffer('InstalledTranslationPackagesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('author: $author, ')
          ..write('recordCount: $recordCount, ')
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

class $CustomDuasTable extends CustomDuas
    with TableInfo<$CustomDuasTable, CustomDuaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomDuasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _arabicMeta = const VerificationMeta('arabic');
  @override
  late final GeneratedColumn<String> arabic = GeneratedColumn<String>(
    'arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transliterationMeta = const VerificationMeta(
    'transliteration',
  );
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
    'transliteration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
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
    title,
    arabic,
    transliteration,
    meaning,
    reference,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_duas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomDuaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('arabic')) {
      context.handle(
        _arabicMeta,
        arabic.isAcceptableOrUnknown(data['arabic']!, _arabicMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
        _transliterationMeta,
        transliteration.isAcceptableOrUnknown(
          data['transliteration']!,
          _transliterationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transliterationMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
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
  CustomDuaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomDuaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      arabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic'],
      )!,
      transliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transliteration'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
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
  $CustomDuasTable createAlias(String alias) {
    return $CustomDuasTable(attachedDatabase, alias);
  }
}

class CustomDuaRow extends DataClass implements Insertable<CustomDuaRow> {
  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomDuaRow({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['arabic'] = Variable<String>(arabic);
    map['transliteration'] = Variable<String>(transliteration);
    map['meaning'] = Variable<String>(meaning);
    map['reference'] = Variable<String>(reference);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomDuasCompanion toCompanion(bool nullToAbsent) {
    return CustomDuasCompanion(
      id: Value(id),
      title: Value(title),
      arabic: Value(arabic),
      transliteration: Value(transliteration),
      meaning: Value(meaning),
      reference: Value(reference),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomDuaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomDuaRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      arabic: serializer.fromJson<String>(json['arabic']),
      transliteration: serializer.fromJson<String>(json['transliteration']),
      meaning: serializer.fromJson<String>(json['meaning']),
      reference: serializer.fromJson<String>(json['reference']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'arabic': serializer.toJson<String>(arabic),
      'transliteration': serializer.toJson<String>(transliteration),
      'meaning': serializer.toJson<String>(meaning),
      'reference': serializer.toJson<String>(reference),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomDuaRow copyWith({
    String? id,
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    String? reference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomDuaRow(
    id: id ?? this.id,
    title: title ?? this.title,
    arabic: arabic ?? this.arabic,
    transliteration: transliteration ?? this.transliteration,
    meaning: meaning ?? this.meaning,
    reference: reference ?? this.reference,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomDuaRow copyWithCompanion(CustomDuasCompanion data) {
    return CustomDuaRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      arabic: data.arabic.present ? data.arabic.value : this.arabic,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      reference: data.reference.present ? data.reference.value : this.reference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomDuaRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('arabic: $arabic, ')
          ..write('transliteration: $transliteration, ')
          ..write('meaning: $meaning, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    arabic,
    transliteration,
    meaning,
    reference,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomDuaRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.arabic == this.arabic &&
          other.transliteration == this.transliteration &&
          other.meaning == this.meaning &&
          other.reference == this.reference &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomDuasCompanion extends UpdateCompanion<CustomDuaRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> arabic;
  final Value<String> transliteration;
  final Value<String> meaning;
  final Value<String> reference;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomDuasCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.arabic = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.meaning = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomDuasCompanion.insert({
    required String id,
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       arabic = Value(arabic),
       transliteration = Value(transliteration),
       meaning = Value(meaning),
       reference = Value(reference),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomDuaRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? arabic,
    Expression<String>? transliteration,
    Expression<String>? meaning,
    Expression<String>? reference,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (arabic != null) 'arabic': arabic,
      if (transliteration != null) 'transliteration': transliteration,
      if (meaning != null) 'meaning': meaning,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomDuasCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? arabic,
    Value<String>? transliteration,
    Value<String>? meaning,
    Value<String>? reference,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomDuasCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (arabic.present) {
      map['arabic'] = Variable<String>(arabic.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CustomDuasCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('arabic: $arabic, ')
          ..write('transliteration: $transliteration, ')
          ..write('meaning: $meaning, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $StudyBookmarksTable studyBookmarks = $StudyBookmarksTable(this);
  late final $StudyNotesTable studyNotes = $StudyNotesTable(this);
  late final $InstalledTafsirPackagesTable installedTafsirPackages =
      $InstalledTafsirPackagesTable(this);
  late final $InstalledTranslationPackagesTable installedTranslationPackages =
      $InstalledTranslationPackagesTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CustomDuasTable customDuas = $CustomDuasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    audioFiles,
    ayahTimings,
    wordTimings,
    downloadJobs,
    syncStates,
    studyBookmarks,
    studyNotes,
    installedTafsirPackages,
    installedTranslationPackages,
    readingProgress,
    appSettings,
    customDuas,
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
typedef $$InstalledTranslationPackagesTableCreateCompanionBuilder =
    InstalledTranslationPackagesCompanion Function({
      required String sourceId,
      required int resourceId,
      required String name,
      required String language,
      required String version,
      required String localPath,
      Value<String?> author,
      required int recordCount,
      required DateTime installedAt,
      Value<int> rowid,
    });
typedef $$InstalledTranslationPackagesTableUpdateCompanionBuilder =
    InstalledTranslationPackagesCompanion Function({
      Value<String> sourceId,
      Value<int> resourceId,
      Value<String> name,
      Value<String> language,
      Value<String> version,
      Value<String> localPath,
      Value<String?> author,
      Value<int> recordCount,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });

class $$InstalledTranslationPackagesTableFilterComposer
    extends Composer<_$UserDatabase, $InstalledTranslationPackagesTable> {
  $$InstalledTranslationPackagesTableFilterComposer({
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

  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
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

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledTranslationPackagesTableOrderingComposer
    extends Composer<_$UserDatabase, $InstalledTranslationPackagesTable> {
  $$InstalledTranslationPackagesTableOrderingComposer({
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

  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
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

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledTranslationPackagesTableAnnotationComposer
    extends Composer<_$UserDatabase, $InstalledTranslationPackagesTable> {
  $$InstalledTranslationPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$InstalledTranslationPackagesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $InstalledTranslationPackagesTable,
          InstalledTranslationPackageRecord,
          $$InstalledTranslationPackagesTableFilterComposer,
          $$InstalledTranslationPackagesTableOrderingComposer,
          $$InstalledTranslationPackagesTableAnnotationComposer,
          $$InstalledTranslationPackagesTableCreateCompanionBuilder,
          $$InstalledTranslationPackagesTableUpdateCompanionBuilder,
          (
            InstalledTranslationPackageRecord,
            BaseReferences<
              _$UserDatabase,
              $InstalledTranslationPackagesTable,
              InstalledTranslationPackageRecord
            >,
          ),
          InstalledTranslationPackageRecord,
          PrefetchHooks Function()
        > {
  $$InstalledTranslationPackagesTableTableManager(
    _$UserDatabase db,
    $InstalledTranslationPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledTranslationPackagesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstalledTranslationPackagesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstalledTranslationPackagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int> recordCount = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledTranslationPackagesCompanion(
                sourceId: sourceId,
                resourceId: resourceId,
                name: name,
                language: language,
                version: version,
                localPath: localPath,
                author: author,
                recordCount: recordCount,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required int resourceId,
                required String name,
                required String language,
                required String version,
                required String localPath,
                Value<String?> author = const Value.absent(),
                required int recordCount,
                required DateTime installedAt,
                Value<int> rowid = const Value.absent(),
              }) => InstalledTranslationPackagesCompanion.insert(
                sourceId: sourceId,
                resourceId: resourceId,
                name: name,
                language: language,
                version: version,
                localPath: localPath,
                author: author,
                recordCount: recordCount,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $InstalledTranslationPackagesTable,
                    InstalledTranslationPackageRecord
                  >(table),
                  BaseReferences<
                    _$UserDatabase,
                    $InstalledTranslationPackagesTable,
                    InstalledTranslationPackageRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledTranslationPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $InstalledTranslationPackagesTable,
      InstalledTranslationPackageRecord,
      $$InstalledTranslationPackagesTableFilterComposer,
      $$InstalledTranslationPackagesTableOrderingComposer,
      $$InstalledTranslationPackagesTableAnnotationComposer,
      $$InstalledTranslationPackagesTableCreateCompanionBuilder,
      $$InstalledTranslationPackagesTableUpdateCompanionBuilder,
      (
        InstalledTranslationPackageRecord,
        BaseReferences<
          _$UserDatabase,
          $InstalledTranslationPackagesTable,
          InstalledTranslationPackageRecord
        >,
      ),
      InstalledTranslationPackageRecord,
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
typedef $$CustomDuasTableCreateCompanionBuilder =
    CustomDuasCompanion Function({
      required String id,
      required String title,
      required String arabic,
      required String transliteration,
      required String meaning,
      required String reference,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CustomDuasTableUpdateCompanionBuilder =
    CustomDuasCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> arabic,
      Value<String> transliteration,
      Value<String> meaning,
      Value<String> reference,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CustomDuasTableFilterComposer
    extends Composer<_$UserDatabase, $CustomDuasTable> {
  $$CustomDuasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
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

class $$CustomDuasTableOrderingComposer
    extends Composer<_$UserDatabase, $CustomDuasTable> {
  $$CustomDuasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
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

class $$CustomDuasTableAnnotationComposer
    extends Composer<_$UserDatabase, $CustomDuasTable> {
  $$CustomDuasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get arabic =>
      $composableBuilder(column: $table.arabic, builder: (column) => column);

  GeneratedColumn<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomDuasTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $CustomDuasTable,
          CustomDuaRow,
          $$CustomDuasTableFilterComposer,
          $$CustomDuasTableOrderingComposer,
          $$CustomDuasTableAnnotationComposer,
          $$CustomDuasTableCreateCompanionBuilder,
          $$CustomDuasTableUpdateCompanionBuilder,
          (
            CustomDuaRow,
            BaseReferences<_$UserDatabase, $CustomDuasTable, CustomDuaRow>,
          ),
          CustomDuaRow,
          PrefetchHooks Function()
        > {
  $$CustomDuasTableTableManager(_$UserDatabase db, $CustomDuasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomDuasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomDuasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomDuasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> arabic = const Value.absent(),
                Value<String> transliteration = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomDuasCompanion(
                id: id,
                title: title,
                arabic: arabic,
                transliteration: transliteration,
                meaning: meaning,
                reference: reference,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String arabic,
                required String transliteration,
                required String meaning,
                required String reference,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomDuasCompanion.insert(
                id: id,
                title: title,
                arabic: arabic,
                transliteration: transliteration,
                meaning: meaning,
                reference: reference,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomDuasTable, CustomDuaRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $CustomDuasTable,
                    CustomDuaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomDuasTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $CustomDuasTable,
      CustomDuaRow,
      $$CustomDuasTableFilterComposer,
      $$CustomDuasTableOrderingComposer,
      $$CustomDuasTableAnnotationComposer,
      $$CustomDuasTableCreateCompanionBuilder,
      $$CustomDuasTableUpdateCompanionBuilder,
      (
        CustomDuaRow,
        BaseReferences<_$UserDatabase, $CustomDuasTable, CustomDuaRow>,
      ),
      CustomDuaRow,
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
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$StudyBookmarksTableTableManager get studyBookmarks =>
      $$StudyBookmarksTableTableManager(_db, _db.studyBookmarks);
  $$StudyNotesTableTableManager get studyNotes =>
      $$StudyNotesTableTableManager(_db, _db.studyNotes);
  $$InstalledTafsirPackagesTableTableManager get installedTafsirPackages =>
      $$InstalledTafsirPackagesTableTableManager(
        _db,
        _db.installedTafsirPackages,
      );
  $$InstalledTranslationPackagesTableTableManager
  get installedTranslationPackages =>
      $$InstalledTranslationPackagesTableTableManager(
        _db,
        _db.installedTranslationPackages,
      );
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CustomDuasTableTableManager get customDuas =>
      $$CustomDuasTableTableManager(_db, _db.customDuas);
}
