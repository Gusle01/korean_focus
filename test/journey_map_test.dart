import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/models/place.dart';
import 'package:korean_focus/data/models/transport_type.dart';
import 'package:korean_focus/features/focus/journey_map.dart';

void main() {
  testWidgets('JourneyMap 렌더링 스모크 (예외 없이 마커·라벨 표시)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: JourneyMap(
                progress: 0.5,
                transport: TransportType.train,
                origin: Place(
                    id: 'jeonju_st',
                    name: '전주역',
                    city: '전주',
                    type: TransportType.train,
                    lat: 35.8497,
                    lng: 127.1601),
                destination: Place(
                    id: 'seoul_st',
                    name: '서울역',
                    city: '서울',
                    type: TransportType.train,
                    lat: 37.5547,
                    lng: 126.9706),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.train_rounded), findsOneWidget);
    expect(find.text('전주역'), findsOneWidget);
    expect(find.text('서울역'), findsOneWidget);

    // 반복 애니메이션 컨트롤러 정리
    await tester.pumpWidget(const SizedBox());
  });
}
