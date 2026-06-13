// LoopFollow
// OnboardingContainerView.swift

import SwiftUI

/// Root of the first-run onboarding wizard. Owns the shared chrome — progress
/// bar and Back/Next footer — and swaps in the view for the current step.
struct OnboardingContainerView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(onClose: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(onClose: onClose))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.step.showsChrome {
                header
            }

            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.step.showsChrome {
                footer
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
    }

    // MARK: - Chrome

    private var header: some View {
        HStack(spacing: 12) {
            OnboardingProgressBar(progress: viewModel.progress)
            Button("Skip") { viewModel.skip() }
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var stepContent: some View {
        let content = Group {
            switch viewModel.step {
            case .welcome:
                WelcomeStepView(viewModel: viewModel)
            case .dataSource:
                DataSourceChoiceStepView(viewModel: viewModel)
            case .connect:
                switch viewModel.dataSource {
                case .dexcom:
                    DexcomConnectStepView(viewModel: viewModel.dexcomViewModel)
                default:
                    NightscoutConnectStepView(viewModel: viewModel.nightscoutViewModel)
                }
            case .units:
                UnitsStepView()
            case .alarms:
                AlarmsStepView(viewModel: viewModel)
            case .completion:
                CompletionStepView(viewModel: viewModel)
            }
        }

        if reduceMotion {
            content.id(viewModel.step)
        } else {
            content
                .id(viewModel.step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }

    private var footer: some View {
        HStack {
            if viewModel.step.previous != nil {
                Button {
                    withStepAnimation { viewModel.goBack() }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.body.weight(.medium))
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button {
                withStepAnimation { viewModel.advance() }
            } label: {
                Text("Continue")
                    .font(.body.weight(.semibold))
                    .frame(minWidth: 120)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canProceed)
        }
        .padding()
        .background(.bar)
    }

    private func withStepAnimation(_ change: () -> Void) {
        if reduceMotion {
            change()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) { change() }
        }
    }
}

/// Thin segmented progress indicator shown at the top of each chrome'd step.
private struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
            }
        }
        .frame(height: 6)
    }
}
