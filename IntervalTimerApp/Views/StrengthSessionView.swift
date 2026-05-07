import SwiftUI
import IntervalTimerCore

/// Full-screen session view for Strength training.
/// The user manually records each set completion; the app automatically
/// counts down the rest period before the next set.
struct StrengthSessionView: View {
    @StateObject private var viewModel: StrengthTimerViewModel
    @Environment(\.dismiss) private var dismiss

    init(config: StrengthConfig) {
        _viewModel = StateObject(wrappedValue: StrengthTimerViewModel(config: config))
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            setDotsView

            if viewModel.phase == .completed {
                EmptyView() // completion overlay takes over
            } else if viewModel.isResting {
                restView
            } else {
                workView
            }

            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.exerciseName.isEmpty ? "Strength" : viewModel.exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.phase == .completed {
                completionOverlay
            }
        }
    }

    // MARK: - Subviews

    /// Row of dots showing set progress.
    private var setDotsView: some View {
        VStack(spacing: 10) {
            Text("Set \(viewModel.currentSet) of \(viewModel.totalSets)")
                .font(.title2.bold())

            HStack(spacing: 8) {
                ForEach(1...viewModel.totalSets, id: \.self) { set in
                    Circle()
                        .fill(dotColor(for: set))
                        .frame(width: 14, height: 14)
                        .animation(.easeInOut, value: viewModel.currentSet)
                }
            }
        }
    }

    /// Shown while the user should be performing a set.
    private var workView: some View {
        VStack(spacing: 28) {
            VStack(spacing: 4) {
                Text("\(viewModel.reps)")
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                Text("REPS")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
            }

            Button {
                viewModel.completeSet()
            } label: {
                Label("Complete Set", systemImage: "checkmark.circle.fill")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            Button {
                viewModel.reset()
                dismiss()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Shown during the rest period between sets.
    private var restView: some View {
        VStack(spacing: 20) {
            Text("Rest")
                .font(.title2.bold())
                .foregroundStyle(.secondary)

            TimerRingView(
                progress: viewModel.restProgress,
                timeRemaining: viewModel.timeRemaining,
                color: .blue
            )
            .frame(width: 200, height: 200)

            Text("Next: Set \(viewModel.currentSet + 1) of \(viewModel.totalSets)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                Text("Workout Complete!")
                    .font(.largeTitle.bold())
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func dotColor(for set: Int) -> Color {
        if set < viewModel.currentSet {
            return .blue
        } else if set == viewModel.currentSet {
            return .blue.opacity(0.4)
        } else {
            return Color(.systemGray4)
        }
    }
}
