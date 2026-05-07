import SwiftUI
import IntervalTimerCore

struct HiitSetupView: View {
    @State private var config = HiitConfig()
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Exercise Name", text: $config.exerciseName)
                }

                Section("Timing") {
                    Stepper("Work: \(config.workDuration)s", value: $config.workDuration, in: 5...300, step: 5)
                    Stepper("Rest: \(config.restDuration)s", value: $config.restDuration, in: 5...300, step: 5)
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
                    .listRowBackground(Color.orange)
                }
            }
            .navigationTitle("HiiT")
            .navigationDestination(isPresented: $showTimer) {
                IntervalTimerView(
                    session: .hiit(config: config),
                    title: config.exerciseName.isEmpty ? "HiiT" : config.exerciseName,
                    accentColor: .orange
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
    HiitSetupView()
}
