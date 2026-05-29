import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_diary/core/time/week_key.dart';
import 'package:expense_diary/features/backup/data/backup_metadata_keys.dart';
import 'package:expense_diary/features/backup/domain/snapshot.dart';

class FirebaseSnapshotRepository {
  FirebaseSnapshotRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Future<void> uploadSnapshot(String uid, Snapshot snapshot) async {
    final snapshotCreatedAt = snapshot.meta.createdAt.toUtc();
    final weekKey = KstWeekKey.fromDateTime(snapshotCreatedAt);

    await _firestore.runTransaction<void>((tx) async {
      final snapshotRef = _snapshotsRef(uid).doc(snapshot.snapshotId);
      final metadataRef = _backupMetadataRef(uid);
      tx.set(snapshotRef, snapshot.toFirestoreJson());
      tx.set(metadataRef, {
        BackupMetadataKeys.cloudLastBackupAt: Timestamp.fromDate(
          snapshotCreatedAt,
        ),
        BackupMetadataKeys.cloudLastBackupWeekKey: weekKey,
      }, SetOptions(merge: true));
    });
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

  Future<Snapshot> downloadSnapshot(String uid, String snapshotId) async {
    final doc = await _snapshotsRef(uid).doc(snapshotId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Snapshot not found: $snapshotId');
    }

    final normalized = _normalizeFirestoreJson(doc.data()!, snapshotId: doc.id);
    return Snapshot.fromJson(normalized);
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
