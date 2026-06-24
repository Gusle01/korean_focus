import ActivityKit
import SwiftUI
import WidgetKit

/// ⚠️ 이 구조체는 Runner 타깃(AppDelegate.swift)의 FocusJourneyAttributes 와
/// 필드가 정확히 동일해야 Live Activity 가 연결됩니다. 한쪽을 바꾸면 다른 쪽도 함께 수정하세요.
struct FocusJourneyAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var remaining: Int // 남은 초
    var progress: Double // 0.0 ~ 1.0
  }

  var origin: String
  var dest: String
  var emoji: String
}

private func formatRemaining(_ seconds: Int) -> String {
  let m = seconds / 60
  let s = seconds % 60
  if m >= 60 {
    return String(format: "%d:%02d:%02d", m / 60, m % 60, s)
  }
  return String(format: "%02d:%02d", m, s)
}

/// 잠금화면 배너 + 다이나믹 아일랜드 UI.
struct FocusJourneyLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: FocusJourneyAttributes.self) { context in
      // 잠금화면 / 배너
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(context.attributes.emoji)
          Text("\(context.attributes.origin) → \(context.attributes.dest)")
            .font(.headline)
          Spacer()
          Text(formatRemaining(context.state.remaining))
            .monospacedDigit()
            .font(.headline)
        }
        ProgressView(value: context.state.progress)
          .tint(.orange)
        Text("집중 여정 진행 중")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding()
      .activityBackgroundTint(Color.black.opacity(0.55))
      .activitySystemActionForegroundColor(Color.white)

    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(context.attributes.emoji).font(.title2)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(formatRemaining(context.state.remaining))
            .monospacedDigit()
            .font(.title3)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            Text("\(context.attributes.origin) → \(context.attributes.dest)")
              .font(.caption)
            ProgressView(value: context.state.progress).tint(.orange)
          }
        }
      } compactLeading: {
        Text(context.attributes.emoji)
      } compactTrailing: {
        Text(formatRemaining(context.state.remaining))
          .monospacedDigit()
          .frame(maxWidth: 56)
      } minimal: {
        Text(context.attributes.emoji)
      }
    }
  }
}
