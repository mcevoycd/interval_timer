import XCTest
@testable import IntervalTimerCore

final class WorkoutTimerTests: XCTestCase {

    // MARK: - IntervalTimerSession — initial state

    func testIntervalTimerSessionInitialState() {
        let session = IntervalTimerSession(
            workDuration: 30, restDuration: 10, intervals: 3, rounds: 2
        )
        XCTAssertEqual(session.state.phase, .idle)
        XCTAssertEqual(session.state.currentInterval, 1)
        XCTAssertEqual(session.state.totalIntervals, 3)
        XCTAssertEqual(session.state.currentRound, 1)
        XCTAssertEqual(session.state.totalRounds, 2)
        XCTAssertEqual(session.state.timeRemaining, 30)
        XCTAssertFalse(session.state.isRunning)
    }

    // MARK: - Start

    func testIntervalTimerSessionStart() {
        var session = IntervalTimerSession(
            workDuration: 30, restDuration: 10, intervals: 3, rounds: 2
        )
        session.start()
        XCTAssertEqual(session.state.phase, .work)
        XCTAssertTrue(session.state.isRunning)
        XCTAssertEqual(session.state.timeRemaining, 30)
    }

    func testStartIsIdempotentFromNonIdleState() {
        var session = IntervalTimerSession(
            workDuration: 30, restDuration: 10, intervals: 3, rounds: 2
        )
        session.start()
        session.tick()
        let timeAfterOneTick = session.state.timeRemaining
        session.start() // should be a no-op
        XCTAssertEqual(session.state.timeRemaining, timeAfterOneTick)
    }

    // MARK: - Tick

    func testIntervalTimerSessionTickDecrementsTime() {
        var session = IntervalTimerSession(
            workDuration: 30, restDuration: 10, intervals: 3, rounds: 2
        )
        session.start()
        session.tick()
        XCTAssertEqual(session.state.timeRemaining, 29)
        XCTAssertEqual(session.state.phase, .work)
    }

    func testTickDoesNothingWhenNotRunning() {
        var session = IntervalTimerSession(
            workDuration: 10, restDuration: 5, intervals: 2, rounds: 1
        )
        session.tick() // still idle
        XCTAssertEqual(session.state.timeRemaining, 10)
        XCTAssertEqual(session.state.phase, .idle)
    }

    // MARK: - Work → Rest transition

    func testWorkToRestTransition() {
        var session = IntervalTimerSession(
            workDuration: 2, restDuration: 3, intervals: 2, rounds: 1
        )
        session.start()
        session.tick() // 2 → 1
        XCTAssertEqual(session.state.phase, .work)
        XCTAssertEqual(session.state.timeRemaining, 1)
        session.tick() // 1 → 0 → transitions to rest with restDuration
        XCTAssertEqual(session.state.phase, .rest)
        XCTAssertEqual(session.state.timeRemaining, 3)
    }

    // MARK: - Rest → next interval

    func testRestToNextIntervalTransition() {
        var session = IntervalTimerSession(
            workDuration: 1, restDuration: 1, intervals: 2, rounds: 1
        )
        session.start()
        session.tick() // work: 1 → 0 → rest (timeRemaining = 1)
        XCTAssertEqual(session.state.phase, .rest)
        session.tick() // rest: 1 → 0 → interval 2, work (timeRemaining = 1)
        XCTAssertEqual(session.state.phase, .work)
        XCTAssertEqual(session.state.currentInterval, 2)
        XCTAssertEqual(session.state.timeRemaining, 1)
    }

    // MARK: - Multiple rounds

    func testMultipleRoundsTransition() {
        var session = IntervalTimerSession(
            workDuration: 1, restDuration: 1, intervals: 1, rounds: 2
        )
        session.start()
        // Round 1
        session.tick() // work: 1 → 0 → rest (1)
        session.tick() // rest: 1 → 0 → round 2, interval 1, work (1)
        XCTAssertEqual(session.state.currentRound, 2)
        XCTAssertEqual(session.state.currentInterval, 1)
        XCTAssertEqual(session.state.phase, .work)
        // Round 2
        session.tick() // work: 1 → 0 → rest (1)
        session.tick() // rest: 1 → 0 → completed
        XCTAssertEqual(session.state.phase, .completed)
        XCTAssertFalse(session.state.isRunning)
    }

    // MARK: - Completion

    func testSessionCompletion() {
        var session = IntervalTimerSession(
            workDuration: 1, restDuration: 1, intervals: 1, rounds: 1
        )
        session.start()
        session.tick() // work → rest
        session.tick() // rest → completed
        XCTAssertEqual(session.state.phase, .completed)
        XCTAssertFalse(session.state.isRunning)
    }

    func testTickAfterCompletionIsNoOp() {
        var session = IntervalTimerSession(
            workDuration: 1, restDuration: 1, intervals: 1, rounds: 1
        )
        session.start()
        session.tick()
        session.tick() // → completed
        session.tick() // should not change anything
        XCTAssertEqual(session.state.phase, .completed)
    }

    // MARK: - No-rest intervals

    func testZeroRestDurationSkipsRestPhase() {
        var session = IntervalTimerSession(
            workDuration: 1, restDuration: 0, intervals: 2, rounds: 1
        )
        session.start()
        session.tick() // work: 1 → 0 → directly to interval 2
        XCTAssertEqual(session.state.phase, .work)
        XCTAssertEqual(session.state.currentInterval, 2)
    }

    // MARK: - Pause / Resume

    func testPauseStopsTickProgression() {
        var session = IntervalTimerSession(
            workDuration: 10, restDuration: 5, intervals: 3, rounds: 2
        )
        session.start()
        session.tick()
        session.pause()
        XCTAssertFalse(session.state.isRunning)
        let frozen = session.state.timeRemaining
        session.tick() // should be no-op
        XCTAssertEqual(session.state.timeRemaining, frozen)
    }

