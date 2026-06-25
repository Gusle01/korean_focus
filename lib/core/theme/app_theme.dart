import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  // 본문 — 고운돋움(따뜻한 본문). 강조는 AppText(명조/보드체)로 올린다.
  final text = GoogleFonts.gowunDodumTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      // 앱바 제목 — 명조로 여정의 정서를 준다.
      titleTextStyle: GoogleFonts.gowunBatang(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
