// LoopFollow
// DexcomConnectStepView.swift

import SwiftUI

struct DexcomConnectStepView: View {
    @ObservedObject var viewModel: DexcomSettingsViewModel
    @ObservedObject var onboarding: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            form
            OnboardingNavFooter(
                continueEnabled: viewModel.canVerifyProceed,
                showBack: onboarding.canGoBack,
                onBack: { onboarding.goBack() },
                onContinue: { onboarding.advance() }
            )
        }
    }

    private var form: some View {
        Form {
            Section {
                EmptyView()
            } header: {
                OnboardingStepHeader(
                    systemImage: "sensor.tag.radiowaves.forward.fill",
                    title: "Connect Dexcom Share",
                    subtitle: "Sign in with the Dexcom Share account that shares glucose data."
                )
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section(header: Text("Dexcom Share")) {
                HStack {
                    Text("Username")
                    TextField("Enter Username", text: $viewModel.userName)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Password")
                    TogglableSecureInput(
                        placeholder: "Enter Password",
                        text: $viewModel.password,
                        style: .singleLine,
                        textContentType: .password
                    )
                }

                Picker("Server", selection: $viewModel.server) {
                    Text("US").tag("US")
                    Text("Outside US").tag("NON-US")
                }
                .pickerStyle(.segmented)
            }

            Section {
                HStack(spacing: 10) {
                    statusIcon
                        .frame(width: 20)
                    Text(viewModel.statusMessage)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch viewModel.statusKind {
        case .idle:
            Image(systemName: "circle").foregroundColor(.secondary)
        case .checking:
            ProgressView()
        case .connected:
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
        }
    }
}
