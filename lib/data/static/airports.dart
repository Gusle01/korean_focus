import '../models/place.dart';
import '../models/transport_type.dart';

/// MVP용 정적 공항 목록.
const airports = <Place>[
  Place(id: 'incheon_ap', name: '인천국제공항', city: '인천', type: TransportType.airplane, lat: 37.4602, lng: 126.4407),
  Place(id: 'gimpo_ap', name: '김포공항', city: '서울', type: TransportType.airplane, lat: 37.5586, lng: 126.7906),
  Place(id: 'jeju_ap', name: '제주공항', city: '제주', type: TransportType.airplane, lat: 33.5113, lng: 126.4930),
  Place(id: 'gimhae_ap', name: '김해공항', city: '부산', type: TransportType.airplane, lat: 35.1795, lng: 128.9382),
  Place(id: 'daegu_ap', name: '대구공항', city: '대구', type: TransportType.airplane, lat: 35.8939, lng: 128.6586),
  Place(id: 'gwangju_ap', name: '광주공항', city: '광주', type: TransportType.airplane, lat: 35.1264, lng: 126.8089),
  Place(id: 'cheongju_ap', name: '청주공항', city: '청주', type: TransportType.airplane, lat: 36.7166, lng: 127.4991),
  Place(id: 'muan_ap', name: '무안공항', city: '무안', type: TransportType.airplane, lat: 34.9914, lng: 126.3828),
  Place(id: 'yeosu_ap', name: '여수공항', city: '여수', type: TransportType.airplane, lat: 34.8423, lng: 127.6166),
  Place(id: 'ulsan_ap', name: '울산공항', city: '울산', type: TransportType.airplane, lat: 35.5936, lng: 129.3517),
  Place(id: 'pohang_ap', name: '포항경주공항', city: '포항', type: TransportType.airplane, lat: 35.9879, lng: 129.4203),
  Place(id: 'yangyang_ap', name: '양양공항', city: '양양', type: TransportType.airplane, lat: 38.0613, lng: 128.6690),
  Place(id: 'gunsan_ap', name: '군산공항', city: '군산', type: TransportType.airplane, lat: 35.9038, lng: 126.6158),
  Place(id: 'sacheon_ap', name: '사천공항', city: '사천', type: TransportType.airplane, lat: 35.0886, lng: 128.0703),
];
