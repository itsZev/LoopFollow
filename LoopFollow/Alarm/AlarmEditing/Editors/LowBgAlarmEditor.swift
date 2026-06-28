// LoopFollow
// LowBgAlarmEditor.swift

import SwiftUI

struct LowBgAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(text: "当血糖当前过低或预测即将过低时报警。注意:Trio 暂不支持预测。")

            AlarmGeneralSection(alarm: $alarm)

            AlarmBGSection(
                header: "低血糖阈值",
                footer: "任意一次读数或预测值达到或低于此值时报警。",
                title: "BG",
                range: 40 ... 150,
                value: $alarm.belowBG
            )

            AlarmStepperSection(
                header: "持续性",
                footer: "血糖需持续低于阈值达此分钟数,"
                    + "报警才会响起。设为 0 立即报警。",
                title: "持续",
                range: 0 ... 120,
                step: 5,
                unitLabel: alarm.type.snoozeTimeUnit.label,
                value: $alarm.persistentMinutes
            )

            AlarmStepperSection(
                header: "预测",
                footer: "在 Loop 预测中向前查看这么多分钟;"
                    + "若任意未来值达到或低于阈值,"
                    + "将提前预警。设为 0 关闭。",
                title: "预测",
                range: 0 ... 60,
                step: 5,
                unitLabel: alarm.type.snoozeTimeUnit.label,
                value: $alarm.predictiveMinutes
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)
            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