    func testResumeAfterPause() {
        var session = IntervalTimerSession(
            workDuration: 10, restDuration: 5, intervals: 3, rounds: 2
        )
        session.start()
        session.tick()
        session.pause()
        session.resume()
        XCTAssertTrue(session.state.isRunning)
        let before = session.state.timeRemaining
        session.tick()
        XCTAssertEqual(session.state.timeRemaining, before - 1)
    }

    func testResumeFromIdleIsNoOp() {
        var session = IntervalTimerSession(
            workDuration: 10, restDuration: 5, intervals: 3, rounds: 2
        )
        session.resume()
        XCTAssertFalse(session.state.isRunning)
        XCTAssertEqual(session.state.phase, .idle)
    }

    // MARK: - Reset

    func testResetRestoresInitialState() {
        var session = IntervalTimerSession(
            workDuration: 30, restDuration: 10, intervals: 3, rounds: 2
        )
        session.start()
        session.tick()
        session.tick()
        session.reset()
        XCTAssertEqual(session.state.phase, .idle)
        XCTAssertEqual(session.state.currentInterval, 1)
        XCTAssertEqual(session.state.currentRound, 1)
        XCTAssertEqual(session.state.timeRemaining, 30)
        XCTAssertFalse(session.state.isRunning)
    }

    // MARK: - Factory methods

    func testHiitFactory() {
        let config = HiitConfig(workDuration: 40, restDuration: 20, intervals: 10, rounds: 4)
        let session = IntervalTimerSession.hiit(config: config)
        XCTAssertEqual(session.workDuration, 40)
        XCTAssertEqual(session.restDuration, 20)
        XCTAssertEqual(session.intervals, 10)
        XCTAssertEqual(session.rounds, 4)
    }

    func testCardioFactory() {
        let config = CardioConfig(workDuration: 60, restDuration: 30, intervals: 5, rounds: 3)
        let session = IntervalTimerSession.cardio(config: config)
        XCTAssertEqual(session.workDuration, 60)
        XCTAssertEqual(session.restDuration, 30)
        XCTAssertEqual(session.intervals, 5)
        XCTAssertEqual(session.rounds, 3)
    }

    // MARK: - StrengthTimerSession — initial state

    func testStrengthTimerInitialState() {
        let config = StrengthConfig(reps: 10, restPeriod: 60, sets: 3)
        let session = StrengthTimerSession(config: config)
        XCTAssertEqual(session.state.phase, .idle)
        XCTAssertEqual(session.currentSet, 1)
        XCTAssertFalse(session.isResting)
        XCTAssertFalse(session.state.isRunning)
        XCTAssertEqual(session.state.totalIntervals, 3)
    }

    // MARK: - Completing a set

    func testCompleteSetStartsRestCountdown() {
        let config = StrengthConfig(reps: 10, restPeriod: 60, sets: 3)
        var session = StrengthTimerSession(config: config)
        session.completeSet()
        XCTAssertEqual(session.state.phase, .rest)
        XCTAssertTrue(session.isResting)
        XCTAssertEqual(session.state.timeRemaining, 60)
        XCTAssertTrue(session.state.isRunning)
    }

    func testCompleteSetIgnoredDuringRest() {
        let config = StrengthConfig(reps: 10, restPeriod: 60, sets: 3)
        var session = StrengthTimerSession(config: config)
        session.completeSet()
        let timeBefore = session.state.timeRemaining
        session.completeSet() // should be ignored while resting
        XCTAssertEqual(session.state.timeRemaining, timeBefore)
    }

    // MARK: - Rest countdown

    func testStrengthRestCountdown() {
        let config = StrengthConfig(reps: 10, restPeriod: 3, sets: 3)
        var session = StrengthTimerSession(config: config)
        session.completeSet()
        session.tick() // 3 → 2
        XCTAssertEqual(session.state.timeRemaining, 2)
        session.tick() // 2 → 1
        XCTAssertEqual(session.state.timeRemaining, 1)
        session.tick() // 1 → 0 → advance to next set
        XCTAssertEqual(session.currentSet, 2)
        XCTAssertFalse(session.isResting)
        XCTAssertEqual(session.state.phase, .work)
        XCTAssertFalse(session.state.isRunning)
    }

    func testTickDoesNothingWhenNotResting() {
        let config = StrengthConfig(reps: 10, restPeriod: 60, sets: 3)
        var session = StrengthTimerSession(config: config)
        session.tick() // still idle, not resting
        XCTAssertEqual(session.currentSet, 1)
        XCTAssertFalse(session.isResting)
    }

    // MARK: - Session completion via last set

    func testLastSetCompletesSession() {
        let config = StrengthConfig(reps: 5, restPeriod: 1, sets: 2)
        var session = StrengthTimerSession(config: config)
        // Set 1 → rest → set 2
        session.completeSet()
        session.tick() // 1 → 0 → advance to set 2
        XCTAssertEqual(session.currentSet, 2)
        // Complete final set
        session.completeSet()
        XCTAssertEqual(session.state.phase, .completed)
        XCTAssertFalse(session.state.isRunning)
    }

    // MARK: - Reset

    func testStrengthTimerReset() {
        let config = StrengthConfig(reps: 10, restPeriod: 60, sets: 3)
        var session = StrengthTimerSession(config: config)
        session.completeSet()
        session.tick()
        session.reset()
        XCTAssertEqual(session.state.phase, .idle)
        XCTAssertEqual(session.currentSet, 1)
        XCTAssertFalse(session.isResting)
        XCTAssertFalse(session.state.isRunning)
    }
}
