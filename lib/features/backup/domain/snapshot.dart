import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';

class SnapshotMeta {
  const SnapshotMeta({
    required this.snapshotId,
    required this.createdAt,
    required this.schemaVersion,
    required this.appVersion,
    required this.dataHash,
    required this.sizeBytes,
  });

  final String snapshotId;
  final DateTime createdAt;
  final int schemaVersion;
  final String appVersion;
  final String dataHash;
  final int sizeBytes;

  Map<String, dynamic> toJson() {
    return {
      'snapshotId': snapshotId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'dataHash': dataHash,
      'sizeBytes': sizeBytes,
    };
  }

  factory SnapshotMeta.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    return SnapshotMeta(
      snapshotId: (json['snapshotId'] as String?) ?? '',
      createdAt:
          createdAtValue is DateTime
              ? createdAtValue
              : DateTime.parse(
                (createdAtValue as String?) ?? DateTime.now().toIso8601String(),
              ),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 0,
      appVersion: (json['appVersion'] as String?) ?? 'unknown',
      dataHash: (json['dataHash'] as String?) ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class SnapshotPayload {
  const SnapshotPayload({
    required this.transactions,
    required this.categories,
    required this.settings,
  });

  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic> settings;

  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions
          .map(_canonicalizeMap)
          .toList(growable: false),
      'categories': categories.map(_canonicalizeMap).toList(growable: false),
      'settings': _canonicalizeMap(settings),
    };
  }

  factory SnapshotPayload.fromJson(Map<String, dynamic> json) {
    return SnapshotPayload(
      transactions: _listOfMaps(json['transactions']),
      categories: _listOfMaps(json['categories']),
      settings: _mapOfDynamic(json['settings']),
    );
  }

  String canonicalJson() => jsonEncode(_canonicalizeDynamic(toJson()));

  List<int> utf8Bytes() => utf8.encode(canonicalJson());

  String sha256Hex() => sha256.convert(utf8Bytes()).toString();

  int sizeBytes() => utf8Bytes().length;

  static List<Map<String, dynamic>> _listOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .map<Map<String, dynamic>>((item) => _mapOfDynamic(item))
        .toList();
  }

  static Map<String, dynamic> _mapOfDynamic(dynamic value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), _normalizeJsonLike(val)),
      );
    }
    return const {};
  }

  static dynamic _normalizeJsonLike(dynamic value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map) return _mapOfDynamic(value);
    if (value is List)
      return value.map(_normalizeJsonLike).toList(growable: false);
    return value;
  }

  static Map<String, dynamic> _canonicalizeMap(Map<String, dynamic> source) {
    final sorted = SplayTreeMap<String, dynamic>();
    for (final entry in source.entries) {
      sorted[entry.key] = _canonicalizeDynamic(entry.value);
    }
    return Map<String, dynamic>.from(sorted);
  }

  static dynamic _canonicalizeDynamic(dynamic value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map<String, dynamic>) return _canonicalizeMap(value);
    if (value is Map) {
      return _canonicalizeMap(value.map((k, v) => MapEntry(k.toString(), v)));
    }
    if (value is List) {
      return value.map(_canonicalizeDynamic).toList(growable: false);
    }
    return value;
  }
}

class Snapshot {
  const Snapshot({
    required this.meta,
    required this.payload,
    this.payloadStoragePath,
  });

  final SnapshotMeta meta;
  final SnapshotPayload payload;

  /// For future expansion (payload in Firebase Storage).
  final String? payloadStoragePath;

  String get snapshotId => meta.snapshotId;

  bool verifyHash() => meta.dataHash == payload.sha256Hex();

  Snapshot copyWith({
    SnapshotMeta? meta,
    SnapshotPayload? payload,
    String? payloadStoragePath,
  }) {
    return Snapshot(
      meta: meta ?? this.meta,
      payload: payload ?? this.payload,
      payloadStoragePath: payloadStoragePath ?? this.payloadStoragePath,
    );
  }

  Map<String, dynamic> toFirestoreJson({bool includePayload = true}) {
    return {
      ...meta.toJson(),
      'payloadStoragePath': payloadStoragePath,
      if (includePayload) 'payload': payload.toJson(),
    };
  }

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    return Snapshot(
      meta: SnapshotMeta.fromJson(json),
      payload: SnapshotPayload.fromJson(_readMap(json['payload'])),
      payloadStoragePath: json['payloadStoragePath'] as String?,
    );
  }

  factory Snapshot.fromSeparateJson(
    Map<String, dynamic> metaJson,
    Map<String, dynamic> payloadJson,
  ) {
    return Snapshot(
      meta: SnapshotMeta.fromJson(metaJson),
      payload: SnapshotPayload.fromJson(payloadJson),
      payloadStoragePath: metaJson['payloadStoragePath'] as String?,
    );
  }

  static Snapshot create({
    required String snapshotId,
    required DateTime createdAt,
    required int schemaVersion,
    required String appVersion,
    required SnapshotPayload payload,
    String? payloadStoragePath,
  }) {
    final hash = payload.sha256Hex();
    final size = payload.sizeBytes();
    return Snapshot(
      meta: SnapshotMeta(
        snapshotId: snapshotId,
        createdAt: createdAt,
        schemaVersion: schemaVersion,
        appVersion: appVersion,
        dataHash: hash,
        sizeBytes: size,
      ),
      payload: payload,
      payloadStoragePath: payloadStoragePath,
    );
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return const {};
  }
}

class SnapshotIntegrityException implements Exception {
  const SnapshotIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'SnapshotIntegrityException: $message';
}
