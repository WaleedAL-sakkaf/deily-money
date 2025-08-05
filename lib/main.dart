import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'providers/entry_provider.dart';
import 'providers/settings_provider.dart';
import 'main_screen.dart';
import 'screens/customer_screen/customers_screen.dart';
import 'screens/daily_reports/daily_reports.dart';
import 'screens/statistics_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database for desktop platforms
  if (isDesktopOrWeb()) {
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
  }

  runApp(const FinancialManagementApp());
}

bool isDesktopOrWeb() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

class FinancialManagementApp extends StatelessWidget {
  const FinancialManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EntryProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'دفتر مهندس',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // supportedLocales: [
            //   Locale('ar', 'AE'),
            // ],
            // locale: Locale('ar', 'AE'),
            routes: {
              '/daily-reports': (context) => const DailyReportsScreen(),
              '/statistics': (context) => const StatisticsScreen(),
              '/customers': (context) => const CustomersScreen(),
            },
          );
        },
      ),
    );
  }
}
