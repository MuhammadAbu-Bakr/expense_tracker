import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  Box<Transaction>? _transactionsBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _transactionsBox = await Hive.openBox<Transaction>('transactions');
      _isInitialized = true;
      notifyListeners();
    }
  }

  List<Transaction> get transactions {
    if (!_isInitialized) return [];
    return _transactionsBox?.values.toList() ?? [];
  }

  double get totalExpenses {
    if (!_isInitialized) return 0;
    return _transactionsBox?.values
            .where((t) => t.isExpense)
            .fold<double>(0, (sum, t) => sum + (t.amount ?? 0)) ??
        0;
  }

  double get totalIncome {
    if (!_isInitialized) return 0;
    return _transactionsBox?.values
            .where((t) => !t.isExpense)
            .fold<double>(0, (sum, t) => sum + (t.amount ?? 0)) ??
        0;
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (!_isInitialized) await initialize();
    await _transactionsBox?.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    if (!_isInitialized) await initialize();
    final index =
        _transactionsBox?.values.toList().indexWhere((t) => t.id == id) ?? -1;
    if (index >= 0) {
      await _transactionsBox?.deleteAt(index);
      notifyListeners();
    }
  }

  List<Transaction> getTransactionsForMonth(DateTime month) {
    if (!_isInitialized) return [];
    return _transactionsBox?.values.where((t) {
          return t.date.month == month.month && t.date.year == month.year;
        }).toList() ??
        [];
  }
}
