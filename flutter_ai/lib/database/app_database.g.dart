// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JournalsTable extends Journals with TableInfo<$JournalsTable, Journal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transcriptMeta =
      const VerificationMeta('transcript');
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
      'transcript', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationSecMeta =
      const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
      'duration_sec', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, audioPath, transcript, durationSec, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journals';
  @override
  VerificationContext validateIntegrity(Insertable<Journal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
          _transcriptMeta,
          transcript.isAcceptableOrUnknown(
              data['transcript']!, _transcriptMeta));
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
          _durationSecMeta,
          durationSec.isAcceptableOrUnknown(
              data['duration_sec']!, _durationSecMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Journal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Journal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path'])!,
      transcript: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transcript']),
      durationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_sec'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $JournalsTable createAlias(String alias) {
    return $JournalsTable(attachedDatabase, alias);
  }
}

class Journal extends DataClass implements Insertable<Journal> {
  /// UUID v4 dibuat di sisi app (tidak auto-increment agar bisa offline-first).
  final String id;

  /// Unix timestamp milidetik saat rekaman selesai.
  final int createdAt;

  /// Path absolut file .m4a di documents directory.
  final String audioPath;

  /// Transkripsi teks dari Whisper API. Null saat proses belum selesai.
  final String? transcript;

  /// Durasi rekaman dalam detik.
  final int durationSec;

  /// Enum: 'pending' | 'processing' | 'done' | 'error'
  final String status;
  const Journal(
      {required this.id,
      required this.createdAt,
      required this.audioPath,
      this.transcript,
      required this.durationSec,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['audio_path'] = Variable<String>(audioPath);
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['duration_sec'] = Variable<int>(durationSec);
    map['status'] = Variable<String>(status);
    return map;
  }

  JournalsCompanion toCompanion(bool nullToAbsent) {
    return JournalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      audioPath: Value(audioPath),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      durationSec: Value(durationSec),
      status: Value(status),
    );
  }

