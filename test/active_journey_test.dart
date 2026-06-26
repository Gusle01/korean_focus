import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:korean_focus/data/models/place.dart';
import 'package:korean_focus/data/models/transport_type.dart';
import 'package:korean_focus/data/repositories/active_journey_repository.dart';

void main() {
  late Box box;

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('kf_active_test');
    Hive.init(dir.path);
    box = await Hive.openBox(activeJourneyBoxName);
  });

  tearDownAll(() async => Hive.deleteFromDisk());
  setUp(() async => box.clear());

  const origin = Place(
      id: 'o',
      name: '전주역',
      city: '전주',
      type: TransportType.train,
      lat: 35.8,
      lng: 127.1);
  const dest = Place(
      id: 'd',
      name: '서울역',
      city: '서울',
      type: TransportType.train,
      lat: 37.55,
      lng: 126.97);

  test('저장한 진행 중 여정을 그대로 복원한다', () async {
    final repo = ActiveJourneyRepository(box);
    final started = DateTime(2026, 6, 26, 9, 0, 0);
    await repo.save(
      transport: TransportType.train,
      origin: origin,
      destination: dest,
      startedAt: started,
      plannedSeconds: 1800,
      pausedAccumSeconds: 30,
      pausedAt: null,
    );

    expect(hasActiveJourney(), isTrue);
    final snap = repo.read()!;
    expect(snap.transport, TransportType.train);
    expect(snap.origin.name, '전주역');
    expect(snap.destination.city, '서울');
    expect(snap.startedAt, started);
    expect(snap.plannedSeconds, 1800);
    expect(snap.pausedAccumSeconds, 30);
    expect(snap.pausedAt, isNull);
  });

  test('정지 시각(pausedAt)도 복원된다', () async {
    final repo = ActiveJourneyRepository(box);
    final paused = DateTime(2026, 6, 26, 9, 10);
    await repo.save(
      transport: TransportType.airplane,
      origin: origin,
      destination: dest,
      startedAt: DateTime(2026, 6, 26, 9, 0),
      plannedSeconds: 3600,
      pausedAccumSeconds: 0,
      pausedAt: paused,
    );

    final snap = repo.read()!;
    expect(snap.transport, TransportType.airplane);
    expect(snap.pausedAt, paused);
  });

  test('clear 하면 진행 중 여정이 사라진다', () async {
    final repo = ActiveJourneyRepository(box);
    await repo.save(
      transport: TransportType.bus,
      origin: origin,
      destination: dest,
      startedAt: DateTime(2026, 1, 1),
      plannedSeconds: 600,
      pausedAccumSeconds: 0,
      pausedAt: null,
    );
    expect(hasActiveJourney(), isTrue);

    await repo.clear();
    expect(hasActiveJourney(), isFalse);
    expect(repo.read(), isNull);
  });
}
