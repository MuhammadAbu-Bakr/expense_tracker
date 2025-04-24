import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  late Box<Transaction> _transactionsBox;

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    _transactionsBox = Hive.box<Transaction>('transactions');
    notifyListeners();
  }

  List<Transaction> get transactions => _transactionsBox.values.toList();

  double get totalExpenses {
    return _transactionsBox.values
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalIncome {
    return _transactionsBox.values
        .where((t) => !t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactionsBox.values.toList().indexWhere((t) => t.id == id);
    if (index >= 0) {
      await _transactionsBox.deleteAt(index);
      notifyListeners();
    }
  }

  List<Transaction> getTransactionsForMonth(DateTime month) {
    return _transactionsBox.values.where((t) {
      return t.date.month == month.month && t.date.year == month.year;
    }).toList();
  }
}