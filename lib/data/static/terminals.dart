import '../models/place.dart';
import '../models/transport_type.dart';

/// MVP용 정적 버스터미널 목록.
const busTerminals = <Place>[
  Place(id: 'seoul_express_term', name: '서울고속버스터미널', city: '서울', type: TransportType.bus, lat: 37.5048, lng: 127.0048),
  Place(id: 'dongseoul_term', name: '동서울종합터미널', city: '서울', type: TransportType.bus, lat: 37.5347, lng: 127.0947),
  Place(id: 'incheon_term', name: '인천종합터미널', city: '인천', type: TransportType.bus, lat: 37.4419, lng: 126.7008),
  Place(id: 'jeonju_term', name: '전주고속버스터미널', city: '전주', type: TransportType.bus, lat: 35.8243, lng: 127.1480),
  Place(id: 'gwangju_term', name: '광주종합버스터미널', city: '광주', type: TransportType.bus, lat: 35.1601, lng: 126.8784),
  Place(id: 'daejeon_term', name: '대전복합터미널', city: '대전', type: TransportType.bus, lat: 36.3504, lng: 127.4346),
  Place(id: 'cheongju_term', name: '청주고속버스터미널', city: '청주', type: TransportType.bus, lat: 36.6320, lng: 127.4400),
  Place(id: 'cheonan_term', name: '천안종합터미널', city: '천안', type: TransportType.bus, lat: 36.8200, lng: 127.1560),
  Place(id: 'dongdaegu_term', name: '동대구터미널', city: '대구', type: TransportType.bus, lat: 35.8772, lng: 128.6285),
  Place(id: 'busan_term', name: '부산종합버스터미널', city: '부산', type: TransportType.bus, lat: 35.2519, lng: 129.0920),
  Place(id: 'chuncheon_term', name: '춘천시외버스터미널', city: '춘천', type: TransportType.bus, lat: 37.8758, lng: 127.7260),
  Place(id: 'gangneung_term', name: '강릉시외버스터미널', city: '강릉', type: TransportType.bus, lat: 37.7630, lng: 128.8960),
  Place(id: 'mokpo_term', name: '목포종합버스터미널', city: '목포', type: TransportType.bus, lat: 34.8118, lng: 126.4400),
  Place(id: 'yeosu_term', name: '여수종합버스터미널', city: '여수', type: TransportType.bus, lat: 34.7616, lng: 127.7000),
];
