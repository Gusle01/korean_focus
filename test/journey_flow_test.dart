import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:korean_focus/app.dart';
import 'package:korean_focus/data/models/focus_session.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('korean_focus_test');
    Hive.init(dir.path);
    Hive.registerAdapter(FocusSessionAdapter());
    await Hive.openBox<FocusSession>('sessions');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('홈 → 기차 → 전주역 → 서울역 → 여정 확인 전체 흐름', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KoreanFocusApp()));
    await tester.pumpAndSettle();

    // 1) 홈
    expect(find.text('새 여정 시작'), findsOneWidget);
    await tester.tap(find.text('새 여정 시작'));
    await tester.pumpAndSettle();

    // 2) 교통수단 선택
    expect(find.text('무엇을 타고 갈까요?'), findsOneWidget);
    await tester.tap(find.text('기차'));
    await tester.pumpAndSettle();

    // 3) 출발지 선택 (검색)
    expect(find.text('어디서 출발할까요?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '전주');
    await tester.pumpAndSettle();
    await tester.tap(find.text('전주역'));
    await tester.pumpAndSettle();

    // 4) 도착지 선택
    expect(find.text('어디로 갈까요?'), findsOneWidget);
    await tester.tap(find.text('서울역'));
    await tester.pumpAndSettle();

    // 5) 여정 확인 — buildRoute로 계산된 소요시간 표시
    expect(find.text('여정 확인'), findsOneWidget);
    expect(find.text('예상 소요 시간'), findsOneWidget);
    expect(find.text('1시간 40분'), findsOneWidget); // 전주역→서울역 KTX 100분
  });
}
