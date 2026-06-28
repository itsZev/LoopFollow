// LoopFollow
// HighBgAlarmEditor.swift

import SwiftUI

struct HighBgAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(
                text: "血糖持续高于您在下方设置的阈值"
                    + "如需忽略短暂波动,请使用「持续」选项。"
            )

            AlarmGeneralSection(alarm: $alarm)

            AlarmBGSection(
                header: "高血糖阈值",
                footer: "任意一次读数达到或高于此值时,报警生效。",
                title: "BG",
                range: 120 ... 350,
                value: $alarm.aboveBG
            )

            AlarmStepperSection(
                header: "持续高血糖",
                footer: "血糖需持续高于阈值多长时间后,"
                    + "报警才会触发。设为 0 立即报警。",
                title: "持续时长",
                range: 0 ... 120,
                step: 5,
                unitLabel: alarm.type.snoozeTimeUnit.label,
                value: $alarm.persistentMinutes
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)
            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
