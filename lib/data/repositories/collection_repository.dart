import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/collectible_category.dart';
import '../models/collectible_def.dart';
import '../models/owned_collectible.dart';
import '../static/collectibles.dart';

const collectiblesBoxName = 'collectibles';

/// 후보 정의 중 하나를 고른다. 아직 보유하지 않은 것을 우선하고,
/// 모두 보유했다면 전체에서 무작위로 고른다. (테스트 가능한 순수 함수)
CollectibleDef? pickCollectibleDef(
  List<CollectibleDef> candidates,
  Set<String> ownedDefIds,
  Random rng,
) {
  if (candidates.isEmpty) return null;
  final fresh = candidates.where((d) => !ownedDefIds.contains(d.id)).toList();
  final pool = fresh.isNotEmpty ? fresh : candidates;
  return pool[rng.nextInt(pool.length)];
}

/// Hive 박스를 감싸 진열장(획득 컬렉션) 저장/조회/지급을 담당.
class CollectionRepository {
  CollectionRepository(this._box, {Random? rng}) : _rng = rng ?? Random();
  final Box<OwnedCollectible> _box;
  final Random _rng;

  Future<void> save(OwnedCollectible c) => _box.put(c.id, c);

  /// 획득 최신순 전체 목록.
  List<OwnedCollectible> all() {
    final list = _box.values.toList();
    list.sort((a, b) => b.acquiredAt.compareTo(a.acquiredAt));
    return list;
  }

  Set<String> ownedDefIds() => _box.values.map((c) => c.defId).toSet();

  int get count => _box.length;

  /// 서로 다른 종류(정의) 개수 — "도감 진행도"용.
  int get distinctCount => ownedDefIds().length;

  /// 도시 → 획득 컬렉션 목록(각 도시 내 최신순). 도시는 획득 최신순으로 정렬.
  Map<String, List<OwnedCollectible>> byCity() {
    final map = <String, List<OwnedCollectible>>{};
    for (final c in all()) {
      (map[c.city] ??= []).add(c);
    }
    return map;
  }

  /// 도착 보상: 도착 도시의 컬렉션 중 하나를 골라 저장하고 반환.
  /// 해당 도시에 정의된 컬렉션이 없으면 null.
  /// id 를 sessionId 로 두어 같은 세션이 중복 지급되지 않도록 한다.
  Future<OwnedCollectible?> awardForArrival({
    required String sessionId,
    required String destCity,
    required String originName,
    required String destName,
    required int transportIndex,
    required int durationSeconds,
    required DateTime acquiredAt,
  }) async {
    final def = pickCollectibleDef(
      collectiblesForCity(destCity),
      ownedDefIds(),
      _rng,
    );
    if (def == null) return null;
    final owned = OwnedCollectible(
      id: sessionId,
      defId: def.id,
      city: def.city,
      categoryIndex: def.category.index,
      name: def.name,
      emoji: def.emoji,
      acquiredAt: acquiredAt,
      originName: originName,
      destName: destName,
      transportIndex: transportIndex,
      durationSeconds: durationSeconds,
    );
    await save(owned);
    return owned;
  }
}

/// 진열장 카테고리 라벨/이모지는 정의의 index 로 복원.
CollectibleCategory categoryOf(OwnedCollectible c) =>
    CollectibleCategory.values[c.categoryIndex];

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(Hive.box<OwnedCollectible>(collectiblesBoxName)),
);
