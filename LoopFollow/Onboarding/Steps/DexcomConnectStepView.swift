// LoopFollow
// DexcomConnectStepView.swift

import SwiftUI

struct DexcomConnectStepView: View {
    @ObservedObject var viewModel: DexcomSettingsViewModel

    var body: some View {
        Form {
            Section {
                EmptyView()
            } header: {
                OnboardingStepHeader(
                    systemImage: "drop.fill",
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
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Password")
                    TogglableSecureInput(
                        placeholder: "Enter Password",
                        text: $viewModel.password,
                        style: .singleLine
                    )
                }

                Picker("Server", selection: $viewModel.server) {
                    Text("US").tag("US")
                    Text("Outside US").tag("NON-US")
                }
                .pickerStyle(.segmented)
            }

            Section {
                HStack {
                    Image(systemName: viewModel.hasCredentials ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(viewModel.hasCredentials ? .green : .secondary)
                    Text(viewModel.hasCredentials ? "Credentials entered" : "Enter your username and password")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
