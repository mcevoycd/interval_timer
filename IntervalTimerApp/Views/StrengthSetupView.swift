import SwiftUI
import IntervalTimerCore

struct StrengthSetupView: View {
    @State private var config = StrengthConfig()
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Exercise Name", text: $config.exerciseName)
                }

                Section("Workout") {
                    Stepper("Reps: \(config.reps)", value: $config.reps, in: 1...50)
                    Stepper("Sets: \(config.sets)", value: $config.sets, in: 1...10)
                    Stepper("Rest: \(config.restPeriod)s", value: $config.restPeriod, in: 10...300, step: 10)
                }

                Section {
                    Button("Start Workout") {
                        showTimer = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Strength")
            .navigationDestination(isPresented: $showTimer) {
                StrengthSessionView(config: config)
            }
        }
    }
}

#Preview {
    StrengthSetupView()
}
