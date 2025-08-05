class Entry {
  final String id;
  final String item;
  final double totalAmount;
  final double piecePrice;
  final double percentage;
  final int? customerId; // إضافة معرف العميل
  final String? customerName; // إضافة اسم العميل
  final String? customerCurrency; // إضافة عملة العميل
  final double transportation;
  final double dailyExchange; // إضافة حقل صرف اليوم
  final DateTime date;

  Entry({
    required this.id,
    required this.item,
    required this.totalAmount,
    required this.piecePrice,
    required this.percentage,
    this.customerId, // جعل العميل اختياري
    this.customerName, // جعل اسم العميل اختياري
    this.customerCurrency, // جعل عملة العميل اختياري
    required this.transportation,
    required this.dailyExchange, // إضافة حقل صرف اليوم
    required this.date,
  });

  // حساب سعر القطعة بالعملة المحلية
  double get piecePriceInLocalCurrency {
    return piecePrice * dailyExchange;
  }

  // حساب صافي الربح (بدون الأعطال الفنية)
  double get netProfit {
    return totalAmount - (piecePriceInLocalCurrency + transportation);
  }

  // حساب ربح المهندس
  double get engineerProfit {
    return (percentage / 100) * netProfit;
  }

  // حساب ربح المدير
  double get managerProfit {
    return netProfit - engineerProfit;
  }

  // تحويل الكائن إلى Map (لحفظه في قاعدة البيانات)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'totalAmount': totalAmount,
      'piecePrice': piecePrice,
      'percentage': percentage,
      'customerId': customerId,
      'customerName': customerName,
      'customerCurrency': customerCurrency,
      'transportation': transportation,
      'dailyExchange': dailyExchange, // إضافة حقل صرف اليوم
      'date': date.toIso8601String(),
    };
  }

  // تحويل الكائن إلى JSON باستخدام toMap
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // تحويل Map إلى كائن Entry (لقراءة البيانات من قاعدة البيانات)
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      item: map['item'],
      totalAmount: map['totalAmount'],
      piecePrice: map['piecePrice'],
      percentage: map['percentage'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerCurrency: map['customerCurrency'],
      transportation: map['transportation'],
      dailyExchange:
          map['dailyExchange'] ?? 0.0, // استخدام 0.0 إذا كانت القيمة null
      date: DateTime.parse(map['date']),
    );
  }
}
