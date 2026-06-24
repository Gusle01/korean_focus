import 'place.dart';
import 'transport_type.dart';

/// 출발지 → 도착지 한 구간의 여정 정보.
class JourneyRoute {
  final Place origin;
  final Place destination;
  final TransportType transport;
  final int durationMinutes; // 정적 소요시간(분)
  final String grade; // KTX / 무궁화 / 고속 / 직항 등

  const JourneyRoute({
    required this.origin,
    required this.destination,
    required this.transport,
    required this.durationMinutes,
    required this.grade,
  });

  Duration get duration => Duration(minutes: durationMinutes);
}
