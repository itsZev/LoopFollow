// LoopFollow
// PhoneBatteryAlarmEditor.swift

import SwiftUI

struct PhoneBatteryAlarmEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(
                text: "This warns you when the phone's battery gets low, based on the percentage you choose.",
                alarmType: alarm.type
            )

            AlarmGeneralSection(alarm: $alarm)

            AlarmStepperSection(
                header: "手机电量阈值",
                footer: "This alerts you when the phone battery drops to or below this level.",
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
