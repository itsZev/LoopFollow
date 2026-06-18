// LoopFollow
// CompletionStepView.swift

import SwiftUI

struct CompletionStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 96, weight: .semibold))
                    .foregroundStyle(.green.gradient)
                    .scaleEffect(animate || reduceMotion ? 1 : 0.6)
                    .opacity(animate || reduceMotion ? 1 : 0)

                Text("You're all set")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("You're ready to go. You can adjust everything later from the Menu.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button { viewModel.finish() } label: {
                Text("Finish")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                animate = true
            }
        }
    }
}
