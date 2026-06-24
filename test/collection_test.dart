import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/repositories/collection_repository.dart';
import 'package:korean_focus/data/static/airports.dart';
import 'package:korean_focus/data/static/collectibles.dart';
import 'package:korean_focus/data/static/stations.dart';
import 'package:korean_focus/data/static/terminals.dart';

void main() {
  group('컬렉션 정의 데이터', () {
    test('모든 정의 id 는 고유하다', () {
      final ids = allCollectibles.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('등장하는 모든 도시(역·터미널·공항)에 컬렉션이 정의돼 있다', () {
      final cities = <String>{
        ...trainStations.map((p) => p.city),
        ...busTerminals.map((p) => p.city),
        ...airports.map((p) => p.city),
      };
      for (final city in cities) {
        expect(collectiblesForCity(city), isNotEmpty,
            reason: '$city 에 컬렉션 정의가 없습니다');
      }
    });

    test('collectibleDefById 로 정의를 찾을 수 있다', () {
      final first = allCollectibles.first;
      expect(collectibleDefById(first.id)?.name, first.name);
      expect(collectibleDefById('___없는id___'), isNull);
    });
  });

  group('pickCollectibleDef', () {
    final jeonju = collectiblesForCity('전주');

    test('후보가 없으면 null', () {
      expect(pickCollectibleDef([], {}, Random(0)), isNull);
    });

    test('미보유 정의를 우선 지급한다', () {
      // 첫 번째만 빼고 모두 보유 → 남은 하나가 반드시 선택된다.
      final owned = jeonju.skip(1).map((d) => d.id).toSet();
      final picked = pickCollectibleDef(jeonju, owned, Random(123));
      expect(picked!.id, jeonju.first.id);
    });

    test('모두 보유했어도 후보 중 하나를 반환한다', () {
      final owned = jeonju.map((d) => d.id).toSet();
      final picked = pickCollectibleDef(jeonju, owned, Random(7));
      expect(jeonju.map((d) => d.id), contains(picked!.id));
    });
  });
}
