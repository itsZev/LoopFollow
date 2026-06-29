// LoopFollow
// ContactSettingsView.swift

import Contacts
import SwiftUI

struct ContactSettingsView: View {
    @ObservedObject var viewModel: ContactSettingsViewModel

    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("联系人集成")) {
                    Text("将名为「\(viewModel.contactName)」的联系人添加到表盘,可实时显示当前血糖。请在弹出提示时授予 App 对通讯录的完整访问权限。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)

                    Toggle("启用联系人血糖更新", isOn: $viewModel.contactEnabled)
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: viewModel.contactEnabled) { isEnabled in
                            if isEnabled {
                                requestContactAccess()
                            }
                        }
                }

                if viewModel.contactEnabled {
                    Section(header: Text("颜色选项")) {
                        Text("选择血糖数值的显示颜色。注意:并非所有表盘都支持自定义颜色。如需自定义,推荐使用「体能训练」或「模块化双重」等表盘。")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)

                        Picker("背景颜色", selection: $viewModel.contactBackgroundColor) {
                            ForEach(ContactColorOption.allCases, id: \.rawValue) { option in
                                Text(option.rawValue.capitalized).tag(option.rawValue)
                            }
                        }

                        Picker("颜色模式", selection: $viewModel.contactColorMode) {
                            ForEach(ContactColorMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }

                        if viewModel.contactColorMode == .staticColor {
                            Picker("文字颜色", selection: $viewModel.contactTextColor) {
                                ForEach(ContactColorOption.allCases, id: \.rawValue) { option in
                                    Text(option.rawValue.capitalized).tag(option.rawValue)
                                }
                            }
                        } else {
                            Text("动态模式根据血糖范围着色:绿色(达标)、黄色(偏高)、红色(偏低)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }

                    Section(header: Text("附加信息")) {
                        Text("要查看趋势、变化量或活性胰岛素,请将其加入其他联系人或创建独立联系人。在「包含」中可选择将数值添加到哪个联系人。")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)

                        Text("趋势")
                            .font(.subheadline)
                        Picker("显示趋势", selection: $viewModel.contactTrend) {
                            ForEach(ContactIncludeOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if viewModel.contactTrend == .include {
                            Picker("趋势包含于", selection: $viewModel.contactTrendTarget) {
                                ForEach(viewModel.availableTargets(for: .Trend), id: \.self) { target in
                                    Text(target.rawValue).tag(target)
                                }
                            }
                        }

                        Text("变化量")
                            .font(.subheadline)
                        Picker("显示变化量", selection: $viewModel.contactDelta) {
                            ForEach(ContactIncludeOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if viewModel.contactDelta == .include {
                            Picker("变化量包含于", selection: $viewModel.contactDeltaTarget) {
                                ForEach(viewModel.availableTargets(for: .Delta), id: \.self) { target in
                                    Text(target.rawValue).tag(target)
                                }
                            }
                        }

                        Text("活性胰岛素")
                            .font(.subheadline)
                        Picker("显示活性胰岛素", selection: $viewModel.contactIOB) {
                            ForEach(ContactIncludeOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if viewModel.contactIOB == .include {
                            Picker("活性胰岛素包含于", selection: $viewModel.contactIOBTarget) {
                                ForEach(viewModel.availableTargets(for: .IOB), id: \.self) { target in
                                    Text(target.rawValue).tag(target)
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("好")))
            }
        }
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
        .navigationBarTitle("Contact", displayMode: .inline)
    }

    private func requestContactAccess() {
        let contactStore = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)

        if status == .authorized {
            // Already authorized, do nothing
        } else if status == .notDetermined {
            contactStore.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    if !granted {
                        viewModel.contactEnabled = false
                        showAlert(title: "访问被拒绝", message: "请在设置中允许访问通讯录以启用此功能。")
                    }
                }
            }
        } else if status == .denied {
            viewModel.contactEnabled = false
            showAlert(title: "访问被拒绝", message: "通讯录访问被拒绝，请前往设置启用通讯录访问。")
        } else if status == .restricted {
            viewModel.contactEnabled = false
            showAlert(title: "访问受限", message: "通讯录访问受限。")
        } else {
            viewModel.contactEnabled = false
            showAlert(title: "错误", message: "检查通讯录访问时发生未知错误。")
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
