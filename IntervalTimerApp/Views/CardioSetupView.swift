import SwiftUI
import IntervalTimerCore

struct CardioSetupView: View {
    @State private var config = CardioConfig()
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Exercise Name", text: $config.exerciseName)
                }

                Section("Timing") {
                    Stepper("Work: \(config.workDuration)s", value: $config.workDuration, in: 10...3600, step: 30)
                    Stepper("Rest: \(config.restDuration)s", value: $config.restDuration, in: 0...600, step: 15)
                }

                Section("Structure") {
                    Stepper("Intervals: \(config.intervals)", value: $config.intervals, in: 1...20)
                    Stepper("Rounds: \(config.rounds)", value: $config.rounds, in: 1...10)
                }

                Section {
                    summaryView
                }

                Section {
                    Button("Start Workout") {
                        showTimer = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Cardio")
            .navigationDestination(isPresented: $showTimer) {
                IntervalTimerView(
                    session: .cardio(config: config),
                    title: config.exerciseName.isEmpty ? "Cardio" : config.exerciseName,
                    accentColor: .green
                )
            }
        }
    }

    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(config.totalIntervals) intervals · \(config.rounds) round\(config.rounds == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("~\(formattedDuration(config.totalDuration))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

#Preview {
    CardioSetupView()
}
