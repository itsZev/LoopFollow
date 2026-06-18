// LoopFollow
// OnboardingStepHeader.swift

import SwiftUI

/// Consistent icon + title + subtitle header used at the top of each step body.
struct OnboardingStepHeader: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        // Left-aligned: justified/centered body copy is harder to read, so the
        // header reads as a natural top-down intro.
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 2)

            Text(title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.leading)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}
