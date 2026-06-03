import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_diary/core/time/week_key.dart';
import 'package:expense_diary/features/backup/data/backup_metadata_keys.dart';
import 'package:expense_diary/features/backup/domain/snapshot.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseSnapshotRepository {
  FirebaseSnapshotRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  static const int maxSnapshotCount = 5;

  CollectionReference<Map<String, dynamic>> _snapshotsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('snapshots');
  }

  DocumentReference<Map<String, dynamic>> _backupMetadataRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('backupQuota');
  }

  Reference _storageRef(String uid, String snapshotId) {
    return _storage.ref('users/$uid/snapshots/$snapshotId.json');
  }

  Future<void> uploadSnapshot(String uid, Snapshot snapshot) async {
    final snapshotCreatedAt = snapshot.meta.createdAt.toUtc();
    final weekKey = KstWeekKey.fromDateTime(snapshotCreatedAt);
    final storagePath = 'users/$uid/snapshots/${snapshot.snapshotId}.json';

    // payload를 Storage에 업로드
    final payloadBytes = Uint8List.fromList(snapshot.payload.utf8Bytes());
    await _storageRef(uid, snapshot.snapshotId).putData(
      payloadBytes,
      SettableMetadata(contentType: 'application/json; charset=utf-8'),
    );

    // Firestore에는 메타데이터만 저장 (payload 제외)
    await _firestore.runTransaction<void>((tx) async {
      final snapshotRef = _snapshotsRef(uid).doc(snapshot.snapshotId);
      final metadataRef = _backupMetadataRef(uid);
      tx.set(snapshotRef, {
        ...snapshot.meta.toJson(),
        'payloadStoragePath': storagePath,
      });
      tx.set(metadataRef, {
        BackupMetadataKeys.cloudLastBackupAt: Timestamp.fromDate(
          snapshotCreatedAt,
        ),
        BackupMetadataKeys.cloudLastBackupWeekKey: weekKey,
      }, SetOptions(merge: true));
    });

    await _pruneOldSnapshots(uid);
  }

  Future<({DateTime? lastBackupAt, String? lastBackupWeekKey})>
  getBackupMetadata(String uid) async {
    final doc = await _backupMetadataRef(uid).get();
    final raw = doc.data();
    if (raw == null) {
      return (lastBackupAt: null, lastBackupWeekKey: null);
    }

    final normalized = _normalizeFirestoreJson(raw, snapshotId: doc.id);
    final lastBackupAt = normalized[BackupMetadataKeys.cloudLastBackupAt];
    final lastBackupWeekKey =
        normalized[BackupMetadataKeys.cloudLastBackupWeekKey] as String?;

    return (
      lastBackupAt: lastBackupAt is DateTime ? lastBackupAt : null,
      lastBackupWeekKey: lastBackupWeekKey,
    );
  }

  Future<List<SnapshotMeta>> listSnapshots(String uid) async {
    final query =
        await _snapshotsRef(uid).orderBy('createdAt', descending: true).get();

    return query.docs
        .map((doc) {
          final raw = doc.data();
          final normalized = _normalizeFirestoreJson(raw, snapshotId: doc.id);
          return SnapshotMeta.fromJson(normalized);
        })
        .toList(growable: false);
  }

  Future<void> deleteSnapshot(String uid, String snapshotId) async {
    final doc = await _snapshotsRef(uid).doc(snapshotId).get();
    if (!doc.exists) return;
    await _deleteSnapshotDocument(uid, doc);
  }

  Future<void> deleteAllSnapshots(String uid) async {
    final query = await _snapshotsRef(uid).get();
    for (final doc in query.docs) {
      await _deleteSnapshotDocument(uid, doc);
    }
  }

  Future<Snapshot> downloadSnapshot(String uid, String snapshotId) async {
    final doc = await _snapshotsRef(uid).doc(snapshotId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Snapshot not found: $snapshotId');
    }

    final normalized = _normalizeFirestoreJson(doc.data()!, snapshotId: doc.id);
    final storagePath = normalized['payloadStoragePath'] as String?;

    // 신규 형식: payload를 Storage에서 읽음
    if (storagePath != null && storagePath.isNotEmpty) {
      final data = await _storage.ref(storagePath).getData();
      if (data == null) {
        throw StateError('Payload not found in Storage: $storagePath');
      }
      final payloadJson = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return Snapshot.fromSeparateJson(normalized, payloadJson);
    }

    // 구형식: payload가 Firestore 도큐먼트에 내장된 경우
    return Snapshot.fromJson(normalized);
  }

  Future<void> _pruneOldSnapshots(String uid) async {
    final query =
        await _snapshotsRef(uid).orderBy('createdAt', descending: false).get();
    final overflow = query.docs.length - maxSnapshotCount;
    if (overflow <= 0) return;

    for (final doc in query.docs.take(overflow)) {
      await _deleteSnapshotDocument(uid, doc);
    }
  }

  Future<void> _deleteSnapshotDocument(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    if (data != null) {
      await _deletePayload(uid, doc.id, data);
    }
    await doc.reference.delete();
  }

  Future<void> _deletePayload(
    String uid,
    String snapshotId,
    Map<String, dynamic> raw,
  ) async {
    final normalized = _normalizeFirestoreJson(raw, snapshotId: snapshotId);
    final storagePath = normalized['payloadStoragePath'] as String?;
    final ref =
        storagePath != null && storagePath.isNotEmpty
            ? _storage.ref(storagePath)
            : _storageRef(uid, snapshotId);

    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  Map<String, dynamic> _normalizeFirestoreJson(
    Map<String, dynamic> raw, {
    required String snapshotId,
  }) {
    final normalized = <String, dynamic>{};

    for (final entry in raw.entries) {
      normalized[entry.key] = _normalizeValue(entry.value);
    }

    normalized.putIfAbsent('snapshotId', () => snapshotId);
    return normalized;
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), _normalizeValue(val)),
      );
    }
    if (value is List) {
      return value.map(_normalizeValue).toList(growable: false);
    }
    return value;
  }
}
