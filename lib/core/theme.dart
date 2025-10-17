import 'package:flutter/material.dart';
import 'constants.dart';

/// Define o tema visual do app (claro e escuro).
class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryColor,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
  );
}