  factory Journal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Journal(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'audioPath': serializer.toJson<String>(audioPath),
      'transcript': serializer.toJson<String?>(transcript),
      'durationSec': serializer.toJson<int>(durationSec),
      'status': serializer.toJson<String>(status),
    };
  }

  Journal copyWith(
          {String? id,
          int? createdAt,
          String? audioPath,
          Value<String?> transcript = const Value.absent(),
          int? durationSec,
          String? status}) =>
      Journal(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        audioPath: audioPath ?? this.audioPath,
        transcript: transcript.present ? transcript.value : this.transcript,
        durationSec: durationSec ?? this.durationSec,
        status: status ?? this.status,
      );
  Journal copyWithCompanion(JournalsCompanion data) {
    return Journal(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      transcript:
          data.transcript.present ? data.transcript.value : this.transcript,
      durationSec:
          data.durationSec.present ? data.durationSec.value : this.durationSec,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Journal(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript, ')
          ..write('durationSec: $durationSec, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, audioPath, transcript, durationSec, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Journal &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.audioPath == this.audioPath &&
          other.transcript == this.transcript &&
          other.durationSec == this.durationSec &&
          other.status == this.status);
}

class JournalsCompanion extends UpdateCompanion<Journal> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<String> audioPath;
  final Value<String?> transcript;
  final Value<int> durationSec;
  final Value<String> status;
  final Value<int> rowid;
  const JournalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.transcript = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalsCompanion.insert({
    required String id,
    required int createdAt,
    required String audioPath,
    this.transcript = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        audioPath = Value(audioPath);
  static Insertable<Journal> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<String>? audioPath,
    Expression<String>? transcript,
    Expression<int>? durationSec,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (audioPath != null) 'audio_path': audioPath,
      if (transcript != null) 'transcript': transcript,
      if (durationSec != null) 'duration_sec': durationSec,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalsCompanion copyWith(
      {Value<String>? id,
      Value<int>? createdAt,
      Value<String>? audioPath,
      Value<String?>? transcript,
      Value<int>? durationSec,
      Value<String>? status,
      Value<int>? rowid}) {
    return JournalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      audioPath: audioPath ?? this.audioPath,
      transcript: transcript ?? this.transcript,
      durationSec: durationSec ?? this.durationSec,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript, ')
          ..write('durationSec: $durationSec, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmpathyMapsTable extends EmpathyMaps
    with TableInfo<$EmpathyMapsTable, EmpathyMap> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmpathyMapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _journalIdMeta =
      const VerificationMeta('journalId');
  @override
  late final GeneratedColumn<String> journalId = GeneratedColumn<String>(
      'journal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES journals (id)'));
  static const VerificationMeta _dominantEmotionMeta =
      const VerificationMeta('dominantEmotion');
  @override
  late final GeneratedColumn<String> dominantEmotion = GeneratedColumn<String>(
      'dominant_emotion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mapJsonMeta =
      const VerificationMeta('mapJson');
  @override
  late final GeneratedColumn<String> mapJson = GeneratedColumn<String>(
      'map_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _analyzedAtMeta =
      const VerificationMeta('analyzedAt');
  @override
  late final GeneratedColumn<int> analyzedAt = GeneratedColumn<int>(
      'analyzed_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, journalId, dominantEmotion, colorHex, mapJson, analyzedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empathy_maps';
  @override
  VerificationContext validateIntegrity(Insertable<EmpathyMap> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('journal_id')) {
      context.handle(_journalIdMeta,
          journalId.isAcceptableOrUnknown(data['journal_id']!, _journalIdMeta));
    } else if (isInserting) {
      context.missing(_journalIdMeta);
    }
    if (data.containsKey('dominant_emotion')) {
      context.handle(
          _dominantEmotionMeta,
          dominantEmotion.isAcceptableOrUnknown(
              data['dominant_emotion']!, _dominantEmotionMeta));
    } else if (isInserting) {
      context.missing(_dominantEmotionMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('map_json')) {
      context.handle(_mapJsonMeta,
          mapJson.isAcceptableOrUnknown(data['map_json']!, _mapJsonMeta));
    } else if (isInserting) {
      context.missing(_mapJsonMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
          _analyzedAtMeta,
          analyzedAt.isAcceptableOrUnknown(
              data['analyzed_at']!, _analyzedAtMeta));
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmpathyMap map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmpathyMap(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      journalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}journal_id'])!,
      dominantEmotion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dominant_emotion'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      mapJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}map_json'])!,
      analyzedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}analyzed_at'])!,
    );
  }

  @override
  $EmpathyMapsTable createAlias(String alias) {
    return $EmpathyMapsTable(attachedDatabase, alias);
  }
}

class EmpathyMap extends DataClass implements Insertable<EmpathyMap> {
  final String id;

  /// FK ke Journals.id
  final String journalId;
  final String dominantEmotion;

  /// Hex code warna, misal "#2C3E50"
  final String colorHex;

  /// Seluruh empathy map disimpan sebagai JSON string.
  /// Struktur: {"feelings":[...],"thoughts":[...],"pain_points":[...],"actions":[...]}
  final String mapJson;

  /// Unix timestamp saat data AI diterima.
  final int analyzedAt;
  const EmpathyMap(
      {required this.id,
      required this.journalId,
      required this.dominantEmotion,
      required this.colorHex,
      required this.mapJson,
      required this.analyzedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['journal_id'] = Variable<String>(journalId);
    map['dominant_emotion'] = Variable<String>(dominantEmotion);
    map['color_hex'] = Variable<String>(colorHex);
    map['map_json'] = Variable<String>(mapJson);
    map['analyzed_at'] = Variable<int>(analyzedAt);
    return map;
  }

  EmpathyMapsCompanion toCompanion(bool nullToAbsent) {
    return EmpathyMapsCompanion(
      id: Value(id),
      journalId: Value(journalId),
      dominantEmotion: Value(dominantEmotion),
      colorHex: Value(colorHex),
      mapJson: Value(mapJson),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory EmpathyMap.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmpathyMap(
      id: serializer.fromJson<String>(json['id']),
      journalId: serializer.fromJson<String>(json['journalId']),
      dominantEmotion: serializer.fromJson<String>(json['dominantEmotion']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      mapJson: serializer.fromJson<String>(json['mapJson']),
      analyzedAt: serializer.fromJson<int>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'journalId': serializer.toJson<String>(journalId),
      'dominantEmotion': serializer.toJson<String>(dominantEmotion),
      'colorHex': serializer.toJson<String>(colorHex),
      'mapJson': serializer.toJson<String>(mapJson),
      'analyzedAt': serializer.toJson<int>(analyzedAt),
    };
  }

  EmpathyMap copyWith(
          {String? id,
          String? journalId,
          String? dominantEmotion,
          String? colorHex,
          String? mapJson,
          int? analyzedAt}) =>
      EmpathyMap(
        id: id ?? this.id,
        journalId: journalId ?? this.journalId,
        dominantEmotion: dominantEmotion ?? this.dominantEmotion,
        colorHex: colorHex ?? this.colorHex,
        mapJson: mapJson ?? this.mapJson,
        analyzedAt: analyzedAt ?? this.analyzedAt,
      );
  EmpathyMap copyWithCompanion(EmpathyMapsCompanion data) {
    return EmpathyMap(
      id: data.id.present ? data.id.value : this.id,
      journalId: data.journalId.present ? data.journalId.value : this.journalId,
      dominantEmotion: data.dominantEmotion.present
          ? data.dominantEmotion.value
          : this.dominantEmotion,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      mapJson: data.mapJson.present ? data.mapJson.value : this.mapJson,
      analyzedAt:
          data.analyzedAt.present ? data.analyzedAt.value : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmpathyMap(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('dominantEmotion: $dominantEmotion, ')
          ..write('colorHex: $colorHex, ')
          ..write('mapJson: $mapJson, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, journalId, dominantEmotion, colorHex, mapJson, analyzedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmpathyMap &&
          other.id == this.id &&
          other.journalId == this.journalId &&
          other.dominantEmotion == this.dominantEmotion &&
          other.colorHex == this.colorHex &&
          other.mapJson == this.mapJson &&
          other.analyzedAt == this.analyzedAt);
}

class EmpathyMapsCompanion extends UpdateCompanion<EmpathyMap> {
  final Value<String> id;
  final Value<String> journalId;
  final Value<String> dominantEmotion;
  final Value<String> colorHex;
  final Value<String> mapJson;
  final Value<int> analyzedAt;
  final Value<int> rowid;
  const EmpathyMapsCompanion({
    this.id = const Value.absent(),
    this.journalId = const Value.absent(),
    this.dominantEmotion = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.mapJson = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmpathyMapsCompanion.insert({
    required String id,
    required String journalId,
    required String dominantEmotion,
    required String colorHex,
    required String mapJson,
    required int analyzedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        journalId = Value(journalId),
        dominantEmotion = Value(dominantEmotion),
        colorHex = Value(colorHex),
        mapJson = Value(mapJson),
        analyzedAt = Value(analyzedAt);
  static Insertable<EmpathyMap> custom({
    Expression<String>? id,
    Expression<String>? journalId,
    Expression<String>? dominantEmotion,
    Expression<String>? colorHex,
    Expression<String>? mapJson,
    Expression<int>? analyzedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalId != null) 'journal_id': journalId,
      if (dominantEmotion != null) 'dominant_emotion': dominantEmotion,
      if (colorHex != null) 'color_hex': colorHex,
      if (mapJson != null) 'map_json': mapJson,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmpathyMapsCompanion copyWith(
      {Value<String>? id,
      Value<String>? journalId,
      Value<String>? dominantEmotion,
      Value<String>? colorHex,
      Value<String>? mapJson,
      Value<int>? analyzedAt,
      Value<int>? rowid}) {
    return EmpathyMapsCompanion(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      dominantEmotion: dominantEmotion ?? this.dominantEmotion,
      colorHex: colorHex ?? this.colorHex,
      mapJson: mapJson ?? this.mapJson,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (journalId.present) {
      map['journal_id'] = Variable<String>(journalId.value);
    }
    if (dominantEmotion.present) {
      map['dominant_emotion'] = Variable<String>(dominantEmotion.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (mapJson.present) {
      map['map_json'] = Variable<String>(mapJson.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<int>(analyzedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmpathyMapsCompanion(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('dominantEmotion: $dominantEmotion, ')
          ..write('colorHex: $colorHex, ')
          ..write('mapJson: $mapJson, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmotionTagsTable extends EmotionTags
    with TableInfo<$EmotionTagsTable, EmotionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmotionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _journalIdMeta =
      const VerificationMeta('journalId');
  @override
  late final GeneratedColumn<String> journalId = GeneratedColumn<String>(
      'journal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES journals (id)'));
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, journalId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emotion_tags';
  @override
  VerificationContext validateIntegrity(Insertable<EmotionTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('journal_id')) {
      context.handle(_journalIdMeta,
          journalId.isAcceptableOrUnknown(data['journal_id']!, _journalIdMeta));
    } else if (isInserting) {
      context.missing(_journalIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmotionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmotionTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      journalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}journal_id'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
    );
  }

  @override
  $EmotionTagsTable createAlias(String alias) {
    return $EmotionTagsTable(attachedDatabase, alias);
  }
}

class EmotionTag extends DataClass implements Insertable<EmotionTag> {
  final String id;
  final String journalId;

  /// Satu kata emosi, misal "lelah", "cemas", "bahagia"
  final String tag;
  const EmotionTag(
      {required this.id, required this.journalId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['journal_id'] = Variable<String>(journalId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  EmotionTagsCompanion toCompanion(bool nullToAbsent) {
    return EmotionTagsCompanion(
      id: Value(id),
      journalId: Value(journalId),
      tag: Value(tag),
    );
  }

  factory EmotionTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmotionTag(
      id: serializer.fromJson<String>(json['id']),
      journalId: serializer.fromJson<String>(json['journalId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'journalId': serializer.toJson<String>(journalId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  EmotionTag copyWith({String? id, String? journalId, String? tag}) =>
      EmotionTag(
        id: id ?? this.id,
        journalId: journalId ?? this.journalId,
        tag: tag ?? this.tag,
      );
  EmotionTag copyWithCompanion(EmotionTagsCompanion data) {
    return EmotionTag(
      id: data.id.present ? data.id.value : this.id,
      journalId: data.journalId.present ? data.journalId.value : this.journalId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmotionTag(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, journalId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmotionTag &&
          other.id == this.id &&
          other.journalId == this.journalId &&
          other.tag == this.tag);
}

class EmotionTagsCompanion extends UpdateCompanion<EmotionTag> {
  final Value<String> id;
  final Value<String> journalId;
  final Value<String> tag;
  final Value<int> rowid;
  const EmotionTagsCompanion({
    this.id = const Value.absent(),
    this.journalId = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmotionTagsCompanion.insert({
    required String id,
    required String journalId,
    required String tag,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        journalId = Value(journalId),
        tag = Value(tag);
  static Insertable<EmotionTag> custom({
    Expression<String>? id,
    Expression<String>? journalId,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalId != null) 'journal_id': journalId,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmotionTagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? journalId,
      Value<String>? tag,
      Value<int>? rowid}) {
    return EmotionTagsCompanion(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (journalId.present) {
      map['journal_id'] = Variable<String>(journalId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmotionTagsCompanion(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JournalsTable journals = $JournalsTable(this);
  late final $EmpathyMapsTable empathyMaps = $EmpathyMapsTable(this);
  late final $EmotionTagsTable emotionTags = $EmotionTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [journals, empathyMaps, emotionTags];
}

typedef $$JournalsTableCreateCompanionBuilder = JournalsCompanion Function({
  required String id,
  required int createdAt,
  required String audioPath,
  Value<String?> transcript,
  Value<int> durationSec,
  Value<String> status,
  Value<int> rowid,
});
typedef $$JournalsTableUpdateCompanionBuilder = JournalsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<String> audioPath,
  Value<String?> transcript,
  Value<int> durationSec,
  Value<String> status,
  Value<int> rowid,
});

final class $$JournalsTableReferences
    extends BaseReferences<_$AppDatabase, $JournalsTable, Journal> {
  $$JournalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EmpathyMapsTable, List<EmpathyMap>>
      _empathyMapsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.empathyMaps,
          aliasName:
              $_aliasNameGenerator(db.journals.id, db.empathyMaps.journalId));

  $$EmpathyMapsTableProcessedTableManager get empathyMapsRefs {
    final manager = $$EmpathyMapsTableTableManager($_db, $_db.empathyMaps)
        .filter((f) => f.journalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_empathyMapsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EmotionTagsTable, List<EmotionTag>>
      _emotionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.emotionTags,
          aliasName:
              $_aliasNameGenerator(db.journals.id, db.emotionTags.journalId));

  $$EmotionTagsTableProcessedTableManager get emotionTagsRefs {
    final manager = $$EmotionTagsTableTableManager($_db, $_db.emotionTags)
        .filter((f) => f.journalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_emotionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$JournalsTableFilterComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  Expression<bool> empathyMapsRefs(
      Expression<bool> Function($$EmpathyMapsTableFilterComposer f) f) {
    final $$EmpathyMapsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.empathyMaps,
        getReferencedColumn: (t) => t.journalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmpathyMapsTableFilterComposer(
              $db: $db,
              $table: $db.empathyMaps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> emotionTagsRefs(
      Expression<bool> Function($$EmotionTagsTableFilterComposer f) f) {
    final $$EmotionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emotionTags,
        getReferencedColumn: (t) => t.journalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmotionTagsTableFilterComposer(
              $db: $db,
              $table: $db.emotionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$JournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$JournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> empathyMapsRefs<T extends Object>(
      Expression<T> Function($$EmpathyMapsTableAnnotationComposer a) f) {
    final $$EmpathyMapsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.empathyMaps,
        getReferencedColumn: (t) => t.journalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmpathyMapsTableAnnotationComposer(
              $db: $db,
              $table: $db.empathyMaps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> emotionTagsRefs<T extends Object>(
      Expression<T> Function($$EmotionTagsTableAnnotationComposer a) f) {
    final $$EmotionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emotionTags,
        getReferencedColumn: (t) => t.journalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmotionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.emotionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$JournalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalsTable,
    Journal,
    $$JournalsTableFilterComposer,
    $$JournalsTableOrderingComposer,
    $$JournalsTableAnnotationComposer,
    $$JournalsTableCreateCompanionBuilder,
    $$JournalsTableUpdateCompanionBuilder,
    (Journal, $$JournalsTableReferences),
    Journal,
    PrefetchHooks Function({bool empathyMapsRefs, bool emotionTagsRefs})> {
  $$JournalsTableTableManager(_$AppDatabase db, $JournalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String> audioPath = const Value.absent(),
            Value<String?> transcript = const Value.absent(),
            Value<int> durationSec = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalsCompanion(
            id: id,
            createdAt: createdAt,
            audioPath: audioPath,
            transcript: transcript,
            durationSec: durationSec,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int createdAt,
            required String audioPath,
            Value<String?> transcript = const Value.absent(),
            Value<int> durationSec = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalsCompanion.insert(
            id: id,
            createdAt: createdAt,
            audioPath: audioPath,
            transcript: transcript,
            durationSec: durationSec,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$JournalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {empathyMapsRefs = false, emotionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (empathyMapsRefs) db.empathyMaps,
                if (emotionTagsRefs) db.emotionTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (empathyMapsRefs)
                    await $_getPrefetchedData<Journal, $JournalsTable,
                            EmpathyMap>(
                        currentTable: table,
                        referencedTable:
                            $$JournalsTableReferences._empathyMapsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$JournalsTableReferences(db, table, p0)
                                .empathyMapsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.journalId == item.id),
                        typedResults: items),
                  if (emotionTagsRefs)
                    await $_getPrefetchedData<Journal, $JournalsTable,
                            EmotionTag>(
                        currentTable: table,
                        referencedTable:
                            $$JournalsTableReferences._emotionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$JournalsTableReferences(db, table, p0)
                                .emotionTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.journalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$JournalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalsTable,
    Journal,
    $$JournalsTableFilterComposer,
    $$JournalsTableOrderingComposer,
    $$JournalsTableAnnotationComposer,
    $$JournalsTableCreateCompanionBuilder,
    $$JournalsTableUpdateCompanionBuilder,
    (Journal, $$JournalsTableReferences),
    Journal,
    PrefetchHooks Function({bool empathyMapsRefs, bool emotionTagsRefs})>;
typedef $$EmpathyMapsTableCreateCompanionBuilder = EmpathyMapsCompanion
    Function({
  required String id,
  required String journalId,
  required String dominantEmotion,
  required String colorHex,
  required String mapJson,
  required int analyzedAt,
  Value<int> rowid,
});
typedef $$EmpathyMapsTableUpdateCompanionBuilder = EmpathyMapsCompanion
    Function({
  Value<String> id,
  Value<String> journalId,
  Value<String> dominantEmotion,
  Value<String> colorHex,
  Value<String> mapJson,
  Value<int> analyzedAt,
  Value<int> rowid,
});

final class $$EmpathyMapsTableReferences
    extends BaseReferences<_$AppDatabase, $EmpathyMapsTable, EmpathyMap> {
  $$EmpathyMapsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalsTable _journalIdTable(_$AppDatabase db) =>
      db.journals.createAlias(
          $_aliasNameGenerator(db.empathyMaps.journalId, db.journals.id));

  $$JournalsTableProcessedTableManager get journalId {
    final $_column = $_itemColumn<String>('journal_id')!;

    final manager = $$JournalsTableTableManager($_db, $_db.journals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EmpathyMapsTableFilterComposer
    extends Composer<_$AppDatabase, $EmpathyMapsTable> {
  $$EmpathyMapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dominantEmotion => $composableBuilder(
      column: $table.dominantEmotion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mapJson => $composableBuilder(
      column: $table.mapJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnFilters(column));

  $$JournalsTableFilterComposer get journalId {
    final $$JournalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableFilterComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmpathyMapsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmpathyMapsTable> {
  $$EmpathyMapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dominantEmotion => $composableBuilder(
      column: $table.dominantEmotion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mapJson => $composableBuilder(
      column: $table.mapJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnOrderings(column));

  $$JournalsTableOrderingComposer get journalId {
    final $$JournalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableOrderingComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmpathyMapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmpathyMapsTable> {
  $$EmpathyMapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dominantEmotion => $composableBuilder(
      column: $table.dominantEmotion, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get mapJson =>
      $composableBuilder(column: $table.mapJson, builder: (column) => column);

  GeneratedColumn<int> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => column);

  $$JournalsTableAnnotationComposer get journalId {
    final $$JournalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableAnnotationComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmpathyMapsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmpathyMapsTable,
    EmpathyMap,
    $$EmpathyMapsTableFilterComposer,
    $$EmpathyMapsTableOrderingComposer,
    $$EmpathyMapsTableAnnotationComposer,
    $$EmpathyMapsTableCreateCompanionBuilder,
    $$EmpathyMapsTableUpdateCompanionBuilder,
    (EmpathyMap, $$EmpathyMapsTableReferences),
    EmpathyMap,
    PrefetchHooks Function({bool journalId})> {
  $$EmpathyMapsTableTableManager(_$AppDatabase db, $EmpathyMapsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmpathyMapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmpathyMapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmpathyMapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> journalId = const Value.absent(),
            Value<String> dominantEmotion = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<String> mapJson = const Value.absent(),
            Value<int> analyzedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmpathyMapsCompanion(
            id: id,
            journalId: journalId,
            dominantEmotion: dominantEmotion,
            colorHex: colorHex,
            mapJson: mapJson,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String journalId,
            required String dominantEmotion,
            required String colorHex,
            required String mapJson,
            required int analyzedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EmpathyMapsCompanion.insert(
            id: id,
            journalId: journalId,
            dominantEmotion: dominantEmotion,
            colorHex: colorHex,
            mapJson: mapJson,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EmpathyMapsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({journalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (journalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.journalId,
                    referencedTable:
                        $$EmpathyMapsTableReferences._journalIdTable(db),
                    referencedColumn:
                        $$EmpathyMapsTableReferences._journalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EmpathyMapsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EmpathyMapsTable,
    EmpathyMap,
    $$EmpathyMapsTableFilterComposer,
    $$EmpathyMapsTableOrderingComposer,
    $$EmpathyMapsTableAnnotationComposer,
    $$EmpathyMapsTableCreateCompanionBuilder,
    $$EmpathyMapsTableUpdateCompanionBuilder,
    (EmpathyMap, $$EmpathyMapsTableReferences),
    EmpathyMap,
    PrefetchHooks Function({bool journalId})>;
typedef $$EmotionTagsTableCreateCompanionBuilder = EmotionTagsCompanion
    Function({
  required String id,
  required String journalId,
  required String tag,
  Value<int> rowid,
});
typedef $$EmotionTagsTableUpdateCompanionBuilder = EmotionTagsCompanion
    Function({
  Value<String> id,
  Value<String> journalId,
  Value<String> tag,
  Value<int> rowid,
});

final class $$EmotionTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EmotionTagsTable, EmotionTag> {
  $$EmotionTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalsTable _journalIdTable(_$AppDatabase db) =>
      db.journals.createAlias(
          $_aliasNameGenerator(db.emotionTags.journalId, db.journals.id));

  $$JournalsTableProcessedTableManager get journalId {
    final $_column = $_itemColumn<String>('journal_id')!;

    final manager = $$JournalsTableTableManager($_db, $_db.journals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EmotionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EmotionTagsTable> {
  $$EmotionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  $$JournalsTableFilterComposer get journalId {
    final $$JournalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableFilterComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmotionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmotionTagsTable> {
  $$EmotionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  $$JournalsTableOrderingComposer get journalId {
    final $$JournalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableOrderingComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmotionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmotionTagsTable> {
  $$EmotionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  $$JournalsTableAnnotationComposer get journalId {
    final $$JournalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.journalId,
        referencedTable: $db.journals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalsTableAnnotationComposer(
              $db: $db,
              $table: $db.journals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmotionTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmotionTagsTable,
    EmotionTag,
    $$EmotionTagsTableFilterComposer,
    $$EmotionTagsTableOrderingComposer,
    $$EmotionTagsTableAnnotationComposer,
    $$EmotionTagsTableCreateCompanionBuilder,
    $$EmotionTagsTableUpdateCompanionBuilder,
    (EmotionTag, $$EmotionTagsTableReferences),
    EmotionTag,
    PrefetchHooks Function({bool journalId})> {
  $$EmotionTagsTableTableManager(_$AppDatabase db, $EmotionTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmotionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmotionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmotionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> journalId = const Value.absent(),
            Value<String> tag = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmotionTagsCompanion(
            id: id,
            journalId: journalId,
            tag: tag,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String journalId,
            required String tag,
            Value<int> rowid = const Value.absent(),
          }) =>
              EmotionTagsCompanion.insert(
            id: id,
            journalId: journalId,
            tag: tag,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EmotionTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({journalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (journalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.journalId,
                    referencedTable:
                        $$EmotionTagsTableReferences._journalIdTable(db),
                    referencedColumn:
                        $$EmotionTagsTableReferences._journalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EmotionTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EmotionTagsTable,
    EmotionTag,
    $$EmotionTagsTableFilterComposer,
    $$EmotionTagsTableOrderingComposer,
    $$EmotionTagsTableAnnotationComposer,
    $$EmotionTagsTableCreateCompanionBuilder,
    $$EmotionTagsTableUpdateCompanionBuilder,
    (EmotionTag, $$EmotionTagsTableReferences),
    EmotionTag,
    PrefetchHooks Function({bool journalId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db, _db.journals);
  $$EmpathyMapsTableTableManager get empathyMaps =>
      $$EmpathyMapsTableTableManager(_db, _db.empathyMaps);
  $$EmotionTagsTableTableManager get emotionTags =>
      $$EmotionTagsTableTableManager(_db, _db.emotionTags);
}
