import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final monthlyTransactions =
        transactionProvider.getTransactionsForMonth(_selectedMonth);

    final expenseTransactions =
        monthlyTransactions.where((t) => t.isExpense).toList();
    final incomeTransactions =
        monthlyTransactions.where((t) => !t.isExpense).toList();

    final categoryData = _getCategoryData(expenseTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectMonth(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(transactionProvider, settingsProvider),
            const SizedBox(height: 24),
            _buildChartSection(categoryData, settingsProvider),
            const SizedBox(height: 24),
            _buildRecentTransactions(expenseTransactions, settingsProvider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(context),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildSummaryCards(
      TransactionProvider provider, SettingsProvider settings) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Income',
            amount: provider.totalIncome,
            color: Colors.green,
            icon: Icons.arrow_upward,
            settings: settings,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Expense',
            amount: provider.totalExpenses,
            color: Colors.red,
            icon: Icons.arrow_downward,
            settings: settings,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildChartSection(
      Map<String, double> categoryData, SettingsProvider settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  PieSeries<MapEntry<String, double>, String>(
                    dataSource: categoryData.entries.toList(),
                    xValueMapper: (entry, _) => entry.key,
                    yValueMapper: (entry, _) => entry.value,
                    dataLabelMapper: (entry, _) =>
                        '${entry.key}\n${settings.formatAmount(entry.value)}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                    ),
                    pointColorMapper: (entry, _) =>
                        _getCategoryColor(entry.key),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1);
  }

  Widget _buildRecentTransactions(
      List<Transaction> transactions, SettingsProvider settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(child: Text('No transactions yet'))
            else
              ...transactions.take(5).map((t) => _TransactionTile(
                    transaction: t,
                    settings: settings,
                  )),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.1);
  }

  Map<String, double> _getCategoryData(List<Transaction> transactions) {
    final Map<String, double> categoryMap = {};
    for (var t in transactions) {
      categoryMap.update(
        t.category,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    return categoryMap;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.amber,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Entertainment': Colors.pink,
      'Bills': Colors.orange,
      'Others': Colors.grey,
    };
    return colors[category] ?? Colors.teal;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final SettingsProvider settings;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              settings.formatAmount(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final SettingsProvider settings;

  const _TransactionTile({
    required this.transaction,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.isExpense ? Colors.red : Colors.green,
        child: Icon(
          transaction.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
        ),
      ),
      title: Text(transaction.title),
      subtitle: Text(transaction.category),
      trailing: Text(
        settings.formatAmount(transaction.amount),
        style: TextStyle(
          color: transaction.isExpense ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
