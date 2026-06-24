# 집중행 (korean_focus)

집중 시간을 **한국의 이동 여정**으로 시각화하는 크로스플랫폼(Flutter) 집중 타이머 앱.

버스 · 기차 · 비행기 중 하나를 고르고 실제 한국의 터미널/역/공항을 출발지·도착지로 선택하면,
집중하는 동안 지도 위에서 교통수단이 목적지를 향해 이동한다. 도착하면 집중 여정 완료.
("Focus Flight"을 한국 교통/지역 감성으로 재해석)

## 기술 스택
- Flutter 3.44 / Dart 3.12 (Android · iOS)
- 상태관리: `flutter_riverpod`
- 라우팅: `go_router`
- 로컬 저장: `hive`
- 폰트: `google_fonts` (Noto Sans KR)
- 지도/경로 애니메이션: `CustomPainter` 직접 구현 (MVP는 실제 지도 미사용)

## 프로젝트 구조
```
lib/
├─ main.dart            # Hive 초기화 + ProviderScope
├─ app.dart             # MaterialApp.router
├─ core/                # theme · router · utils(geo, duration_format)
├─ data/
│  ├─ models/           # transport_type, place, journey_route, focus_session
│  ├─ static/           # 기차역·터미널·공항 + 소요시간 테이블
│  └─ repositories/     # place(검색) · session(저장/집계)
└─ features/            # home · (이후) transport/place/confirm/focus/complete
```

## 실행
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Hive 어댑터 생성
flutter run
```

## 진행 상황
- [x] Phase 0 — 프로젝트 스캐폴딩 + 패키지
- [x] Phase 1 — 데이터 레이어 (모델 · 정적데이터 · 리포지토리 · 테스트 9개)
- [ ] Phase 2 — 교통수단 선택 / 출발·도착 선택(검색)
- [ ] Phase 3~ — 여정 확인 · 집중 타이머 · 지도 애니메이션 · 완료 화면

## 테스트
```bash
flutter test
flutter analyze
```
