import ActivityKit
import SwiftUI
import WidgetKit

/// ⚠️ Runner 타깃(AppDelegate.swift)의 FocusJourneyAttributes 와 필드가 정확히 동일해야 함.
struct FocusJourneyAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var startEpoch: Double
    var endEpoch: Double
    var paused: Bool
    var remaining: Int
    var progress: Double
  }

  var origin: String
  var dest: String
  var emoji: String
}

private func clockText(_ seconds: Int) -> String {
  let m = seconds / 60
  let s = seconds % 60
  if m >= 60 {
    return String(format: "%d:%02d:%02d", m / 60, m % 60, s)
  }
  return String(format: "%02d:%02d", m, s)
}

private func interval(_ s: FocusJourneyAttributes.ContentState) -> ClosedRange<Date> {
  let start = Date(timeIntervalSince1970: s.startEpoch / 1000)
  var end = Date(timeIntervalSince1970: s.endEpoch / 1000)
  if end <= start { end = start.addingTimeInterval(1) }
  return start...end
}

/// 남은시간: 진행 중이면 timerInterval 로 매초 자동 카운트다운, 일시정지면 정적.
@ViewBuilder
private func remainingView(_ s: FocusJourneyAttributes.ContentState, font: Font) -> some View {
  if s.paused {
    Text(clockText(s.remaining)).font(font).monospacedDigit()
  } else {
    Text(timerInterval: interval(s), countsDown: true)
      .font(font)
      .monospacedDigit()
      .multilineTextAlignment(.trailing)
  }
}

/// 진행바: 진행 중이면 timerInterval 로 자동 진행, 일시정지면 정적.
@ViewBuilder
private func progressView(_ s: FocusJourneyAttributes.ContentState) -> some View {
  if s.paused {
    ProgressView(value: s.progress).tint(.orange)
  } else {
    ProgressView(timerInterval: interval(s), countsDown: false) {
      EmptyView()
    } currentValueLabel: {
      EmptyView()
    }
    .tint(.orange)
  }
}

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
          remainingView(context.state, font: .headline)
        }
        progressView(context.state)
        Text(context.state.paused ? "일시정지" : "집중 여정 진행 중")
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
          remainingView(context.state, font: .title3)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            Text("\(context.attributes.origin) → \(context.attributes.dest)")
              .font(.caption)
            progressView(context.state)
          }
        }
      } compactLeading: {
        Text(context.attributes.emoji)
      } compactTrailing: {
        remainingView(context.state, font: .caption2).frame(maxWidth: 64)
      } minimal: {
        Text(context.attributes.emoji)
      }
    }
  }
}
