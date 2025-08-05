import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

Future<void> requestStoragePermission() async {
  // التحقق من إذن الوصول الكامل للتخزين
  if (await Permission.manageExternalStorage.isGranted) {
    // الإذن موجود بالفعل
    return;
  } else {
    // الطلب من المستخدم لفتح الإعدادات ومنح الإذن
    if (await Permission.manageExternalStorage.request().isGranted) {
      // تمت الموافقة على الإذن
      print("Permission granted");
    } else {
      // إذا رفض الإذن، يمكن عرض رسالة للمستخدم أو التعامل مع الرفض
      print("Permission denied");
    }
  }
}

Future<void> pickFile() async {
  // طلب إذن الوصول إلى التخزين
  var status = await Permission.storage.request();
  if (status.isGranted) {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      // التعامل مع الملف الذي تم اختياره
      print("Selected file: ${file.path}");
    } else {
      print("No file selected");
    }
  } else {
    print("Storage permission denied");
  }
}

Future<void> saveFile(BuildContext context) async {
  // طلب إذن الوصول الكامل للتخزين
  await requestStoragePermission();

  // بعد التأكد من الإذن، اختر مجلد لحفظ الملف
  final selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory != null) {
    final filePath = '$selectedDirectory/report.pdf';
    final file = File(filePath);

    // هنا يمكنك كتابة البيانات التي تريد حفظها في الملف
    await file.writeAsBytes([1, 2, 3, 4, 5]); // بيانات عشوائية كمثال

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الملف في: $filePath')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لم يتم اختيار مجلد')),
    );
  }
}
