import 'package:flutter/material.dart';

import '../../data/models/transport_type.dart';

/// 교통수단 → Material 아이콘 매핑 (UI 전용).
IconData transportIcon(TransportType type) => switch (type) {
      TransportType.bus => Icons.directions_bus_rounded,
      TransportType.train => Icons.train_rounded,
      TransportType.airplane => Icons.flight_rounded,
    };
