import Foundation

// MARK: - Timer Phase

public enum TimerPhase: Equatable {
    case idle
    case work
    case rest
    case completed
}

// MARK: - Timer State

public struct TimerState: Equatable {
    public var phase: TimerPhase
    public var currentInterval: Int
    public var totalIntervals: Int
    public var currentRound: Int
    public var totalRounds: Int
    public var timeRemaining: Int
    public var isRunning: Bool

    public init(
        phase: TimerPhase = .idle,
        currentInterval: Int = 0,
        totalIntervals: Int = 0,
        currentRound: Int = 0,
        totalRounds: Int = 0,
        timeRemaining: Int = 0,
        isRunning: Bool = false
    ) {
        self.phase = phase
        self.currentInterval = currentInterval
        self.totalIntervals = totalIntervals
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.timeRemaining = timeRemaining
        self.isRunning = isRunning
    }
}

// MARK: - Interval Timer Session (shared by HiiT & Cardio)

/// A value-type state machine that drives a HiiT or Cardio interval workout.
/// Call `tick()` once per second (from a Timer) while `state.isRunning` is true.
public struct IntervalTimerSession: Equatable {
    public let workDuration: Int
    public let restDuration: Int
    public let intervals: Int
    public let rounds: Int
    public var state: TimerState

    public init(workDuration: Int, restDuration: Int, intervals: Int, rounds: Int) {
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.intervals = intervals
        self.rounds = rounds
        self.state = TimerState(
            phase: .idle,
            currentInterval: 1,
            totalIntervals: intervals,
            currentRound: 1,
            totalRounds: rounds,
            timeRemaining: workDuration,
            isRunning: false
        )
    }

    /// Transition from idle to the first work phase.
    public mutating func start() {
        guard state.phase == .idle else { return }
        state.phase = .work
        state.timeRemaining = workDuration
        state.isRunning = true
    }

    public mutating func pause() {
        state.isRunning = false
    }

    public mutating func resume() {
        guard state.phase != .idle, state.phase != .completed else { return }
        state.isRunning = true
    }

    public mutating func reset() {
        state = TimerState(
            phase: .idle,
            currentInterval: 1,
            totalIntervals: intervals,
            currentRound: 1,
            totalRounds: rounds,
            timeRemaining: workDuration,
            isRunning: false
        )
    }

    /// Advance the session by one second. Call once per second from a timer.
    public mutating func tick() {
        guard state.isRunning else { return }
        guard state.phase == .work || state.phase == .rest else { return }

        state.timeRemaining -= 1

        guard state.timeRemaining <= 0 else { return }

        switch state.phase {
        case .work:
            if restDuration > 0 {
                state.phase = .rest
                state.timeRemaining = restDuration
            } else {
                advanceInterval()
            }
        case .rest:
            advanceInterval()
        default:
            break
        }
    }

    private mutating func advanceInterval() {
        if state.currentInterval < intervals {
            state.currentInterval += 1
            state.phase = .work
            state.timeRemaining = workDuration
        } else if state.currentRound < rounds {
            state.currentRound += 1
            state.currentInterval = 1
            state.phase = .work
            state.timeRemaining = workDuration
        } else {
            state.phase = .completed
            state.isRunning = false
        }
    }
}

// MARK: - Factory helpers

public extension IntervalTimerSession {
    /// Create a session configured for a HiiT workout.
    static func hiit(config: HiitConfig) -> IntervalTimerSession {
        IntervalTimerSession(
            workDuration: config.workDuration,
            restDuration: config.restDuration,
            intervals: config.intervals,
            rounds: config.rounds
        )
    }

    /// Create a session configured for a Cardio workout.
    static func cardio(config: CardioConfig) -> IntervalTimerSession {
        IntervalTimerSession(
            workDuration: config.workDuration,
            restDuration: config.restDuration,
            intervals: config.intervals,
            rounds: config.rounds
        )
    }
}

// MARK: - Strength Timer Session

/// A value-type state machine for a Strength training session.
/// The user taps "Complete Set" to record each set; the session then
/// automatically counts down the configured rest period before allowing
/// the next set.
public struct StrengthTimerSession: Equatable {
    public let config: StrengthConfig
    public var state: TimerState
    public var currentSet: Int
    public var isResting: Bool

    public init(config: StrengthConfig) {
        self.config = config
        self.currentSet = 1
        self.isResting = false
        self.state = TimerState(
            phase: .idle,
            currentInterval: 1,
            totalIntervals: config.sets,
            currentRound: 1,
            totalRounds: 1,
            timeRemaining: 0,
            isRunning: false
        )
    }

    /// Record the completion of the current set and start the rest countdown
    /// (or finish the session if it was the final set).
    public mutating func completeSet() {
        guard !isResting else { return }
        if currentSet < config.sets {
            isResting = true
            state.phase = .rest
            state.timeRemaining = config.restPeriod
            state.isRunning = true
        } else {
            state.phase = .completed
            state.isRunning = false
        }
    }

    /// Advance the rest countdown by one second. Call once per second from a timer.
    public mutating func tick() {
        guard state.isRunning, isResting else { return }

        state.timeRemaining -= 1

        if state.timeRemaining <= 0 {
            currentSet += 1
            state.currentInterval = currentSet
            isResting = false
            state.phase = .work
            state.isRunning = false
        }
    }

    public mutating func reset() {
        currentSet = 1
        isResting = false
        state = TimerState(
            phase: .idle,
            currentInterval: 1,
            totalIntervals: config.sets,
            currentRound: 1,
            totalRounds: 1,
            timeRemaining: 0,
            isRunning: false
        )
    }
}
