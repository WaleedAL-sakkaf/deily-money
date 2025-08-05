class Customer {
  final int id;
  String name; // قابل للتعديل
  List<TransactionEntry> transactions;
  final bool isSettled;
  String currency; // قابل للتعديل
  double balance; // إضافة خاصية الرصيد

  Customer({
    required this.id,
    required this.name,
    required this.transactions,
    this.isSettled = false,
    required this.currency,
    this.balance = 0.0, // رصيد افتراضي
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isSettled': isSettled ? 1 : 0,
      'currency': currency,
      'balance': balance, // حفظ الرصيد
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      transactions: [],
      isSettled: (map['isSettled'] ?? 0) == 1,
      currency: map['currency'] ?? 'YER',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0, // استرجاع الرصيد
    );
  }
}

class TransactionEntry {
  final int? id;
  final int customerId;
  final DateTime date;
  final String item;
  final double amount;
  final String currency;
  final bool isCredit;

  TransactionEntry({
    this.id,
    required this.customerId,
    required this.date,
    required this.item,
    required this.amount,
    required this.currency,
    required this.isCredit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'item': item,
      'amount': amount,
      'currency': currency,
      'isCredit': isCredit ? 1 : 0,
    };
  }

  factory TransactionEntry.fromMap(Map<String, dynamic> map) {
    return TransactionEntry(
      id: map['id'],
      customerId: map['customerId'] ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      item: map['item'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'محلي',
      isCredit: (map['isCredit'] ?? 0) == 1,
    );
  }
}
