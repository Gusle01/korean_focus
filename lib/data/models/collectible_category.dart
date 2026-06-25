/// 컬렉션 아이템의 분류: 특산품 · 음식 · 전통 · 명소.
enum CollectibleCategory { specialty, food, tradition, landmark }

extension CollectibleCategoryX on CollectibleCategory {
  String get label => switch (this) {
        CollectibleCategory.specialty => '특산품',
        CollectibleCategory.food => '음식',
        CollectibleCategory.tradition => '전통',
        CollectibleCategory.landmark => '명소',
      };

  String get emoji => switch (this) {
        CollectibleCategory.specialty => '🎁',
        CollectibleCategory.food => '🍲',
        CollectibleCategory.tradition => '🏮',
        CollectibleCategory.landmark => '📍',
      };
}
