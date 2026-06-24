import '../models/collectible_category.dart';
import '../models/collectible_def.dart';

/// 도시별로 도착 시 획득 가능한 컬렉션 정의 목록.
/// city 값은 Place.city 와 정확히 일치해야 한다(매칭 키).
const _c = CollectibleCategory.specialty;
const _f = CollectibleCategory.food;
const _t = CollectibleCategory.tradition;
const _l = CollectibleCategory.landmark;

const allCollectibles = <CollectibleDef>[
  // ── 서울 ──────────────────────────────────────────────
  CollectibleDef(id: 'seoul_gyeongbok', city: '서울', category: _l, name: '경복궁', emoji: '🏯', description: '조선의 법궁. 광화문과 근정전이 자리한 도심 속 궁궐.'),
  CollectibleDef(id: 'seoul_seolleongtang', city: '서울', category: _f, name: '설렁탕', emoji: '🍲', description: '뽀얀 국물에 밥을 말아 먹는 서울 대표 국밥.'),
  CollectibleDef(id: 'seoul_jongmyo', city: '서울', category: _t, name: '종묘제례악', emoji: '🎭', description: '조선 왕실 제례에 쓰인 음악과 춤(유네스코 인류무형유산).'),
  CollectibleDef(id: 'seoul_namsan', city: '서울', category: _l, name: 'N서울타워', emoji: '🗼', description: '남산 정상에 선 서울의 상징 전망 타워.'),

  // ── 인천 ──────────────────────────────────────────────
  CollectibleDef(id: 'incheon_chinatown', city: '인천', category: _l, name: '차이나타운', emoji: '🏮', description: '짜장면이 처음 만들어진 곳으로 알려진 인천 명소.'),
  CollectibleDef(id: 'incheon_dakgangjeong', city: '인천', category: _f, name: '신포 닭강정', emoji: '🍗', description: '바삭하고 달콤한 신포시장 명물 닭강정.'),
  CollectibleDef(id: 'incheon_wolmido', city: '인천', category: _l, name: '월미도', emoji: '🎡', description: '바다와 놀이공원이 어우러진 인천의 낭만 거리.'),
  CollectibleDef(id: 'incheon_hwamunseok', city: '인천', category: _c, name: '강화 화문석', emoji: '🪶', description: '강화도 전통 꽃돗자리. 왕골을 한 올씩 엮어 만든다.'),

  // ── 광명 ──────────────────────────────────────────────
  CollectibleDef(id: 'gwangmyeong_cave', city: '광명', category: _l, name: '광명동굴', emoji: '🕳️', description: '폐광을 문화·예술 공간으로 되살린 수도권 명소.'),
  CollectibleDef(id: 'gwangmyeong_wine', city: '광명', category: _c, name: '광명동굴 와인', emoji: '🍷', description: '서늘한 동굴에서 숙성·전시되는 국산 와인.'),
  CollectibleDef(id: 'gwangmyeong_cherry', city: '광명', category: _l, name: '안양천 벚꽃길', emoji: '🌸', description: '봄이면 벚꽃 터널이 펼쳐지는 안양천 산책로.'),

  // ── 수원 ──────────────────────────────────────────────
  CollectibleDef(id: 'suwon_hwaseong', city: '수원', category: _l, name: '수원화성', emoji: '🏯', description: '정조가 쌓은 성곽. 유네스코 세계문화유산.'),
  CollectibleDef(id: 'suwon_galbi', city: '수원', category: _f, name: '수원 왕갈비', emoji: '🍖', description: '큼직하게 썰어 양념한 수원의 대표 갈비.'),
  CollectibleDef(id: 'suwon_haenggung', city: '수원', category: _t, name: '화성행궁', emoji: '🏛️', description: '정조가 행차 때 머물던 가장 큰 규모의 행궁.'),
  CollectibleDef(id: 'suwon_tongdak', city: '수원', category: _f, name: '통닭거리', emoji: '🍗', description: '가마솥 통닭으로 유명한 수원 남문 먹자골목.'),

  // ── 아산 ──────────────────────────────────────────────
  CollectibleDef(id: 'asan_oncheon', city: '아산', category: _l, name: '온양온천', emoji: '♨️', description: '600년 역사를 가진 한국에서 가장 오래된 온천.'),
  CollectibleDef(id: 'asan_hyeonchungsa', city: '아산', category: _t, name: '현충사', emoji: '🏯', description: '충무공 이순신을 기리는 사당.'),
  CollectibleDef(id: 'asan_pear', city: '아산', category: _c, name: '아산 배', emoji: '🍐', description: '맑고 단 과즙으로 이름난 아산의 배.'),
  CollectibleDef(id: 'asan_oeam', city: '아산', category: _t, name: '외암민속마을', emoji: '🏘️', description: '돌담과 초가가 그대로 보존된 전통 마을.'),

  // ── 청주 ──────────────────────────────────────────────
  CollectibleDef(id: 'cheongju_jikji', city: '청주', category: _t, name: '직지', emoji: '📜', description: '현존 세계 最古 금속활자 인쇄본 직지심체요절.'),
  CollectibleDef(id: 'cheongju_sangdang', city: '청주', category: _l, name: '상당산성', emoji: '🏯', description: '청주 시내를 굽어보는 조선시대 석축 산성.'),
  CollectibleDef(id: 'cheongju_rice', city: '청주', category: _c, name: '청원생명쌀', emoji: '🌾', description: '맑은 물로 키운 청주 청원 지역의 친환경 쌀.'),
  CollectibleDef(id: 'cheongju_suamgol', city: '청주', category: _l, name: '수암골', emoji: '🎨', description: '벽화로 되살아난 정겨운 달동네 골목.'),

  // ── 대전 ──────────────────────────────────────────────
  CollectibleDef(id: 'daejeon_sungsimdang', city: '대전', category: _f, name: '성심당 튀김소보로', emoji: '🥖', description: '대전을 대표하는 빵집 성심당의 명물 빵.'),
  CollectibleDef(id: 'daejeon_kalguksu', city: '대전', category: _f, name: '대전 칼국수', emoji: '🍜', description: '칼국수 거리로 유명한 대전의 손칼국수.'),
  CollectibleDef(id: 'daejeon_expo', city: '대전', category: _l, name: '엑스포과학공원', emoji: '🛰️', description: '93 대전엑스포의 상징, 한빛탑이 있는 과학공원.'),
  CollectibleDef(id: 'daejeon_arboretum', city: '대전', category: _l, name: '한밭수목원', emoji: '🌳', description: '도심 속 국내 최대 규모의 인공 수목원.'),

  // ── 대구 ──────────────────────────────────────────────
  CollectibleDef(id: 'daegu_makchang', city: '대구', category: _f, name: '대구 막창', emoji: '🍢', description: '연탄불에 구워 된장소스에 찍어 먹는 대구 별미.'),
  CollectibleDef(id: 'daegu_dongseongno', city: '대구', category: _l, name: '동성로', emoji: '🛍️', description: '대구 최대 번화가이자 만남의 거리.'),
  CollectibleDef(id: 'daegu_gatbawi', city: '대구', category: _l, name: '팔공산 갓바위', emoji: '⛰️', description: '한 가지 소원은 꼭 들어준다는 기도 명소.'),
  CollectibleDef(id: 'daegu_apple', city: '대구', category: _c, name: '대구 사과', emoji: '🍎', description: '"능금의 고장" 대구를 대표하던 새콤달콤한 사과.'),

  // ── 부산 ──────────────────────────────────────────────
  CollectibleDef(id: 'busan_haeundae', city: '부산', category: _l, name: '해운대', emoji: '🏖️', description: '한국에서 가장 유명한 도심 해수욕장.'),
  CollectibleDef(id: 'busan_dwaeji', city: '부산', category: _f, name: '돼지국밥', emoji: '🍲', description: '진한 사골 국물에 밥을 마는 부산 소울푸드.'),
  CollectibleDef(id: 'busan_jagalchi', city: '부산', category: _l, name: '자갈치시장', emoji: '🐟', description: '"오이소~" 활기 넘치는 한국 최대 수산시장.'),
  CollectibleDef(id: 'busan_eomuk', city: '부산', category: _c, name: '부산어묵', emoji: '🍢', description: '쫄깃한 식감으로 전국에 이름난 부산 어묵.'),

  // ── 울산 ──────────────────────────────────────────────
  CollectibleDef(id: 'ulsan_ganjeolgot', city: '울산', category: _l, name: '간절곶', emoji: '🌅', description: '한반도에서 해가 가장 먼저 뜨는 곳 중 하나.'),
  CollectibleDef(id: 'ulsan_taehwa', city: '울산', category: _l, name: '태화강 국가정원', emoji: '🌿', description: '대나무 숲과 강이 어우러진 도심 국가정원.'),
  CollectibleDef(id: 'ulsan_eonyang', city: '울산', category: _f, name: '언양불고기', emoji: '🥩', description: '석쇠에 구워내는 울산 언양식 한우 불고기.'),
  CollectibleDef(id: 'ulsan_whale', city: '울산', category: _t, name: '장생포 고래문화', emoji: '🐋', description: '반구대 암각화로 이어지는 울산의 고래 이야기.'),

  // ── 익산 ──────────────────────────────────────────────
  CollectibleDef(id: 'iksan_mireuksa', city: '익산', category: _l, name: '미륵사지 석탑', emoji: '🗼', description: '현존 最古·最大의 백제 석탑(국보).'),
  CollectibleDef(id: 'iksan_jewelry', city: '익산', category: _c, name: '익산 보석', emoji: '💎', description: '국내 최대 주얼리 산업단지가 있는 보석의 도시.'),
  CollectibleDef(id: 'iksan_wanggung', city: '익산', category: _t, name: '왕궁리 유적', emoji: '🏛️', description: '백제 왕궁터로 전하는 사적.'),
  CollectibleDef(id: 'iksan_bibimbap', city: '익산', category: _f, name: '황등비빔밥', emoji: '🍱', description: '육회를 얹어 비비는 익산 황등식 비빔밥.'),

  // ── 전주 ──────────────────────────────────────────────
  CollectibleDef(id: 'jeonju_bibimbap', city: '전주', category: _f, name: '전주비빔밥', emoji: '🍱', description: '갖은 나물과 고추장으로 비비는 전주의 대표 음식.'),
  CollectibleDef(id: 'jeonju_hanok', city: '전주', category: _l, name: '전주 한옥마을', emoji: '🏘️', description: '700여 채 한옥이 모인 전통 마을.'),
  CollectibleDef(id: 'jeonju_hanji', city: '전주', category: _c, name: '전주 한지', emoji: '📜', description: '천년을 간다는 전주의 전통 한지.'),
  CollectibleDef(id: 'jeonju_kongnamul', city: '전주', category: _f, name: '콩나물국밥', emoji: '🍲', description: '뜨끈하게 속을 풀어주는 전주식 국밥.'),

  // ── 광주 ──────────────────────────────────────────────
  CollectibleDef(id: 'gwangju_mudeung', city: '광주', category: _l, name: '무등산', emoji: '⛰️', description: '주상절리 입석대로 유명한 광주의 진산.'),
  CollectibleDef(id: 'gwangju_kimchi', city: '광주', category: _f, name: '광주 김치', emoji: '🥬', description: '깊고 진한 맛으로 김치축제가 열리는 고장.'),
  CollectibleDef(id: 'gwangju_yangrim', city: '광주', category: _l, name: '양림동 근대골목', emoji: '🏘️', description: '근대 건축과 예술이 어우러진 골목.'),
  CollectibleDef(id: 'gwangju_tteokgalbi', city: '광주', category: _f, name: '송정 떡갈비', emoji: '🍖', description: '다진 고기를 빚어 구워내는 광주 송정 떡갈비.'),

  // ── 목포 ──────────────────────────────────────────────
  CollectibleDef(id: 'mokpo_gatbawi', city: '목포', category: _l, name: '목포 갓바위', emoji: '🪨', description: '바닷가에 솟은 갓 모양의 천연기념물 바위.'),
  CollectibleDef(id: 'mokpo_nakji', city: '목포', category: _f, name: '세발낙지', emoji: '🐙', description: '가늘고 부드러운 목포 갯벌의 낙지.'),
  CollectibleDef(id: 'mokpo_yudal', city: '목포', category: _l, name: '유달산', emoji: '⛰️', description: '목포 항구를 품은 시민의 산.'),
  CollectibleDef(id: 'mokpo_hongeo', city: '목포', category: _f, name: '홍어삼합', emoji: '🐟', description: '삭힌 홍어·돼지고기·묵은지의 남도 별미.'),

  // ── 강릉 ──────────────────────────────────────────────
  CollectibleDef(id: 'gangneung_gyeongpo', city: '강릉', category: _l, name: '경포대', emoji: '🌊', description: '호수와 바다를 함께 보는 강릉의 명승.'),
  CollectibleDef(id: 'gangneung_chodang', city: '강릉', category: _f, name: '초당두부', emoji: '🥡', description: '바닷물로 간을 맞춘 강릉 초당마을 손두부.'),
  CollectibleDef(id: 'gangneung_coffee', city: '강릉', category: _c, name: '강릉 커피', emoji: '☕', description: '안목 커피거리에서 시작된 강릉의 커피 문화.'),
  CollectibleDef(id: 'gangneung_ojukheon', city: '강릉', category: _t, name: '오죽헌', emoji: '🏯', description: '신사임당과 율곡 이이가 태어난 집.'),

  // ── 여수 ──────────────────────────────────────────────
  CollectibleDef(id: 'yeosu_night', city: '여수', category: _l, name: '여수 밤바다', emoji: '🌃', description: '노래로도 유명한 여수의 반짝이는 밤바다.'),
  CollectibleDef(id: 'yeosu_gat', city: '여수', category: _c, name: '돌산갓김치', emoji: '🥬', description: '알싸하고 시원한 여수 돌산의 갓김치.'),
  CollectibleDef(id: 'yeosu_gejang', city: '여수', category: _f, name: '게장백반', emoji: '🦀', description: '밥도둑 간장게장으로 차린 여수 한상.'),
  CollectibleDef(id: 'yeosu_hyangiram', city: '여수', category: _l, name: '향일암', emoji: '🌅', description: '바다 위 일출로 이름난 절벽 암자.'),

  // ── 천안 ──────────────────────────────────────────────
  CollectibleDef(id: 'cheonan_walnut', city: '천안', category: _f, name: '천안 호두과자', emoji: '🥮', description: '호두를 넣어 구운 천안의 대표 명물.'),
  CollectibleDef(id: 'cheonan_independence', city: '천안', category: _t, name: '독립기념관', emoji: '🇰🇷', description: '겨레의 독립 역사를 모은 기념관.'),
  CollectibleDef(id: 'cheonan_grape', city: '천안', category: _c, name: '천안 거봉포도', emoji: '🍇', description: '알이 굵고 단 천안 입장의 거봉포도.'),
  CollectibleDef(id: 'cheonan_gwangdeoksa', city: '천안', category: _l, name: '광덕사', emoji: '🛕', description: '호두나무 시배지로 전하는 천년 고찰.'),

  // ── 춘천 ──────────────────────────────────────────────
  CollectibleDef(id: 'chuncheon_dakgalbi', city: '춘천', category: _f, name: '춘천 닭갈비', emoji: '🍗', description: '철판에 볶아 먹는 춘천의 대표 음식.'),
  CollectibleDef(id: 'chuncheon_nami', city: '춘천', category: _l, name: '남이섬', emoji: '🌲', description: '메타세쿼이아 길로 유명한 강 위의 섬.'),
  CollectibleDef(id: 'chuncheon_makguksu', city: '춘천', category: _f, name: '막국수', emoji: '🍜', description: '메밀로 뽑은 시원한 춘천 막국수.'),
  CollectibleDef(id: 'chuncheon_skywalk', city: '춘천', category: _l, name: '소양강 스카이워크', emoji: '🌉', description: '강 위를 걷는 투명 유리 전망 다리.'),

  // ── 제주 ──────────────────────────────────────────────
  CollectibleDef(id: 'jeju_halla', city: '제주', category: _l, name: '한라산', emoji: '🌋', description: '남한 최고봉이자 제주의 중심 화산.'),
  CollectibleDef(id: 'jeju_pork', city: '제주', category: _f, name: '흑돼지', emoji: '🐖', description: '쫄깃하고 고소한 제주 흑돼지 구이.'),
  CollectibleDef(id: 'jeju_tangerine', city: '제주', category: _c, name: '제주 감귤', emoji: '🍊', description: '겨울이면 제주를 노랗게 물들이는 귤.'),
  CollectibleDef(id: 'jeju_haenyeo', city: '제주', category: _t, name: '제주 해녀', emoji: '🤿', description: '맨몸으로 바다에 드는 해녀 문화(유네스코).'),

  // ── 무안 ──────────────────────────────────────────────
  CollectibleDef(id: 'muan_onion', city: '무안', category: _c, name: '무안 양파', emoji: '🧅', description: '국내 손꼽히는 산지의 달큰한 무안 양파.'),
  CollectibleDef(id: 'muan_getbol', city: '무안', category: _l, name: '무안 갯벌', emoji: '🦀', description: '습지보호구역으로 지정된 드넓은 갯벌.'),
  CollectibleDef(id: 'muan_nakji', city: '무안', category: _f, name: '무안 낙지', emoji: '🐙', description: '청정 갯벌에서 난 부드러운 세발낙지.'),
  CollectibleDef(id: 'muan_baengnyeon', city: '무안', category: _l, name: '회산 백련지', emoji: '🪷', description: '동양 최대 규모의 백련 자생 연못.'),

  // ── 포항 ──────────────────────────────────────────────
  CollectibleDef(id: 'pohang_homigot', city: '포항', category: _l, name: '호미곶', emoji: '🌅', description: '바다에서 솟은 "상생의 손"과 일출 명소.'),
  CollectibleDef(id: 'pohang_gwamegi', city: '포항', category: _f, name: '구룡포 과메기', emoji: '🐟', description: '꽁치를 얼리고 말려 만든 포항 겨울 별미.'),
  CollectibleDef(id: 'pohang_yeongildae', city: '포항', category: _l, name: '영일대 해수욕장', emoji: '🏖️', description: '바다 위 누각에서 야경을 즐기는 해변.'),
  CollectibleDef(id: 'pohang_mulhoe', city: '포항', category: _f, name: '포항 물회', emoji: '🍲', description: '시원하게 말아 먹는 동해안 물회.'),

  // ── 양양 ──────────────────────────────────────────────
  CollectibleDef(id: 'yangyang_songi', city: '양양', category: _c, name: '양양 송이버섯', emoji: '🍄', description: '향이 진하기로 이름난 양양의 자연산 송이.'),
  CollectibleDef(id: 'yangyang_hajodae', city: '양양', category: _l, name: '하조대', emoji: '🌅', description: '소나무와 정자, 일출이 어우러진 절경.'),
  CollectibleDef(id: 'yangyang_naksansa', city: '양양', category: _t, name: '낙산사', emoji: '🛕', description: '동해를 굽어보는 관음 도량 천년 고찰.'),
  CollectibleDef(id: 'yangyang_surf', city: '양양', category: _l, name: '서피비치', emoji: '🏄', description: '서핑의 성지로 떠오른 양양의 해변.'),

  // ── 군산 ──────────────────────────────────────────────
  CollectibleDef(id: 'gunsan_isungdang', city: '군산', category: _f, name: '이성당 빵', emoji: '🍞', description: '현존 국내 最古 빵집 이성당의 단팥빵·야채빵.'),
  CollectibleDef(id: 'gunsan_modern', city: '군산', category: _t, name: '근대문화거리', emoji: '🏛️', description: '일제강점기 건물이 남은 군산 근대역사 거리.'),
  CollectibleDef(id: 'gunsan_jjamppong', city: '군산', category: _f, name: '군산 짬뽕', emoji: '🍜', description: '짬뽕 특화거리가 있을 만큼 유명한 군산 짬뽕.'),
  CollectibleDef(id: 'gunsan_seonyudo', city: '군산', category: _l, name: '선유도', emoji: '🏝️', description: '고운 모래해변과 다리로 이어진 고군산군도의 섬.'),

  // ── 사천 ──────────────────────────────────────────────
  CollectibleDef(id: 'sacheon_hoe', city: '사천', category: _f, name: '삼천포 회', emoji: '🐟', description: '삼천포항에서 올라온 싱싱한 활어회.'),
  CollectibleDef(id: 'sacheon_cablecar', city: '사천', category: _l, name: '사천 바다케이블카', emoji: '🚠', description: '바다와 섬, 산을 잇는 전망 케이블카.'),
  CollectibleDef(id: 'sacheon_aerospace', city: '사천', category: _l, name: '항공우주박물관', emoji: '🛩️', description: '항공산업의 도시 사천의 비행기 박물관.'),
  CollectibleDef(id: 'sacheon_gulhang', city: '사천', category: _t, name: '대방진굴항', emoji: '⚓', description: '왜구를 막기 위해 판 조선시대 군항 유적.'),
];

/// 해당 도시에서 획득 가능한 컬렉션 정의 목록.
List<CollectibleDef> collectiblesForCity(String city) =>
    allCollectibles.where((d) => d.city == city).toList();

/// defId 로 정의 조회. 없으면 null.
CollectibleDef? collectibleDefById(String id) {
  for (final d in allCollectibles) {
    if (d.id == id) return d;
  }
  return null;
}
