import XCTest
@testable import IntervalTimerCore

final class WorkoutModelsTests: XCTestCase {

    // MARK: - HiitConfig

    func testHiitConfigDefaults() {
        let config = HiitConfig()
        XCTAssertEqual(config.exerciseName, "")
        XCTAssertEqual(config.workDuration, 30)
        XCTAssertEqual(config.restDuration, 10)
        XCTAssertEqual(config.intervals, 8)
        XCTAssertEqual(config.rounds, 3)
    }

    func testHiitConfigCustomValues() {
        let config = HiitConfig(
            exerciseName: "Burpees",
            workDuration: 40,
            restDuration: 20,
            intervals: 10,
            rounds: 5
        )
        XCTAssertEqual(config.exerciseName, "Burpees")
        XCTAssertEqual(config.workDuration, 40)
        XCTAssertEqual(config.restDuration, 20)
        XCTAssertEqual(config.intervals, 10)
        XCTAssertEqual(config.rounds, 5)
    }

    func testHiitConfigTotalDuration() {
        // 3 rounds × 8 intervals × (30 + 10)s = 960s
        let config = HiitConfig(workDuration: 30, restDuration: 10, intervals: 8, rounds: 3)
        XCTAssertEqual(config.totalDuration, 960)
    }

    func testHiitConfigTotalIntervals() {
        let config = HiitConfig(intervals: 8, rounds: 3)
        XCTAssertEqual(config.totalIntervals, 24)
    }

    func testHiitConfigEquality() {
        let a = HiitConfig(exerciseName: "Sprints", workDuration: 20, restDuration: 10, intervals: 6, rounds: 4)
        let b = HiitConfig(exerciseName: "Sprints", workDuration: 20, restDuration: 10, intervals: 6, rounds: 4)
        XCTAssertEqual(a, b)
    }

    // MARK: - StrengthConfig

    func testStrengthConfigDefaults() {
        let config = StrengthConfig()
        XCTAssertEqual(config.exerciseName, "")
        XCTAssertEqual(config.reps, 10)
        XCTAssertEqual(config.restPeriod, 60)
        XCTAssertEqual(config.sets, 3)
    }

    func testStrengthConfigCustomValues() {
        let config = StrengthConfig(
            exerciseName: "Squat",
            reps: 12,
            restPeriod: 90,
            sets: 4
        )
        XCTAssertEqual(config.exerciseName, "Squat")
        XCTAssertEqual(config.reps, 12)
        XCTAssertEqual(config.restPeriod, 90)
        XCTAssertEqual(config.sets, 4)
    }

    func testStrengthConfigEquality() {
        let a = StrengthConfig(exerciseName: "Deadlift", reps: 5, restPeriod: 120, sets: 5)
        let b = StrengthConfig(exerciseName: "Deadlift", reps: 5, restPeriod: 120, sets: 5)
        XCTAssertEqual(a, b)
    }

    // MARK: - CardioConfig

    func testCardioConfigDefaults() {
        let config = CardioConfig()
        XCTAssertEqual(config.exerciseName, "")
        XCTAssertEqual(config.workDuration, 60)
        XCTAssertEqual(config.restDuration, 30)
        XCTAssertEqual(config.intervals, 5)
        XCTAssertEqual(config.rounds, 2)
    }

    func testCardioConfigTotalDuration() {
        // 2 rounds × 5 intervals × (60 + 30)s = 900s
        let config = CardioConfig(workDuration: 60, restDuration: 30, intervals: 5, rounds: 2)
        XCTAssertEqual(config.totalDuration, 900)
    }

    func testCardioConfigTotalIntervals() {
        let config = CardioConfig(intervals: 5, rounds: 2)
        XCTAssertEqual(config.totalIntervals, 10)
    }

    // MARK: - WorkoutType

    func testWorkoutTypeAllCases() {
        XCTAssertEqual(WorkoutType.allCases.count, 3)
        XCTAssertTrue(WorkoutType.allCases.contains(.hiit))
        XCTAssertTrue(WorkoutType.allCases.contains(.strength))
        XCTAssertTrue(WorkoutType.allCases.contains(.cardio))
    }

    func testWorkoutTypeRawValues() {
        XCTAssertEqual(WorkoutType.hiit.rawValue, "HiiT")
        XCTAssertEqual(WorkoutType.strength.rawValue, "Strength")
        XCTAssertEqual(WorkoutType.cardio.rawValue, "Cardio")
    }

    func testWorkoutTypeIdentifiable() {
        XCTAssertEqual(WorkoutType.hiit.id, "HiiT")
        XCTAssertEqual(WorkoutType.strength.id, "Strength")
        XCTAssertEqual(WorkoutType.cardio.id, "Cardio")
    }
}
