import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_diary/auth/auth_repository.dart';
import 'package:expense_diary/data/firestore/transaction_dto.dart';
import 'package:uuid/uuid.dart';

class FirestoreTransactionRepository {
  FirestoreTransactionRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
    Uuid? uuid,
  }) : _authRepository = authRepository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _uuid = uuid ?? const Uuid();

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  String get _uid {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User must be signed in to use cloud transactions.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactionsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('transactions');

  Future<TransactionDto> createOrUpdate(TransactionDto tx) async {
    final now = DateTime.now();
    final txId = tx.id.isEmpty ? _uuid.v4() : tx.id;
    final docRef = _transactionsRef.doc(txId);
    final existing = await docRef.get();

    final normalized = tx.copyWith(
      id: txId,
      createdAt:
          existing.exists
              ? (existing.data()?['createdAt'] is Timestamp
                  ? (existing.data()!['createdAt'] as Timestamp).toDate()
                  : tx.createdAt)
              : tx.createdAt,
      updatedAt: now,
      deleted: false,
    );

    final data = normalized.toJson();
    if (!existing.exists) {
      data['createdAt'] = Timestamp.fromDate(now);
      data['updatedAt'] = Timestamp.fromDate(now);
    }

    await docRef.set(data, SetOptions(merge: true));
    return normalized.copyWith(
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Future<void> delete(String txId) async {
    await _transactionsRef.doc(txId).delete();
  }

  Future<List<TransactionDto>> listByMonth(String yyyyMM) async {
    final (start, end) = _monthRange(yyyyMM);
    final snapshot =
        await _transactionsRef
            .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('spentAt', isLessThan: Timestamp.fromDate(end))
            .orderBy('spentAt', descending: true)
            .get();
    return snapshot.docs.map(TransactionDto.fromDoc).toList();
  }

  Stream<List<TransactionDto>> watchByMonth(String yyyyMM) {
    final (start, end) = _monthRange(yyyyMM);
    return _transactionsRef
        .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('spentAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TransactionDto.fromDoc).toList());
  }

  (DateTime, DateTime) _monthRange(String yyyyMM) {
    if (yyyyMM.length != 6) {
      throw ArgumentError.value(yyyyMM, 'yyyyMM', 'Expected format yyyyMM');
    }
    final year = int.parse(yyyyMM.substring(0, 4));
    final month = int.parse(yyyyMM.substring(4, 6));
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (start, end);
  }
}

