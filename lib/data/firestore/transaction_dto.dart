import 'package:cloud_firestore/cloud_firestore.dart';

enum LedgerTransactionType { income, expense }

extension LedgerTransactionTypeX on LedgerTransactionType {
  String get value => switch (this) {
    LedgerTransactionType.income => 'income',
    LedgerTransactionType.expense => 'expense',
  };

  static LedgerTransactionType fromValue(String value) {
    return switch (value) {
      'income' => LedgerTransactionType.income,
      _ => LedgerTransactionType.expense,
    };
  }
}

class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.memo,
    required this.spentAt,
    required this.createdAt,
    required this.updatedAt,
    this.deleted = false,
  });

  final String id;
  final int amount;
  final LedgerTransactionType type;
  final String categoryId;
  final String memo;
  final DateTime spentAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;

  TransactionDto copyWith({
    String? id,
    int? amount,
    LedgerTransactionType? type,
    String? categoryId,
    String? memo,
    DateTime? spentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return TransactionDto(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      memo: memo ?? this.memo,
      spentAt: spentAt ?? this.spentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  factory TransactionDto.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return TransactionDto.fromJson(doc.data() ?? const {}, id: doc.id);
  }

  factory TransactionDto.fromJson(Map<String, dynamic> json, {String? id}) {
    return TransactionDto(
      id: id ?? (json['id'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: LedgerTransactionTypeX.fromValue(
        json['type'] as String? ?? 'expense',
      ),
      categoryId: json['categoryId'] as String? ?? '',
      memo: json['memo'] as String? ?? '',
      spentAt: _toDateTime(json['spentAt']) ?? DateTime.now(),
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updatedAt']) ?? DateTime.now(),
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type.value,
      'categoryId': categoryId,
      'memo': memo,
      'spentAt': Timestamp.fromDate(spentAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deleted': deleted,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

