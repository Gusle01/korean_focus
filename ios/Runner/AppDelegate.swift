import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Live Activity 제어용 MethodChannel 등록.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FocusLiveActivity") {
      let channel = FlutterMethodChannel(
        name: "korean_focus/live_activity",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        LiveActivityManager.shared.handle(call, result)
      }
    }
  }
}

/// iOS 16.1+ Live Activity(다이나믹 아일랜드/잠금화면)를 ActivityKit 으로 제어.
/// 실제 위젯 UI 는 FocusJourneyWidget 익스텐션 타깃에 있다
/// (ios/LIVE_ACTIVITY_SETUP.md 참고). 위젯 타깃이 없으면 알림만 동작한다.
class LiveActivityManager {
  static let shared = LiveActivityManager()

  func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard #available(iOS 16.1, *) else {
      result(nil)
      return
    }
    switch call.method {
    case "start": start(call.arguments, result)
    case "update": update(call.arguments, result)
    case "end": end(result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 16.1, *)
  private func start(_ args: Any?, _ result: @escaping FlutterResult) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled,
          let a = args as? [String: Any],
          let origin = a["origin"] as? String,
          let dest = a["dest"] as? String else {
      result(nil)
      return
    }
    let emoji = a["emoji"] as? String ?? ""
    let remaining = a["remaining"] as? Int ?? 0
    let progress = a["progress"] as? Double ?? 0.0

    let attributes = FocusJourneyAttributes(origin: origin, dest: dest, emoji: emoji)
    let state = FocusJourneyAttributes.ContentState(remaining: remaining, progress: progress)
    do {
      let activity = try Activity.request(attributes: attributes, contentState: state)
      result(activity.id)
    } catch {
      result(nil)
    }
  }

  @available(iOS 16.1, *)
  private func update(_ args: Any?, _ result: @escaping FlutterResult) {
    let a = args as? [String: Any] ?? [:]
    let remaining = a["remaining"] as? Int ?? 0
    let progress = a["progress"] as? Double ?? 0.0
    let state = FocusJourneyAttributes.ContentState(remaining: remaining, progress: progress)
    Task {
      for activity in Activity<FocusJourneyAttributes>.activities {
        await activity.update(using: state)
      }
      result(nil)
    }
  }

  @available(iOS 16.1, *)
  private func end(_ result: @escaping FlutterResult) {
    Task {
      for activity in Activity<FocusJourneyAttributes>.activities {
        await activity.end(dismissalPolicy: .immediate)
      }
      result(nil)
    }
  }
}

/// Live Activity 속성. 위젯 익스텐션의 동일 정의와 반드시 일치해야 한다.
@available(iOS 16.1, *)
struct FocusJourneyAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var remaining: Int // 남은 초
    var progress: Double // 0.0 ~ 1.0
  }

  var origin: String
  var dest: String
  var emoji: String
}
