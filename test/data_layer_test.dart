import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/models/focus_session.dart';
import 'package:korean_focus/data/models/place.dart';
import 'package:korean_focus/data/models/transport_type.dart';
import 'package:korean_focus/data/repositories/place_repository.dart';
import 'package:korean_focus/data/repositories/session_repository.dart';
import 'package:korean_focus/data/static/route_durations.dart';
import 'package:korean_focus/data/static/stations.dart';

void main() {
  const placeRepo = PlaceRepository();

  group('PlaceRepository.search', () {
    test('빈 검색어는 전체 목록을 반환한다', () {
      final result = placeRepo.search(TransportType.train, '');
      expect(result.length, trainStations.length);
    });

    test('역 이름으로 검색된다', () {
      final result = placeRepo.search(TransportType.train, '전주');
      expect(result.any((p) => p.id == 'jeonju_st'), isTrue);
      expect(result.every((p) => p.type == TransportType.train), isTrue);
    });

    test('도시명으로도 검색된다', () {
      final result = placeRepo.search(TransportType.airplane, '제주');
      expect(result.any((p) => p.id == 'jeju_ap'), isTrue);
    });

    test('출발지는 도착지 목록에서 제외된다', () {
      final origin = trainStations.firstWhere((p) => p.id == 'seoul_st');
      final dests = placeRepo.destinationsFor(TransportType.train, origin);
      expect(dests.any((p) => p.id == 'seoul_st'), isFalse);
    });
  });

  group('buildRoute', () {
    Place station(String id) => trainStations.firstWhere((p) => p.id == id);

    test('정적 테이블에 있으면 그 값을 쓴다', () {
      final route =
          buildRoute(station('jeonju_st'), station('seoul_st'), TransportType.train);
      expect(route.durationMinutes, 100);
      expect(route.grade, 'KTX');
    });

    test('방향이 반대여도 같은 값을 찾는다', () {
      final route =
          buildRoute(station('seoul_st'), station('jeonju_st'), TransportType.train);
      expect(route.durationMinutes, 100);
    });

    test('테이블에 없으면 거리 기반으로 추정한다(20~240분)', () {
      final route =
          buildRoute(station('suwon_st'), station('busan_st'), TransportType.train);
      expect(route.durationMinutes, inInclusiveRange(20, 240));
      expect(route.grade, 'KTX');
    });
  });

  group('집중 통계 집계', () {
    FocusSession make({
      required int seconds,
      required DateTime at,
      bool completed = true,
    }) =>
        FocusSession(
          id: at.toIso8601String(),
          originName: '전주역',
          destName: '서울역',
          transportIndex: TransportType.train.index,
          plannedSeconds: seconds,
          focusedSeconds: seconds,
          startedAt: at,
          completed: completed,
        );

    test('오늘 완료 세션만 합산한다', () {
      final now = DateTime(2026, 6, 25, 10);
      final sessions = [
        make(seconds: 600, at: DateTime(2026, 6, 25, 9)),
        make(seconds: 300, at: DateTime(2026, 6, 24, 9)), // 어제
        make(seconds: 999, at: DateTime(2026, 6, 25, 8), completed: false),
      ];
      expect(todayFocusedSeconds(sessions, now), 600);
    });

    test('전체 누적은 완료 세션 전부를 합산한다', () {
      final sessions = [
        make(seconds: 600, at: DateTime(2026, 6, 25, 9)),
        make(seconds: 300, at: DateTime(2026, 6, 24, 9)),
      ];
      expect(totalFocusedSeconds(sessions), 900);
    });
  });
}
