import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../providers/entry_provider.dart';
import '../../models/entry.dart';
import 'statistics_controller.dart';
import 'statistics_service.dart';
import 'pdf_service.dart';
import 'statistics_widgets.dart';
import 'ui_components.dart';

class StatisticsScreenNew extends StatefulWidget {
  const StatisticsScreenNew({super.key});

  @override
  State<StatisticsScreenNew> createState() => _StatisticsScreenNewState();
}

class _StatisticsScreenNewState extends State<StatisticsScreenNew> {
  late StatisticsController _controller;
  late StatisticsService _statisticsService;
  late PdfService _pdfService;

  @override
  void initState() {
    super.initState();
    _controller = StatisticsController();
    _statisticsService = StatisticsService();
    _pdfService = PdfService();
    _controller.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final primaryColor = Colors.blue.shade700;

    final entryProvider = Provider.of<EntryProvider>(context);
    final entries = entryProvider.entries;

    // تصفية العناصر حسب الفلتر المحدد
    final filteredEntries = _statisticsService.filterEntries(
      entries,
      _controller.selectedFilter,
      _controller.startDate,
      _controller.endDate,
    );

    // حساب الإحصائيات
    final statistics =
        _statisticsService.calculateBasicStatistics(filteredEntries);

    final numberFormat = NumberFormat("#,##0", "ar_SA");

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الصفحة مع زر تقرير PDF
                  StatisticsUIComponents.buildPageHeader(
                    isDark: isDark,
                    onPdfButtonPressed: () => _generatePdfReport(
                      context,
                      filteredEntries,
                      statistics,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // أزرار الفلترة
                  StatisticsUIComponents.buildFilterButtons(
                    controller: _controller,
                    isDark: isDark,
                    onFilterChanged: () => setState(() {}),
                    onDateRangePressed: () => _showDateRangePicker(context),
                  ),

                  const SizedBox(height: 24),

                  // عنوان تفاصيل الأرباح
                  StatisticsUIComponents.buildSectionTitle(
                    title: 'تفاصيل الأرباح',
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),

                  // بطاقات الإحصائيات الفرعية
                  StatisticsUIComponents.buildStatisticsCards(
                    totalEngineerProfit: statistics['totalEngineerProfit']!,
                    totalManagerProfit: statistics['totalManagerProfit']!,
                    entriesCount: filteredEntries.length,
                    highestProfit: statistics['highestProfit']!,
                    isDark: isDark,
                    numberFormat: numberFormat,
                  ),

                  const SizedBox(height: 24),

                  // الرسم البياني التفاعلي
                  StatisticsWidgets.buildProfitChart(filteredEntries, isDark),

                  const SizedBox(height: 24),

                  // بطاقة الإحصائيات الرئيسية
                  StatisticsWidgets.buildMainStatsCard(
                    totalNetProfit: statistics['totalNetProfit']!,
                    totalAmount: statistics['totalAmount']!,
                    profitPercentage:
                        statistics['profitPercentage']!.toStringAsFixed(1),
                    numberFormat: numberFormat,
                  ),

                  const SizedBox(height: 24),

                  // بطاقة إحصائيات العملاء
                  StatisticsWidgets.buildCustomerStatsCard(
                    isDark: isDark,
                    customers: _controller.customers,
                    topCustomers: _controller.topCustomers,
                    isLoadingCustomers: _controller.isLoadingCustomers,
                    customerDbHelper: _controller.customerDbHelper,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة إنشاء تقرير PDF
  void _generatePdfReport(
    BuildContext context,
    List<Entry> filteredEntries,
    Map<String, double> statistics,
  ) {
    _pdfService.generatePdfReport(
      context,
      filteredEntries,
      statistics['totalNetProfit']!,
      statistics['totalEngineerProfit']!,
      statistics['totalManagerProfit']!,
      statistics['totalAmount']!,
      _controller.selectedFilter,
    );
  }

  // دالة لإظهار منتقي التاريخ
  Future<void> _showDateRangePicker(BuildContext context) async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _controller.startDate != null && _controller.endDate != null
              ? DateTimeRange(
                  start: _controller.startDate!, end: _controller.endDate!)
              : DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 7)),
                  end: DateTime.now(),
                ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          ),
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _controller.updateCustomDateRange(
            pickedDateRange.start, pickedDateRange.end);
      });
    }
  }
}
