// LoopFollow
// NightscoutSettingsView.swift

import SwiftUI

struct NightscoutSettingsView: View {
    @ObservedObject var viewModel: NightscoutSettingsViewModel
    var usesModalCloseButton: Bool = false
    var onContinueToUnits: (() -> Void)? = nil
    var onImportSettings: (() -> Void)? = nil
    @State private var showUnitsSetup = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            urlSection
            tokenSection
            statusSection

            if viewModel.isFreshSetup {
                continueSection
            }

            importSection
        }
        .navigationDestination(isPresented: $showUnitsSetup) {
            UnitsOnboardingView {
                dismiss()
            }
        }
        .navigationBarTitle("Nightscout 设置", displayMode: .inline)
        .navigationBarBackButtonHidden(usesModalCloseButton)
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
    }

    // MARK: - Subviews / Computed Properties

    private var urlSection: some View {
        Section(header: Text("网址")) {
            TextField("输入网址", text: $viewModel.nightscoutURL)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: viewModel.nightscoutURL) { newValue in
                    viewModel.processURL(newValue)
                }
        }
    }

    private var tokenSection: some View {
        Section(header: Text("令牌")) {
            HStack {
                Text("访问令牌")
                TogglableSecureInput(
                    placeholder: "输入令牌",
                    text: $viewModel.nightscoutToken,
                    style: .singleLine,
                    textContentType: .password
                )
            }
        }
    }

    private var statusSection: some View {
        Section(header: Text("状态")) {
            HStack {
                Text(viewModel.nightscoutStatus)
                if viewModel.isConnected {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }

    private var continueSection: some View {
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
            .disabled(!viewModel.isConnected)
            .listRowBackground(Color.clear)
        }
    }

    private var importSection: some View {
        Section(header: Text("导入设置")) {
            if let onImportSettings {
                Button(action: onImportSettings) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                        Text("从二维码导入设置")
                            .foregroundColor(.primary)
                    }
                }
            } else {
                NavigationLink(destination: ImportExportSettingsView()) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                        Text("从二维码导入设置")
                    }
                }
            }
        }
    }
}
