enum TransportType { bus, train, airplane }

extension TransportTypeX on TransportType {
  /// 교통수단 표시명: 버스 / 기차 / 비행기
  String get label => switch (this) {
        TransportType.bus => '버스',
        TransportType.train => '기차',
        TransportType.airplane => '비행기',
      };

  /// 정류 지점 단위명: 터미널 / 역 / 공항
  String get spotLabel => switch (this) {
        TransportType.bus => '터미널',
        TransportType.train => '역',
        TransportType.airplane => '공항',
      };

  String get emoji => switch (this) {
        TransportType.bus => '🚌',
        TransportType.train => '🚆',
        TransportType.airplane => '✈️',
      };
}
