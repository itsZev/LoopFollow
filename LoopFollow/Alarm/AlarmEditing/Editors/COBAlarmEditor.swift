// LoopFollow
// COBAlarmEditor.swift

import SwiftUI

struct COBAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(
                text: "Alerts when Carbs-on-Board is at or above the amount you set below.",
                alarmType: alarm.type
            )

            AlarmGeneralSection(alarm: $alarm)

            AlarmStepperSection(
                header: "活性碳水上限",
                footer: "Alert when Carbs-on-Board is at or above this number.",
                title: "高于等于",
                range: 1 ... 200,
                step: 1,
                unitLabel: "g",
                value: $alarm.threshold
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)

            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
