// LoopFollow
// IOBAlarmEditor.swift

import SwiftUI

struct IOBAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(
                text: "Alerts when insulin-on-board is high, or when several "
                    + "boluses in quick succession exceed the limits you set.",
                alarmType: alarm.type
            )

            AlarmGeneralSection(alarm: $alarm)

            AlarmStepperSection(
                header: "注射剂量上限",
                footer: "This counts only boluses larger than this size.",
                title: "高于",
                range: 0.1 ... 20,
                step: 0.1,
                unitLabel: "单位",
                value: $alarm.delta
            )

            AlarmStepperSection(
                header: "注射次数",
                footer: "Number of qualifying boluses needed to trigger.",
                title: "Count",
                range: 1 ... 10,
                step: 1,
                unitLabel: "Boluses",
                value: $alarm.monitoringWindow
            )

            AlarmStepperSection(
                header: "时间窗口",
                footer: "How far back to look for those boluses.",
                title: "Time",
                range: 5 ... 120,
                step: 5,
                unitLabel: "min",
                value: $alarm.predictiveMinutes
            )

            AlarmStepperSection(
                header: "Insulin On Board",
                footer: "Alert if current IOB or total boluses reach this.",
                title: "IOB 高于",
                range: 1 ... 20,
                step: 0.5,
                unitLabel: "单位",
                value: $alarm.threshold
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)
            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
