// LoopFollow
// NightscoutConnectStepView.swift

import SwiftUI

struct NightscoutConnectStepView: View {
    @ObservedObject var viewModel: NightscoutSettingsViewModel

    private enum TokenMode: Hashable {
        case haveToken
        case createFromSecret
    }

    @State private var mode: TokenMode = .haveToken
    @State private var apiSecret: String = ""
    @State private var isProvisioning = false
    @State private var provisioningError: String?

    var body: some View {
        Form {
            Section {
                EmptyView()
            } header: {
                OnboardingStepHeader(
                    systemImage: "globe",
                    title: "Connect to Nightscout",
                    subtitle: "Enter your site address. If your site needs a token, LoopFollow can create a read-only one for you."
                )
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            urlSection
            tokenModeSection

            switch mode {
            case .haveToken:
                tokenSection
            case .createFromSecret:
                secretSection
            }

            statusSection
        }
    }

    // MARK: - Sections

    private var urlSection: some View {
        Section(header: Text("URL")) {
            TextField("https://your-site.example.com", text: $viewModel.nightscoutURL)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: viewModel.nightscoutURL) { newValue in
                    viewModel.processURL(newValue)
                }
        }
    }

    private var tokenModeSection: some View {
        Section {
            Picker("Token", selection: $mode) {
                Text("I have a token").tag(TokenMode.haveToken)
                Text("Create one for me").tag(TokenMode.createFromSecret)
            }
            .pickerStyle(.segmented)
        } footer: {
            if mode == .createFromSecret {
                Text("Your API secret is used once to create a read-only access token and is never stored.")
            } else {
                Text("Paste a token, or a full Nightscout URL that includes a token. Leave empty if your site is public.")
            }
        }
    }

    private var tokenSection: some View {
        Section(header: Text("Access Token")) {
            HStack {
                Text("Token")
                TogglableSecureInput(
                    placeholder: "Enter Token",
                    text: $viewModel.nightscoutToken,
                    style: .singleLine,
                    textContentType: .password
                )
            }
        }
    }

    private var secretSection: some View {
        Section(header: Text("API Secret")) {
            HStack {
                Text("Secret")
                TogglableSecureInput(
                    placeholder: "Enter API Secret",
                    text: $apiSecret,
                    style: .singleLine,
                    textContentType: .password
                )
            }

            Button(action: createToken) {
                HStack {
                    Spacer()
                    if isProvisioning {
                        ProgressView()
                    } else {
                        Text("Create Read-Only Token")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .disabled(isProvisioning
                || apiSecret.isEmpty
                || viewModel.nightscoutURL.isEmpty)

            if let provisioningError {
                Text(provisioningError)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }

    private var statusSection: some View {
        Section(header: Text("Status")) {
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

    // MARK: - Token provisioning

    private func createToken() {
        provisioningError = nil
        isProvisioning = true
        let url = viewModel.nightscoutURL
        let secret = apiSecret

        Task {
            do {
                let token = try await NightscoutUtils.provisionReadOnlyToken(url: url, secret: secret)
                await MainActor.run {
                    apiSecret = ""
                    viewModel.nightscoutToken = token
                    isProvisioning = false
                }
            } catch {
                await MainActor.run {
                    isProvisioning = false
                    provisioningError = message(for: error)
                }
            }
        }
    }

    private func message(for error: Error) -> String {
        guard let nsError = error as? NightscoutUtils.NightscoutError else {
            return "Could not create a token. Please try again."
        }
        switch nsError {
        case .invalidToken:
            return "That API secret was rejected. Check it and try again."
        case .invalidURL, .emptyAddress:
            return "Please enter a valid site URL first."
        case .siteNotFound:
            return "Couldn't reach that site. Check the URL."
        case .networkError:
            return "Network error. Check your connection and try again."
        case .tokenRequired, .unknown:
            return "Could not create a token. Please try again."
        }
    }
}
