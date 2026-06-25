import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// 「승차권」 서체 역할 분담.
///
/// - [display] 명조(Gowun Batang) — 지명·제목. 여정의 정서를 담당.
/// - [number]  등폭 보드체(Space Mono) — 시각·통계·코드. 등폭 숫자.
/// - [label]   보드체 트래킹 소형 — 섹션 라벨·캡션.
///
/// 본문은 테마(Gowun Dodum)를 그대로 쓰고, 강조가 필요한 곳만 위 셋으로 올린다.
class AppText {
  AppText._();

  /// 지명·제목용 명조.
  static TextStyle display({
    double size = 20,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double height = 1.2,
  }) =>
      GoogleFonts.gowunBatang(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// 시각·통계·코드용 등폭 숫자.
  static TextStyle number({
    double size = 32,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.5,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 섹션 라벨·캡션용 트래킹 소형.
  static TextStyle label({
    double size = 12,
    Color color = AppColors.textTertiary,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 1.5,
      );
}
