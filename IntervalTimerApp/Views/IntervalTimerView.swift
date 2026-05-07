import SwiftUI
import IntervalTimerCore

/// Full-screen timer view shared by HiiT and Cardio workouts.
struct IntervalTimerView: View {
    @StateObject private var viewModel: IntervalTimerViewModel
    @Environment(\.dismiss) private var dismiss

    let title: String
    let accentColor: Color

    init(session: IntervalTimerSession, title: String, accentColor: Color) {
        self.title = title
        self.accentColor = accentColor
        _viewModel = StateObject(wrappedValue: IntervalTimerViewModel(session: session))
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            phaseBadge

            TimerRingView(
                progress: viewModel.progress,
                timeRemaining: viewModel.timeRemaining,
                color: phaseColor
            )
            .frame(width: 240, height: 240)

            progressLabel

            Spacer()

            controlButtons
                .padding(.bottom, 32)
        }
        .padding(.horizontal)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isRunning)
        .overlay {
            if viewModel.phase == .completed {
                completionOverlay
            }
        }
    }

    // MARK: - Subviews

    private var phaseBadge: some View {
        Text(phaseText)
            .font(.title.bold())
            .foregroundStyle(phaseColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .background(phaseColor.opacity(0.12), in: Capsule())
            .animation(.easeInOut(duration: 0.25), value: viewModel.phase)
    }

    private var progressLabel: some View {
        VStack(spacing: 6) {
            if viewModel.totalRounds > 1 {
                Text("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
                    .font(.headline)
            }
            Text("Interval \(viewModel.currentInterval) of \(viewModel.totalIntervals)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 36) {
            Button {
                viewModel.reset()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }

            Button {
                switch viewModel.phase {
                case .idle:      viewModel.start()
                case .completed: break
                default:
                    viewModel.isRunning ? viewModel.pause() : viewModel.resume()
                }
            } label: {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 72))
                    .foregroundStyle(accentColor)
                    .symbolRenderingMode(.hierarchical)
            }

            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
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
                .tint(accentColor)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private var phaseText: String {
        switch viewModel.phase {
        case .idle:      return "Ready"
        case .work:      return "WORK"
        case .rest:      return "REST"
        case .completed: return "Done!"
        }
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .work: return accentColor
        case .rest: return .blue
        default:    return .secondary
        }
    }

    private var playPauseIcon: String {
        (viewModel.phase == .idle || !viewModel.isRunning) ? "play.circle.fill" : "pause.circle.fill"
    }
}
