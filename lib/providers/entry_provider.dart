import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../providers/database_helper.dart';

class EntryProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Entry> _entries = [];
  List<Entry> _filteredEntries = [];

  List<Entry> get entries =>
      _filteredEntries.isNotEmpty ? _filteredEntries : _entries;

  Future<void> loadEntries() async {
    _entries = await _databaseHelper.getEntries();
    _filteredEntries = _entries;
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async {
    if (_entries.any((e) => e.id == entry.id)) {
      await _databaseHelper.updateEntry(entry);
    } else {
      await _databaseHelper.insertEntry(entry);
    }
    await loadEntries();
  }

  Future<void> editEntry(String id, Entry newEntry) async {
    await _databaseHelper.updateEntry(newEntry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _databaseHelper.deleteEntry(id);
    await loadEntries();
  }

  /// **🔹 إضافة `setEntries` لحل الخطأ**
  void setEntries(List<Entry> newEntries) {
    _entries = newEntries;
    _filteredEntries = newEntries;
    notifyListeners();
  }
  
  /// استعادة البيانات من النسخة الاحتياطية
  Future<void> restoreEntries(List<Entry> restoredEntries) async {
    // حذف جميع البيانات الحالية
    await _databaseHelper.deleteAllEntries();
    
    // إضافة البيانات المستعادة
    for (var entry in restoredEntries) {
      await _databaseHelper.insertEntry(entry);
    }
    
    // إعادة تحميل البيانات
    await loadEntries();
  }

  void filterEntries(String period) {
    final now = DateTime.now();
    _filteredEntries = _entries.where((entry) {
      switch (period) {
        case 'weekly':
          return now.difference(entry.date).inDays <= 7;
        case 'monthly':
          return now.difference(entry.date).inDays <= 30;
        case 'yearly':
          return now.difference(entry.date).inDays <= 365;
        default:
          return true;
      }
    }).toList();
    notifyListeners();
  }
}
