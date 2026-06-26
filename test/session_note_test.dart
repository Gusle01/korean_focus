import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/models/focus_session.dart';

void main() {
  final base = FocusSession(
    id: '1',
    originName: '서울역',
    destName: '부산역',
    transportIndex: 1,
    plannedSeconds: 3600,
    focusedSeconds: 3600,
    startedAt: DateTime(2026, 6, 27),
    completed: true,
  );

  test('기본 회고는 null', () {
    expect(base.note, isNull);
  });

  test('copyWith로 회고를 남긴다(다른 필드는 보존)', () {
    final withNote = base.copyWith(note: '논문 서론 정리');
    expect(withNote.note, '논문 서론 정리');
    expect(withNote.id, base.id);
    expect(withNote.destName, base.destName);
    expect(withNote.completed, isTrue);
  });

  test('clearNote로 회고를 지운다', () {
    final cleared = base.copyWith(note: '메모').copyWith(clearNote: true);
    expect(cleared.note, isNull);
  });
}
