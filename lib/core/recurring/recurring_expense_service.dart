import 'package:drift/drift.dart';
import 'package:expense_diary/core/recurring/recurring_schedule.dart';
import 'package:expense_diary/database/drift_database.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class RecurringExpenseService {
  const RecurringExpenseService._();

  /// due 된 반복 지출을 실제 Expense로 생성한다. 최대 [limit]건 처리.
  /// 반환값: 생성된 Expense 건수.
  static Future<int> generateDueExpenses({
    DateTime? now,
    int limit = 100,
  }) async {
    final db = GetIt.I<LocalDatabase>();
    final today = _toDateOnly(now ?? DateTime.now());
    final actives = await db.getActiveRecurringExpenses();

    int generated = 0;

    for (final rule in actives) {
      if (generated >= limit) break;

      var nextRun = _toDateOnly(rule.nextRunDate);

      while (!nextRun.isAfter(today) && generated < limit) {
        // 종료일 초과 시 비활성화
        if (rule.endDate != null &&
            nextRun.isAfter(_toDateOnly(rule.endDate!))) {
          await db.deactivateRecurringExpense(rule.id);
          break;
        }

        // 중복 방지
        final exists = await db.recurringExpenseOccurrenceExists(
          rule.id,
          nextRun,
        );
        if (!exists) {
          await db.createExpense(
            ExpensesCompanion(
              expenseName: Value(rule.name),
              expenseDate: Value(nextRun),
              expense: Value(rule.amount),
              categoryId: Value(rule.categoryId),
              paymentMethodId: Value(rule.paymentMethodId),
              expenseDetail: Value(rule.detail ?? ''),
              recurringExpenseId: Value(rule.id),
              recurringOccurrenceDate: Value(nextRun),
            ),
          );
          generated++;
        }

        final next = RecurringSchedule.calculateNextRunDate(
          current: nextRun,
          frequency: rule.frequency,
          interval: rule.interval,
        );

        await db.updateRecurringExpense(
          RecurringExpensesCompanion(
            id: Value(rule.id),
            nextRunDate: Value(next),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // 종료일이 있고 다음 실행일이 종료일 이후면 비활성화
        if (rule.endDate != null &&
            next.isAfter(_toDateOnly(rule.endDate!))) {
          await db.deactivateRecurringExpense(rule.id);
          break;
        }

        nextRun = next;
      }
    }

    if (generated > 0) {
      debugPrint('RecurringExpenseService: generated $generated expenses');
    }

    return generated;
  }

  static DateTime _toDateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
