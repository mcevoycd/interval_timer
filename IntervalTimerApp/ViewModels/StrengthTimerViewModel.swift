import Combine
import Foundation
import IntervalTimerCore

/// ObservableObject wrapper around `StrengthTimerSession`.
/// Drives the rest-period countdown and exposes derived state for the view.
@MainActor
final class StrengthTimerViewModel: ObservableObject {
    @Published private(set) var session: StrengthTimerSession

    private var timerCancellable: AnyCancellable?

    init(config: StrengthConfig) {
        self.session = StrengthTimerSession(config: config)
    }

    var currentSet: Int   { session.currentSet }
    var totalSets: Int    { session.config.sets }
    var reps: Int         { session.config.reps }
    var isResting: Bool   { session.isResting }
    var timeRemaining: Int { session.state.timeRemaining }
    var phase: TimerPhase { session.state.phase }
    var exerciseName: String { session.config.exerciseName }

    /// Fraction [0, 1] of the rest period that has elapsed.
    var restProgress: Double {
        let total = session.config.restPeriod
        guard total > 0 else { return 0 }
        let elapsed = total - session.state.timeRemaining
        return Double(elapsed) / Double(total)
    }

    func completeSet() {
        session.completeSet()
        if session.isResting {
            scheduleTimer()
        }
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
                if !self.session.isResting {
                    self.cancelTimer()
                }
            }
    }

    private func cancelTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
