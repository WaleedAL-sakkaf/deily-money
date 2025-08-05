import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/customer.dart';
import '../../database/customer_database_helper.dart';
import 'statistics_service.dart';

class StatisticsController {
  // المتغيرات الحالية
  String selectedFilter = 'يومي';
  final List<String> filters = ['يومي', 'أسبوعي', 'شهري', 'سنوي', 'مخصص'];
  DateTime? startDate;
  DateTime? endDate;
  bool isCustomDateRange = false;
  bool isLoadingCustomers = false;

  // متغيرات العملاء
  final CustomerDatabaseHelper customerDbHelper = CustomerDatabaseHelper();
  List<Customer> customers = [];
  List<Map<String, dynamic>> topCustomers = [];

  // خدمة الإحصائيات
  final StatisticsService _statisticsService = StatisticsService();

  // إضافة متغيرات للـ caching
  Map<String, dynamic>? _cachedCustomerData;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // تهيئة البيانات
  Future<void> initializeData() async {
    // تهيئة بيانات التاريخ للغة العربية
    initializeDateFormatting('ar', null);

    // تحميل البيانات بشكل متوازي
    await Future.wait([
      loadCustomerData(),
      // يمكن إضافة تحميل بيانات أخرى هنا في المستقبل
    ]);
  }

  // تحميل بيانات العملاء مع caching محسن
  Future<void> loadCustomerData() async {
    // التحقق من صلاحية الـ cache
    if (_cachedCustomerData != null && _lastCacheTime != null) {
      final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
      if (timeSinceLastCache < _cacheDuration) {
        // استخدام البيانات المخزنة مؤقتاً
        customers = _cachedCustomerData!['customers'] as List<Customer>;
        topCustomers =
            _cachedCustomerData!['topCustomers'] as List<Map<String, dynamic>>;
        return;
      }
    }

    isLoadingCustomers = true;

    try {
      // تحميل البيانات في خيط منفصل لتجنب تجميد الواجهة
      final customerData = await _statisticsService.loadCustomerDataOptimized();
      customers = customerData['customers'] as List<Customer>;
      topCustomers = customerData['topCustomers'] as List<Map<String, dynamic>>;

      // حفظ البيانات في الـ cache
      _cachedCustomerData = customerData;
      _lastCacheTime = DateTime.now();
    } catch (e) {
      debugPrint('Error loading customer data: $e');
      // في حالة الخطأ، استخدم البيانات المخزنة مؤقتاً إذا كانت متوفرة
      if (_cachedCustomerData != null) {
        customers = _cachedCustomerData!['customers'] as List<Customer>;
        topCustomers =
            _cachedCustomerData!['topCustomers'] as List<Map<String, dynamic>>;
      }
    } finally {
      isLoadingCustomers = false;
    }
  }

  // تغيير الفلتر
  void changeFilter(String filter) {
    selectedFilter = filter;
    if (filter != 'مخصص') {
      isCustomDateRange = false;
    }

    // إعادة تحميل البيانات إذا كانت فارغة
    if (customers.isEmpty && !isLoadingCustomers) {
      loadCustomerData();
    }
  }

  // تحديث نطاق التاريخ المخصص
  void updateCustomDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    selectedFilter = 'مخصص';
    isCustomDateRange = true;
  }

  // الحصول على النص المعروض للفلتر المخصص
  String getCustomFilterText() {
    if (startDate != null && endDate != null) {
      return '${DateFormat('dd/MM', 'ar').format(startDate!)} - ${DateFormat('dd/MM', 'ar').format(endDate!)}';
    }
    return 'مخصص';
  }

  // التحقق من كون الفلتر محدد
  bool isFilterSelected(String filter) {
    return selectedFilter == filter;
  }

  // الحصول على قائمة الفلاتر المعروضة
  List<String> getVisibleFilters() {
    return filters.where((filter) {
      if (filter == 'مخصص' && !isFilterSelected(filter)) {
        return false;
      }
      return true;
    }).toList();
  }

  // تنسيق المبالغ المالية
  String formatCurrency(double amount) {
    return _statisticsService.formatCurrency(amount);
  }

  // تنسيق التاريخ
  String formatDate(DateTime date) {
    return _statisticsService.formatDate(date);
  }

  // تنسيق التاريخ المختصر
  String formatShortDate(DateTime date) {
    return _statisticsService.formatShortDate(date);
  }

  // دالة لتحديث الـ cache عند تغيير البيانات
  void invalidateCache() {
    _cachedCustomerData = null;
    _lastCacheTime = null;
  }
}
