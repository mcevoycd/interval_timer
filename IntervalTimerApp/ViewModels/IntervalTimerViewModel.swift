import Combine
import Foundation
import IntervalTimerCore

/// ObservableObject wrapper around `IntervalTimerSession`.
/// Drives the 1-second Combine timer and exposes derived state for the view.
@MainActor
final class IntervalTimerViewModel: ObservableObject {
    @Published private(set) var session: IntervalTimerSession

    private var timerCancellable: AnyCancellable?

    init(session: IntervalTimerSession) {
        self.session = session
    }

    var isRunning: Bool { session.state.isRunning }
    var phase: TimerPhase { session.state.phase }
    var timeRemaining: Int { session.state.timeRemaining }
    var currentInterval: Int { session.state.currentInterval }
    var totalIntervals: Int { session.state.totalIntervals }
    var currentRound: Int { session.state.currentRound }
    var totalRounds: Int { session.state.totalRounds }

    /// Duration of the current phase in seconds (used for ring progress).
    var phaseDuration: Int {
        switch session.state.phase {
        case .work: return session.workDuration
        case .rest: return session.restDuration
        default:    return 1
        }
    }

    /// Fraction [0, 1] of the current phase that has elapsed.
    var progress: Double {
        guard phaseDuration > 0 else { return 0 }
        let elapsed = phaseDuration - session.state.timeRemaining
        return Double(elapsed) / Double(phaseDuration)
    }

    func start() {
        session.start()
        scheduleTimer()
    }

    func pause() {
        session.pause()
        cancelTimer()
    }

    func resume() {
        session.resume()
        scheduleTimer()
    }

    func reset() {
        cancelTimer()
        session.reset()
    }

    private func scheduleTimer() {
        cancelTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.session.tick()
                if self.session.state.phase == .completed {
                    self.cancelTimer()
                }
            }
    }

    private func cancelTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
