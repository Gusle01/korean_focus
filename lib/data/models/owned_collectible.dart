import 'package:hive/hive.dart';

part 'owned_collectible.g.dart';

/// 사용자가 실제로 획득해 진열장에 보관 중인 컬렉션 1건. (Hive 저장 대상)
///
/// 진열장에서 "언제 / 어디서 출발해 / 어떤 교통수단으로 / 얼마나 걸려" 얻었는지
/// 보여주기 위해 획득 당시의 여정 정보를 함께 저장한다.
@HiveType(typeId: 1)
class OwnedCollectible {
  @HiveField(0)
  final String id; // 인스턴스 id (획득 세션과 1:1)
  @HiveField(1)
  final String defId; // CollectibleDef.id (도감/중복 판정용)
  @HiveField(2)
  final String city; // 획득 지역(도착 도시)
  @HiveField(3)
  final int categoryIndex; // CollectibleCategory.index
  @HiveField(4)
  final String name;
  @HiveField(5)
  final String emoji;
  @HiveField(6)
  final DateTime acquiredAt; // 획득 날짜
  @HiveField(7)
  final String originName; // 출발 지역(장소명)
  @HiveField(8)
  final String destName; // 도착 지역(장소명)
  @HiveField(9)
  final int transportIndex; // TransportType.index (이동 수단)
  @HiveField(10)
  final int durationSeconds; // 소요 시간(실제 집중 시간, 초)

  const OwnedCollectible({
    required this.id,
    required this.defId,
    required this.city,
    required this.categoryIndex,
    required this.name,
    required this.emoji,
    required this.acquiredAt,
    required this.originName,
    required this.destName,
    required this.transportIndex,
    required this.durationSeconds,
  });
}
