import 'package:flutter/material.dart';

import 'constants.dart';

class AppTheme {

  static ThemeData darkTheme = ThemeData(

    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        AppConstants.backgroundColor,

    fontFamily:
        AppConstants.fontMain,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.cardColor,
      centerTitle: true,
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppConstants.primaryColor,
    ),

    cardColor: AppConstants.cardColor,

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(
        backgroundColor:
            AppConstants.primaryColor,

        minimumSize:
            const Size(double.infinity, 50),
      ),
    ),
  );
}