import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 집중 화면 지도 스타일: false = 감성(CustomPainter), true = 실제(flutter_map).
final useRealMapProvider = StateProvider<bool>((ref) => false);
