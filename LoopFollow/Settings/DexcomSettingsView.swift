// LoopFollow
// DexcomSettingsView.swift

import SwiftUI

struct DexcomSettingsView: View {
    @ObservedObject var viewModel: DexcomSettingsViewModel
    var usesModalCloseButton: Bool = false
    var onContinueToUnits: (() -> Void)? = nil
    @State private var showUnitsSetup = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Dexcom 设置")) {
                HStack {
                    Text("用户名")
                    TextField("Enter 用户名", text: $viewModel.userName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("密码")
                    TogglableSecureInput(
                        placeholder: "Enter 密码",
                        text: $viewModel.password,
                        style: .singleLine
                    )
                }

                Picker("服务器", selection: $viewModel.server) {
                    Text("美国").tag("美国")
                    Text("NON-美国").tag("NON-美国")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if viewModel.isFreshSetup {
                Section {
                    Button(action: {
                        if let onContinueToUnits {
                            onContinueToUnits()
                        } else {
                            showUnitsSetup = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("继续")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.hasCredentials)
                    .listRowBackground(Color.clear)
                }
            }

            importSection
        }
        .navigationDestination(isPresented: $showUnitsSetup) {
            UnitsOnboardingView {
                dismiss()
            }
        }
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
        .navigationBarTitle("Dexcom 设置", displayMode: .inline)
        .navigationBarBackButtonHidden(usesModalCloseButton)
    }

    private var importSection: some View {
        Section(header: Text("导入设置")) {
            NavigationLink(destination: ImportExportSettingsView()) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.blue)
                    Text("导入设置 from QR Code")
                }
            }
        }
    }
}
