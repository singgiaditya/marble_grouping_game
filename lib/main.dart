import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Marble Grouping Game",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: MyTheme.theme,
    ),
  );
}