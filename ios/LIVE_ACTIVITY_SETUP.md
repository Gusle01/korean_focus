# iOS Live Activity (다이나믹 아일랜드) 설정

집중 여정의 실시간 상태를 아이폰 **잠금화면**과 **다이나믹 아일랜드**에
표시하는 Live Activity 기능입니다.

Flutter/Swift 코드는 모두 들어가 있고 **앱 자체는 그대로 빌드**됩니다.
다만 Live Activity 위젯은 별도의 **위젯 익스텐션 타깃**이 필요해서,
아래 한 번의 Xcode 설정이 끝나야 화면에 표시됩니다. (위젯 타깃이 없어도
Android 진행 알림과 iOS 도착 알림은 정상 동작합니다.)

요구 사항: **iOS 16.1+**, 실기기(시뮬레이터는 다이나믹 아일랜드 미표시),
Apple Developer 서명.

## 이미 적용되어 있는 것
- `Runner/Info.plist` → `NSSupportsLiveActivities = YES`
- `Runner/AppDelegate.swift` → ActivityKit 제어 + MethodChannel `korean_focus/live_activity`
- Dart: `lib/core/notifications/` (NotificationService, LiveActivityBridge)
- 위젯 소스: `ios/FocusJourneyWidget/` (타깃에 추가만 하면 됨)

## Xcode 설정 (한 번만)
1. `ios/Runner.xcworkspace` 를 Xcode 로 연다.
2. **File ▸ New ▸ Target… ▸ Widget Extension** 선택.
   - Product Name: `FocusJourneyWidget`
   - **Include Live Activity** 체크, Include Configuration App Intent 는 해제.
   - Finish → "Activate scheme" 묻는 창은 Cancel.
3. Xcode 가 생성한 기본 위젯 파일들은 삭제하고, 대신 이 폴더의
   `FocusJourneyLiveActivity.swift` 와 `FocusJourneyWidgetBundle.swift` 를
   위젯 타깃에 추가한다. (기존 `Info.plist` 는 그대로 두거나 이 폴더 것으로 교체)
4. 위젯 타깃의 **Deployment Target 을 iOS 16.1 이상**으로 설정.
5. `FocusJourneyWidget` 타깃의 `FocusJourneyAttributes` 정의가
   `Runner/AppDelegate.swift` 의 정의와 **필드까지 동일한지** 확인.
   (둘 중 하나만 바꾸면 Live Activity 가 연결되지 않음)
6. 실기기에서 실행 → 집중 시작 시 다이나믹 아일랜드/잠금화면에 표시됨.

> 푸시로 원격 업데이트까지 하려면 App Group + ActivityKit push 설정이 추가로
> 필요하지만, 이 앱은 앱이 켜진 동안 로컬에서 갱신하므로 App Group 없이 동작합니다.
