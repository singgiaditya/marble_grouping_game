import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';

class MyTheme {
  static final ThemeData theme = ThemeData(
    primarySwatch: MaterialColor(MyColor.primary.toARGB32(), {
      50: MyColor.primary.withValues(alpha: 0.1),
      100: MyColor.primary.withValues(alpha: 0.2),
      200: MyColor.primary.withValues(alpha: 0.3),
      300: MyColor.primary.withValues(alpha: 0.4),
      400: MyColor.primary.withValues(alpha: 0.5),
      500: MyColor.primary.withValues(alpha: 0.6),
      600: MyColor.primary.withValues(alpha: 0.7),
      700: MyColor.primary.withValues(alpha: 0.8),
      800: MyColor.primary.withValues(alpha: 0.9),
      900: MyColor.primary.withValues(alpha: 1.0),
    }),
    brightness: Brightness.light,
    scaffoldBackgroundColor: MyColor.background,
    textTheme: TextTheme(
      displayLarge: TextStyle(color: MyColor.textPrimary),
      headlineLarge: TextStyle(color: MyColor.textPrimary),
      titleLarge: TextStyle(color: MyColor.textPrimary),
      bodyLarge: TextStyle(color: MyColor.textPrimary),
      bodyMedium: TextStyle(color: MyColor.textPrimary),
    ),
  );
}
