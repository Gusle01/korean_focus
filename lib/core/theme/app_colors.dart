import 'package:flutter/material.dart';

/// 한국 교통 감성 + 따뜻한 종이 — 「승차권」 팔레트.
///
/// 바탕(종이)·먹빛(글자)·황톳빛/노을(포인트)을 축으로,
/// 청자·단청을 보조 강조로 둔다.
class AppColors {
  AppColors._();

  // 바탕 — 따뜻한 종이.
  static const background = Color(0xFFF4ECDB); // 종이 베이지
  static const surface = Color(0xFFFBF6EC); // 카드 — 미색
  static const kraft = Color(0xFFEBDDC2); // 크라프트(절취 스텁 등)

  // 글자 — 먹빛.
  static const textPrimary = Color(0xFF211E17);
  static const textSecondary = Color(0xFF5C5446);
  static const textTertiary = Color(0xFF928975);

  // 포인트 — 황톳빛 + 노을.
  static const primary = Color(0xFFBA7517); // 황톳빛
  static const primaryDark = Color(0xFF854F0B);
  static const primaryLight = Color(0xFFE3A646); // 노을빛 하이라이트

  // 보조 — 청자 / 단청.
  static const celadon = Color(0xFF5E8A6E); // 컬렉션 등 보조 포인트
  static const danchung = Color(0xFFB5462F); // 도장 · 강조

  // 선.
  static const line = Color(0x1A211E17); // 10%
  static const line2 = Color(0x2E211E17); // ~18%

  /// 카드용 따뜻한 그림자(은은한 입체).
  static const cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x14523414), // 따뜻한 갈색 8%
      blurRadius: 24,
      offset: Offset(0, 14),
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Color(0x0F523414),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
}
