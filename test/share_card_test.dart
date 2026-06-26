import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/core/theme/app_theme.dart';
import 'package:korean_focus/features/complete/share_card.dart';

void main() {
  final date = DateTime(2026, 6, 26);

  testWidgets('공유 카드가 오버플로 없이 렌더된다(컬렉션 포함)', (tester) async {
    final data = ShareCardData(
      originName: '서울역',
      destName: '부산역',
      destCity: '부산',
      transportIndex: 1,
      durationSeconds: 9600,
      date: date,
      collectibleEmoji: '🍲',
      collectibleName: '돼지국밥',
      collectibleCategory: '음식',
    );
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: JourneyShareCard(data: data))),
    ));
    await tester.pump();

    expect(find.text('집중행'), findsOneWidget);
    expect(find.text('부산역'), findsOneWidget);
    expect(find.text('돼지국밥'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('컬렉션 없이도 렌더된다', (tester) async {
    final data = ShareCardData(
      originName: '광주송정역',
      destName: '서울역',
      destCity: '서울',
      transportIndex: 1,
      durationSeconds: 1800,
      date: date,
    );
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: JourneyShareCard(data: data))),
    ));
    await tester.pump();

    expect(find.text('집중행'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
