// LoopFollow
// UnitsStepView.swift

import SwiftUI

struct UnitsStepView: View {
    var body: some View {
        Form {
            Section {
                EmptyView()
            } header: {
                OnboardingStepHeader(
                    systemImage: "ruler",
                    title: "Units & metrics",
                    subtitle: "Choose how glucose values and statistics are displayed. You can change any of this later in Settings."
                )
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            UnitsConfigurationView()
        }
    }
}
