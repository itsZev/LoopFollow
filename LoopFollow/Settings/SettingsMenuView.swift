// LoopFollow
// SettingsMenuView.swift

import SwiftUI
import UIKit

struct SettingsMenuView: View {
    // MARK: - Observed Objects

    @ObservedObject private var nightscoutURL = Storage.shared.url
    @ObservedObject private var settingsPath = Observable.shared.settingsPath

    // MARK: – Local state

    var onBack: (() -> Void)?

    // MARK: – Observed objects

    @ObservedObject private var url = Storage.shared.url

    // MARK: – Body

    var body: some View {
        NavigationStack(path: $settingsPath.value) {
            List {
                dataSection

                Section("显示设置") {
                    NavigationRow(title: "通用",
                                  icon: "gearshape")
                    {
                        settingsPath.value.append(Sheet.general)
                    }

                    NavigationRow(title: "图表",
                                  icon: "chart.xyaxis.line")
                    {
                        settingsPath.value.append(Sheet.graph)
                    }

                    if !nightscoutURL.value.isEmpty {
                        NavigationRow(title: "信息显示",
                                      icon: "info.circle")
                        {
                            settingsPath.value.append(Sheet.infoDisplay)
                        }
                    }
                    NavigationRow(title: "单位与指标",
                                  icon: "scalemass")
                    {
                        settingsPath.value.append(Sheet.units)
                    }

                    NavigationRow(title: "标签页",
                                  icon: "rectangle.3.group")
                    {
                        settingsPath.value.append(Sheet.tabSettings)
                    }
                }

                Section("应用设置") {
                    NavigationRow(title: "后台刷新",
                                  icon: "arrow.clockwise")
                    {
                        settingsPath.value.append(Sheet.backgroundRefresh)
                    }

                    NavigationRow(title: "导入/导出",
                                  icon: "square.and.arrow.down")
                    {
                        settingsPath.value.append(Sheet.importExport)
                    }

                    NavigationRow(title: "APN",
                                  icon: "bell.and.waves.left.and.right")
                    {
                        settingsPath.value.append(Sheet.apn)
                    }

                    #if !targetEnvironment(macCatalyst)
                        NavigationRow(title: "实时活动",
                                      icon: "dot.radiowaves.left.and.right")
                        {
                            settingsPath.value.append(Sheet.liveActivity)
                        }
                    #endif

                    if !nightscoutURL.value.isEmpty && MVPFeatureFlags.remoteControlEnabled {
                        NavigationRow(title: "远程",
                                      icon: "antenna.radiowaves.left.and.right")
                        {
                            settingsPath.value.append(Sheet.remote)
                        }
                    }
                }

                Section("报警") {
                    NavigationRow(title: "报警",
                                  icon: "bell.badge")
                    {
                        settingsPath.value.append(Sheet.alarmSettings)
                    }
                }

                Section("集成") {
                    NavigationRow(title: "日历",
                                  icon: "calendar")
                    {
                        settingsPath.value.append(Sheet.calendar)
                    }

                    NavigationRow(title: "联系人",
                                  icon: "person.circle")
                    {
                        settingsPath.value.append(Sheet.contact)
                    }
                }

                Section("高级设置") {
                    NavigationRow(title: "高级",
                                  icon: "exclamationmark.shield")
                    {
                        settingsPath.value.append(Sheet.advanced)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Sheet.self) { $0.destination }
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
    }

    // MARK: – Section builders

    @ViewBuilder
    private var dataSection: some View {
        Section("数据设置") {
            NavigationRow(title: "Nightscout",
                          icon: "network")
            {
                settingsPath.value.append(Sheet.nightscout)
            }

            NavigationRow(title: "Dexcom",
                          icon: "sensor.tag.radiowaves.forward")
            {
                settingsPath.value.append(Sheet.dexcom)
            }
        }
    }
}

// MARK: – Sheet routing

private enum Sheet: Hashable, Identifiable {
    case units
    case nightscout, dexcom
    case backgroundRefresh
    case general, graph
    case tabSettings
    case infoDisplay
    case alarmSettings
    case apn
    #if !targetEnvironment(macCatalyst)
        case liveActivity
    #endif
    case remote
    case importExport
    case calendar, contact
    case advanced
    case aggregatedStats

    var id: Self { self }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .units: UnitsSettingsView()
        case .nightscout: NightscoutSettingsView(viewModel: .init())
        case .dexcom: DexcomSettingsView(viewModel: .init())
        case .backgroundRefresh: BackgroundRefreshSettingsView(viewModel: .init())
        case .general: GeneralSettingsView()
        case .graph: GraphSettingsView()
        case .tabSettings: TabCustomizationModal()
        case .infoDisplay: InfoDisplaySettingsView(viewModel: .init())
        case .alarmSettings: AlarmSettingsView()
        case .apn: APNSettingsView()
        #if !targetEnvironment(macCatalyst)
            case .liveActivity: LiveActivitySettingsView()
        #endif
        case .remote: RemoteSettingsView(viewModel: .init())
        case .importExport: ImportExportSettingsView()
        case .calendar: CalendarSettingsView()
        case .contact: ContactSettingsView(viewModel: .init())
        case .advanced: AdvancedSettingsView(viewModel: .init())
        case .aggregatedStats:
            AggregatedStatsViewWrapper()
        }
    }
}

// Helper view to access MainViewController
struct AggregatedStatsViewWrapper: View {
    @State private var mainViewController: MainViewController?

    var body: some View {
        Group {
            if let mainVC = mainViewController {
                AggregatedStatsContentView(mainViewController: mainVC)
            } else {
                Text("加载统计中...")
                    .onAppear {
                        mainViewController = getMainViewController()
                    }
            }
        }
    }

    private func getMainViewController() -> MainViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController
        else {
            return nil
        }

        if let mainVC = rootVC as? MainViewController {
            return mainVC
        }

        if let navVC = rootVC as? UINavigationController,
           let mainVC = navVC.viewControllers.first as? MainViewController
        {
            return mainVC
        }

        if let tabVC = rootVC as? UITabBarController {
            for vc in tabVC.viewControllers ?? [] {
                if let mainVC = vc as? MainViewController {
                    return mainVC
                }
                if let navVC = vc as? UINavigationController,
                   let mainVC = navVC.viewControllers.first as? MainViewController
                {
                    return mainVC
                }
            }
        }

        return nil
    }
}

// MARK: – UIKit helpers (unchanged)

import UIKit

extension UIApplication {
    var topMost: UIViewController? {
        guard var top = keyWindow?.rootViewController else { return nil }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

extension UIViewController {
    func presentSimpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "确定", style: .default))
        present(a, animated: true)
    }
}
