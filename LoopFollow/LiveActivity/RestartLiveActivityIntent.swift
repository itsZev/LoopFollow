// LoopFollow
// RestartLiveActivityIntent.swift

import AppIntents
import UIKit

struct RestartLiveActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "重启实时活动"
    static var description = IntentDescription("启动或重启 LoopFollow 实时活动。")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        Storage.shared.laEnabled.value = true

        let keyId = Storage.shared.lfKeyId.value
        let apnsKey = Storage.shared.lfApnsKey.value

        if keyId.isEmpty || apnsKey.isEmpty {
            if let url = URL(string: "\(AppGroupID.urlScheme)://settings/live-activity") {
                await MainActor.run { UIApplication.shared.open(url) }
            }
            return .result(dialog: "请在 LoopFollow 设置中输入 APNs 凭据以使用实时活动。")
        }

        await MainActor.run { LiveActivityManager.shared.forceRestart() }

        return .result(dialog: "实时活动已重启。")
    }
}

struct LoopFollowAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RestartLiveActivityIntent(),
            phrases: ["重启 \(.applicationName) 中的实时活动"],
            shortTitle: "重启实时活动",
            systemImageName: "dot.radiowaves.left.and.right",
        )
    }
}
