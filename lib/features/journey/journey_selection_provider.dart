import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/place.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/active_journey_repository.dart';

/// 진행 중인 여정 선택 상태 (교통수단 → 출발 → 도착).
class JourneySelection {
  final TransportType? transport;
  final Place? origin;
  final Place? destination;

  const JourneySelection({this.transport, this.origin, this.destination});

  bool get isComplete =>
      transport != null && origin != null && destination != null;

  JourneySelection copyWith({Place? origin, Place? destination}) =>
      JourneySelection(
        transport: transport,
        origin: origin ?? this.origin,
        destination: destination ?? this.destination,
      );
}

class JourneySelectionNotifier extends Notifier<JourneySelection> {
  @override
  JourneySelection build() {
    // 앱 재실행 시 진행 중 여정이 있으면 선택 상태를 복원한다.
    final snap = hasActiveJourney()
        ? ref.read(activeJourneyRepositoryProvider).read()
        : null;
    if (snap != null) {
      return JourneySelection(
        transport: snap.transport,
        origin: snap.origin,
        destination: snap.destination,
      );
    }
    return const JourneySelection();
  }

  /// 교통수단 변경 시 출발/도착은 초기화(교통수단별 장소가 다르므로).
  void selectTransport(TransportType t) =>
      state = JourneySelection(transport: t);

  /// 출발지 변경 시 도착지는 초기화.
  void selectOrigin(Place p) =>
      state = JourneySelection(transport: state.transport, origin: p);

  void selectDestination(Place p) => state = state.copyWith(destination: p);

  void reset() => state = const JourneySelection();
}

final journeySelectionProvider =
    NotifierProvider<JourneySelectionNotifier, JourneySelection>(
  JourneySelectionNotifier.new,
);
