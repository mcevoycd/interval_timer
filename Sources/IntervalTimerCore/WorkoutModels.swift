import Foundation

// MARK: - Workout Type

public enum WorkoutType: String, CaseIterable, Identifiable {
    case hiit = "HiiT"
    case strength = "Strength"
    case cardio = "Cardio"

    public var id: String { rawValue }
}

// MARK: - HiiT Configuration

/// Configuration for a High-Intensity Interval Training session.
/// The user specifies an exercise name, work/rest durations, the number of
/// intervals per round, and the total number of rounds.
public struct HiitConfig: Equatable {
    public var exerciseName: String
    public var workDuration: Int   // seconds
    public var restDuration: Int   // seconds
    public var intervals: Int
    public var rounds: Int

    public init(
        exerciseName: String = "",
        workDuration: Int = 30,
        restDuration: Int = 10,
        intervals: Int = 8,
        rounds: Int = 3
    ) {
        self.exerciseName = exerciseName
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.intervals = intervals
        self.rounds = rounds
    }

    /// Total number of work/rest cycles across all rounds.
    public var totalIntervals: Int { rounds * intervals }

    /// Estimated total session duration in seconds.
    public var totalDuration: Int {
        rounds * intervals * (workDuration + restDuration)
    }
}

// MARK: - Strength Configuration

/// Configuration for a Strength training session.
/// The user specifies an exercise name, target reps per set, number of sets,
/// and the rest period between sets.
public struct StrengthConfig: Equatable {
    public var exerciseName: String
    public var reps: Int
    public var restPeriod: Int   // seconds
    public var sets: Int

    public init(
        exerciseName: String = "",
        reps: Int = 10,
        restPeriod: Int = 60,
        sets: Int = 3
    ) {
        self.exerciseName = exerciseName
        self.reps = reps
        self.restPeriod = restPeriod
        self.sets = sets
    }
}

// MARK: - Cardio Configuration

/// Configuration for a Cardio session, structured identically to HiiT but
/// typically with longer work/rest periods.
public struct CardioConfig: Equatable {
    public var exerciseName: String
    public var workDuration: Int   // seconds
    public var restDuration: Int   // seconds
    public var intervals: Int
    public var rounds: Int

    public init(
        exerciseName: String = "",
        workDuration: Int = 60,
        restDuration: Int = 30,
        intervals: Int = 5,
        rounds: Int = 2
    ) {
        self.exerciseName = exerciseName
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.intervals = intervals
        self.rounds = rounds
    }

    /// Total number of work/rest cycles across all rounds.
    public var totalIntervals: Int { rounds * intervals }

    /// Estimated total session duration in seconds.
    public var totalDuration: Int {
        rounds * intervals * (workDuration + restDuration)
    }
}
