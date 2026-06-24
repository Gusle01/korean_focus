import '../models/place.dart';
import '../models/transport_type.dart';

/// MVP용 정적 기차역 목록.
const trainStations = <Place>[
  Place(id: 'seoul_st', name: '서울역', city: '서울', type: TransportType.train, lat: 37.5547, lng: 126.9706),
  Place(id: 'yongsan_st', name: '용산역', city: '서울', type: TransportType.train, lat: 37.5299, lng: 126.9645),
  Place(id: 'gwangmyeong_st', name: '광명역', city: '광명', type: TransportType.train, lat: 37.4163, lng: 126.8847),
  Place(id: 'suwon_st', name: '수원역', city: '수원', type: TransportType.train, lat: 37.2659, lng: 127.0001),
  Place(id: 'cheonan_asan_st', name: '천안아산역', city: '아산', type: TransportType.train, lat: 36.7945, lng: 127.1045),
  Place(id: 'osong_st', name: '오송역', city: '청주', type: TransportType.train, lat: 36.6201, lng: 127.3275),
  Place(id: 'daejeon_st', name: '대전역', city: '대전', type: TransportType.train, lat: 36.3315, lng: 127.4347),
  Place(id: 'dongdaegu_st', name: '동대구역', city: '대구', type: TransportType.train, lat: 35.8797, lng: 128.6286),
  Place(id: 'busan_st', name: '부산역', city: '부산', type: TransportType.train, lat: 35.1151, lng: 129.0413),
  Place(id: 'ulsan_st', name: '울산역', city: '울산', type: TransportType.train, lat: 35.5512, lng: 129.1390),
  Place(id: 'iksan_st', name: '익산역', city: '익산', type: TransportType.train, lat: 35.9379, lng: 126.9573),
  Place(id: 'jeonju_st', name: '전주역', city: '전주', type: TransportType.train, lat: 35.8497, lng: 127.1601),
  Place(id: 'gwangju_songjeong_st', name: '광주송정역', city: '광주', type: TransportType.train, lat: 35.1366, lng: 126.7931),
  Place(id: 'mokpo_st', name: '목포역', city: '목포', type: TransportType.train, lat: 34.7916, lng: 126.3886),
  Place(id: 'gangneung_st', name: '강릉역', city: '강릉', type: TransportType.train, lat: 37.7639, lng: 128.8970),
  Place(id: 'yeosu_expo_st', name: '여수엑스포역', city: '여수', type: TransportType.train, lat: 34.7616, lng: 127.7470),
];
