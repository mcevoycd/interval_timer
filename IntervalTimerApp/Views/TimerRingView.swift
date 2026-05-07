import SwiftUI

/// A circular countdown ring showing elapsed progress and the time remaining.
struct TimerRingView: View {
    let progress: Double
    let timeRemaining: Int
    let color: Color
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text(timeString)
                .font(.system(size: 52, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        }
    }

    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        if m > 0 {
            return String(format: "%d:%02d", m, s)
        } else {
            return "\(s)"
        }
    }
}

#Preview {
    TimerRingView(progress: 0.4, timeRemaining: 24, color: .orange)
        .frame(width: 240, height: 240)
        .padding()
}
