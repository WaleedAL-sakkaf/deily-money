import 'package:intl/intl.dart';
import '../../models/entry.dart';
import '../../database/customer_database_helper.dart';
import '../../models/customer.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  // تصفية العناصر حسب الفلتر المحدد
  List<Entry> filterEntries(List<Entry> entries, String filter,
      DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();
    switch (filter) {
      case 'يومي':
        return entries.where((entry) {
          return entry.date.year == now.year &&
              entry.date.month == now.month &&
              entry.date.day == now.day;
        }).toList();
      case 'أسبوعي':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return entries.where((entry) {
          return entry.date
                  .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              entry.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
      case 'شهري':
        return entries.where((entry) {
          return entry.date.year == now.year && entry.date.month == now.month;
        }).toList();
      case 'سنوي':
        return entries.where((entry) {
          return entry.date.year == now.year;
        }).toList();
      case 'مخصص':
        if (startDate != null && endDate != null) {
          return entries.where((entry) {
            final adjustedEndDate = endDate!.add(const Duration(days: 1));
            return entry.date
                    .isAfter(startDate!.subtract(const Duration(days: 1))) &&
                entry.date.isBefore(adjustedEndDate);
          }).toList();
        }
        return entries;
      default:
        return entries;
    }
  }

  // حساب الإحصائيات الأساسية
  Map<String, double> calculateBasicStatistics(List<Entry> entries) {
    if (entries.isEmpty) {
      return {
        'totalNetProfit': 0.0,
        'totalEngineerProfit': 0.0,
        'totalManagerProfit': 0.0,
        'totalAmount': 0.0,
        'profitPercentage': 0.0,
        'highestProfit': 0.0,
        'averageProfit': 0.0,
      };
    }

    final totalNetProfit =
        entries.fold(0.0, (sum, entry) => sum + entry.netProfit);
    final totalEngineerProfit =
        entries.fold(0.0, (sum, entry) => sum + entry.engineerProfit);
    final totalManagerProfit =
        entries.fold(0.0, (sum, entry) => sum + entry.managerProfit);
    final totalAmount =
        entries.fold(0.0, (sum, entry) => sum + entry.totalAmount);

    final profitPercentage =
        totalAmount > 0 ? (totalNetProfit / totalAmount * 100) : 0.0;
    final highestProfit =
        entries.map((e) => e.netProfit).reduce((a, b) => a > b ? a : b);
    final averageProfit = totalNetProfit / entries.length;

    return {
      'totalNetProfit': totalNetProfit,
      'totalEngineerProfit': totalEngineerProfit,
      'totalManagerProfit': totalManagerProfit,
      'totalAmount': totalAmount,
      'profitPercentage': profitPercentage,
      'highestProfit': highestProfit,
      'averageProfit': averageProfit,
    };
  }

  // تحميل بيانات العملاء محسن
  Future<Map<String, dynamic>> loadCustomerDataOptimized() async {
    final customerDbHelper = CustomerDatabaseHelper();

    // جلب جميع العملاء ومعاملاتهم في استعلام واحد محسن
    final customerData = await customerDbHelper.getCustomersWithTransactions();

    final allCustomers = customerData['customers'] as List<Customer>;
    final transactionsMap =
        customerData['transactions'] as Map<int, List<TransactionEntry>>;

    // ربط المعاملات بالعملاء
    for (var customer in allCustomers) {
      customer.transactions = transactionsMap[customer.id] ?? [];
    }

    // ترتيب العملاء حسب عدد المعاملات
    final sortedCustomers = List<Customer>.from(allCustomers);
    sortedCustomers
        .sort((a, b) => b.transactions.length.compareTo(a.transactions.length));

    // تجهيز قائمة العملاء الأكثر نشاطًا (تحسين الأداء)
    final topCustomers = sortedCustomers.take(5).map((customer) {
      // حساب الأرصدة بشكل محسن
      double totalCredit = 0.0;
      double totalDebit = 0.0;
      DateTime? lastTransaction;

      for (var tx in customer.transactions) {
        if (tx.isCredit) {
          totalCredit += tx.amount;
        } else {
          totalDebit += tx.amount;
        }

        if (lastTransaction == null || tx.date.isAfter(lastTransaction)) {
          lastTransaction = tx.date;
        }
      }

      final double balance = totalCredit - totalDebit;

      return {
        'customer': customer,
        'transactionCount': customer.transactions.length,
        'balance': balance,
        'lastTransaction': lastTransaction,
      };
    }).toList();

    return {
      'customers': allCustomers,
      'topCustomers': topCustomers,
    };
  }

  // تحميل بيانات العملاء
  Future<Map<String, dynamic>> loadCustomerData() async {
    final customerDbHelper = CustomerDatabaseHelper();

    // جلب جميع العملاء ومعاملاتهم في استعلام واحد محسن
    final customerData = await customerDbHelper.getCustomersWithTransactions();

    final allCustomers = customerData['customers'] as List<Customer>;
    final transactionsMap =
        customerData['transactions'] as Map<int, List<TransactionEntry>>;

    // ربط المعاملات بالعملاء
    for (var customer in allCustomers) {
      customer.transactions = transactionsMap[customer.id] ?? [];
    }

    // ترتيب العملاء حسب عدد المعاملات
    final sortedCustomers = List<Customer>.from(allCustomers);
    sortedCustomers
        .sort((a, b) => b.transactions.length.compareTo(a.transactions.length));

    // تجهيز قائمة العملاء الأكثر نشاطًا
    final topCustomers = sortedCustomers.take(5).map((customer) {
      final double totalCredit = customer.transactions
          .where((tx) => tx.isCredit)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final double totalDebit = customer.transactions
          .where((tx) => !tx.isCredit)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final double balance = totalCredit - totalDebit;

      return {
        'customer': customer,
        'transactionCount': customer.transactions.length,
        'balance': balance,
        'lastTransaction': customer.transactions.isNotEmpty
            ? customer.transactions.first.date
            : null,
      };
    }).toList();

    return {
      'customers': allCustomers,
      'topCustomers': topCustomers,
    };
  }

  // تنسيق المبالغ المالية
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: 'ريال',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // تنسيق التاريخ
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'ar').format(date);
  }

  // تنسيق التاريخ المختصر
  String formatShortDate(DateTime date) {
    return DateFormat('dd/MM', 'ar').format(date);
  }
}
