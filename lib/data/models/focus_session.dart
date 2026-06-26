import 'package:hive/hive.dart';

part 'focus_session.g.dart';

/// 완료/기록된 집중 세션 1건. (Hive 저장 대상)
@HiveType(typeId: 0)
class FocusSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String originName;
  @HiveField(2)
  final String destName;
  @HiveField(3)
  final int transportIndex; // TransportType.index
  @HiveField(4)
  final int plannedSeconds; // 목표 집중 시간
  @HiveField(5)
  final int focusedSeconds; // 실제 집중한 시간
  @HiveField(6)
  final DateTime startedAt;
  @HiveField(7)
  final bool completed; // 도착(완주) 여부
  @HiveField(8)
  final String? note; // 한 줄 회고("뭘 집중했는지") — 도착 후 입력, 없으면 null

  const FocusSession({
    required this.id,
    required this.originName,
    required this.destName,
    required this.transportIndex,
    required this.plannedSeconds,
    required this.focusedSeconds,
    required this.startedAt,
    required this.completed,
    this.note,
  });

  FocusSession copyWith({String? note, bool clearNote = false}) => FocusSession(
        id: id,
        originName: originName,
        destName: destName,
        transportIndex: transportIndex,
        plannedSeconds: plannedSeconds,
        focusedSeconds: focusedSeconds,
        startedAt: startedAt,
        completed: completed,
        note: clearNote ? null : (note ?? this.note),
      );
}
