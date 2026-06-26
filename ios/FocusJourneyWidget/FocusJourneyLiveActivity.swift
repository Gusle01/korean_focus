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
      // 잠금화면 / 배너 — 큼직하게.
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
          Text(context.attributes.emoji)
            .font(.title3)
          Text("\(context.attributes.origin) → \(context.attributes.dest)")
            .font(.title3)
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
          Spacer()
          Text(context.state.paused ? "일시정지" : "집중 중")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        HStack(alignment: .firstTextBaseline) {
          Text("남은 시간")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Spacer()
          remainingView(
            context.state,
            font: .system(size: 40, weight: .semibold, design: .rounded))
        }
        progressView(context.state)
          .scaleEffect(x: 1, y: 1.8, anchor: .center)
          .padding(.vertical, 4)
      }
      .padding(20)
      .activityBackgroundTint(Color.black.opacity(0.55))
      .activitySystemActionForegroundColor(Color.white)

    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(context.attributes.emoji).font(.largeTitle)
        }
        DynamicIslandExpandedRegion(.center) {
          Text("\(context.attributes.origin) → \(context.attributes.dest)")
            .font(.subheadline)
            .fontWeight(.medium)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        DynamicIslandExpandedRegion(.trailing) {
          remainingView(
            context.state,
            font: .system(size: 28, weight: .semibold, design: .rounded))
            .frame(maxWidth: 130)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 6) {
            progressView(context.state)
              .scaleEffect(x: 1, y: 1.6, anchor: .center)
              .padding(.vertical, 3)
            Text(context.state.paused ? "일시정지" : "집중 여정 진행 중")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      } compactLeading: {
        Text(context.attributes.emoji)
      } compactTrailing: {
        remainingView(context.state, font: .caption2).frame(maxWidth: 70)
      } minimal: {
        Text(context.attributes.emoji)
      }
    }
  }
}
