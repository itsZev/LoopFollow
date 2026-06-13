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
                    subtitle: "Sign in with the Dexcom Share account you use to follow glucose."
                )
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section(header: Text("Dexcom Share")) {
                HStack {
                    Text("User Name")
                    TextField("Enter User Name", text: $viewModel.userName)
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
                    Text("NON-US").tag("NON-US")
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
