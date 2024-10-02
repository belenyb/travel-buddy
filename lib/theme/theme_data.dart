import 'package:flutter/material.dart';
import 'package:travel_buddy/theme/theme_constants.dart';

ThemeData getThemeData(BuildContext context) {
  return ThemeData(
    primaryColor: ThemeConstants.primaryColor,
    chipTheme: ChipThemeData(
      labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: ThemeConstants.primaryColor,
          ),
      side: const BorderSide(color: ThemeConstants.primaryColor, width: 0.5),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ThemeConstants.primaryColor,
      onPrimary: ThemeConstants.primaryTextColor,
      secondary: ThemeConstants.secondaryColor,
      onSecondary: Color(0xFF322942),
      error: ThemeConstants.errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: ThemeConstants.primaryTextColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: ThemeConstants.primaryColor,
    ),
  );
}
