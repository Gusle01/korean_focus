import 'collectible_category.dart';

/// 도시별로 획득 가능한 컬렉션 아이템 '정의'(정적 데이터).
/// 도착 시 해당 도시의 정의 중 하나가 [OwnedCollectible]로 지급된다.
class CollectibleDef {
  final String id; // 고유 정의 id, 예: jeonju_bibimbap
  final String city; // 도시명, 예: 전주
  final CollectibleCategory category;
  final String name; // 예: 전주비빔밥
  final String emoji; // 예: 🍱
  final String description;

  const CollectibleDef({
    required this.id,
    required this.city,
    required this.category,
    required this.name,
    required this.emoji,
    required this.description,
  });
}
