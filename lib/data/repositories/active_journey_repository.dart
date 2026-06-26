import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/place.dart';
import '../models/transport_type.dart';

const activeJourneyBoxName = 'active_journey';
const _key = 'current';

/// 진행 중 여정이 저장돼 있는지(앱 재실행 시 라우팅 판단용).
bool hasActiveJourney() =>
    Hive.isBoxOpen(activeJourneyBoxName) &&
    Hive.box(activeJourneyBoxName).containsKey(_key);

/// 복원용 진행 중 여정 스냅샷(타이머 + 선택).
class ActiveJourneySnapshot {
  final TransportType transport;
  final Place origin;
  final Place destination;
  final DateTime startedAt;
  final int plannedSeconds;
  final int pausedAccumSeconds;
  final DateTime? pausedAt;

  const ActiveJourneySnapshot({
    required this.transport,
    required this.origin,
    required this.destination,
    required this.startedAt,
    required this.plannedSeconds,
    required this.pausedAccumSeconds,
    required this.pausedAt,
  });
}

/// 진행 중인 여정(타이머+선택)을 한 건 저장/복원한다.
///
/// Live Activity/알림은 앱이 죽어도 살아남으므로, 재실행 시 이 기록으로
/// 집중 화면을 복원해 "유령 현황"과 앱 상태를 일치시킨다.
class ActiveJourneyRepository {
  ActiveJourneyRepository(this._box);
  final Box _box;

  ActiveJourneySnapshot? read() {
    final raw = _box.get(_key);
    if (raw is! Map) return null;
    try {
      final m = Map<String, dynamic>.from(raw);
      Place place(dynamic v) {
        final p = Map<String, dynamic>.from(v as Map);
        return Place(
          id: p['id'] as String,
          name: p['name'] as String,
          city: p['city'] as String,
          type: TransportType.values[p['type'] as int],
          lat: (p['lat'] as num).toDouble(),
          lng: (p['lng'] as num).toDouble(),
        );
      }

      final pausedMs = m['pausedAtMs'] as int?;
      return ActiveJourneySnapshot(
        transport: TransportType.values[m['transport'] as int],
        origin: place(m['origin']),
        destination: place(m['destination']),
        startedAt: DateTime.fromMillisecondsSinceEpoch(m['startedAtMs'] as int),
        plannedSeconds: m['plannedSeconds'] as int,
        pausedAccumSeconds: m['pausedAccumSeconds'] as int? ?? 0,
        pausedAt: pausedMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(pausedMs),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required TransportType transport,
    required Place origin,
    required Place destination,
    required DateTime startedAt,
    required int plannedSeconds,
    required int pausedAccumSeconds,
    required DateTime? pausedAt,
  }) {
    Map<String, dynamic> pm(Place p) => {
          'id': p.id,
          'name': p.name,
          'city': p.city,
          'type': p.type.index,
          'lat': p.lat,
          'lng': p.lng,
        };
    return _box.put(_key, {
      'transport': transport.index,
      'origin': pm(origin),
      'destination': pm(destination),
      'startedAtMs': startedAt.millisecondsSinceEpoch,
      'plannedSeconds': plannedSeconds,
      'pausedAccumSeconds': pausedAccumSeconds,
      'pausedAtMs': pausedAt?.millisecondsSinceEpoch,
    });
  }

  Future<void> clear() => _box.delete(_key);
}

final activeJourneyRepositoryProvider = Provider<ActiveJourneyRepository>(
  (ref) => ActiveJourneyRepository(Hive.box(activeJourneyBoxName)),
);
