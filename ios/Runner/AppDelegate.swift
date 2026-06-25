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
/// 위젯이 시작~종료 시각 구간으로 스스로 카운트다운하므로(Text/ProgressView timerInterval),
/// 앱은 시작·일시정지·재개·종료 때만 상태를 갱신한다(초당 갱신 불필요, 백그라운드에도 똑딱임).
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
  private func contentState(_ a: [String: Any]) -> FocusJourneyAttributes.ContentState {
    FocusJourneyAttributes.ContentState(
      startEpoch: (a["startMs"] as? NSNumber)?.doubleValue ?? 0,
      endEpoch: (a["endMs"] as? NSNumber)?.doubleValue ?? 0,
      paused: (a["paused"] as? NSNumber)?.boolValue ?? false,
      remaining: (a["remaining"] as? NSNumber)?.intValue ?? 0,
      progress: (a["progress"] as? NSNumber)?.doubleValue ?? 0.0
    )
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
    let attributes = FocusJourneyAttributes(origin: origin, dest: dest, emoji: emoji)
    do {
      let activity = try Activity.request(
        attributes: attributes, contentState: contentState(a))
      result(activity.id)
    } catch {
      result(nil)
    }
  }

  @available(iOS 16.1, *)
  private func update(_ args: Any?, _ result: @escaping FlutterResult) {
    let state = contentState(args as? [String: Any] ?? [:])
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
    var startEpoch: Double // 시작 시각(ms) — 진행/카운트다운 기준
    var endEpoch: Double // 종료 시각(ms)
    var paused: Bool // 일시정지면 정적 표시
    var remaining: Int // 일시정지/폴백 표시용 남은 초
    var progress: Double // 일시정지/폴백 표시용 진행률
  }

  var origin: String
  var dest: String
  var emoji: String
}
