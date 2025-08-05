import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final entries = entryProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإدخالات المدخلة'),
        backgroundColor: Colors.blue.shade800,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('التفاصيل')),
              DataColumn(label: Text('المبلغ الإجمالي')),
              DataColumn(label: Text('سعر القطعة')),
              DataColumn(label: Text('اسم المورد')),
              DataColumn(label: Text('المواصلات')),
              DataColumn(label: Text('صافي الربح')),
              DataColumn(label: Text('ربح المهندس')),
              DataColumn(label: Text('ربح المدير')),
              DataColumn(label: Text('التاريخ')),
            ],
            rows: entries.map((entry) {
              return DataRow(cells: [
                DataCell(Text(entry.item)),
                DataCell(Text(entry.totalAmount.toStringAsFixed(2))),
                DataCell(Text(entry.piecePrice.toStringAsFixed(2))),
                DataCell(Text(entry.customerName ?? 'غير محدد')),
                DataCell(Text(entry.transportation.toStringAsFixed(2))),
                DataCell(Text(entry.netProfit.toStringAsFixed(2))),
                DataCell(Text(entry.engineerProfit.toStringAsFixed(2))),
                DataCell(Text(entry.managerProfit.toStringAsFixed(2))),
                DataCell(Text(entry.date.toLocal().toString().split(' ')[0])),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
