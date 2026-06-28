// LoopFollow
// PumpBatteryAlarmEditor.swift

import SwiftUI

struct PumpBatteryAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(
                text: "This warns you when the pump's battery gets low, based on the percentage you choose.",
                alarmType: alarm.type
            )

            AlarmGeneralSection(alarm: $alarm)

            AlarmStepperSection(
                header: "泵电量阈值",
                footer: "This alerts you when the pump battery drops to or below this level.",
                title: "低于等于",
                range: 0 ... 100,
                step: 5,
                unitLabel: "%",
                value: $alarm.threshold
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)
            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
