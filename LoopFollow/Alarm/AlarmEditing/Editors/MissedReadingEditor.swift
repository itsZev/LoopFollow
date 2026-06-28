// LoopFollow
// MissedReadingEditor.swift

import SwiftUI

struct MissedReadingEditor: View {
    @Binding var alarm: Alarm

    var body: some View {
        Group {
            InfoBanner(text: "This warns you if the glucose monitor stops sending readings for too long..", alarmType: alarm.type)

            AlarmGeneralSection(alarm: $alarm)

            AlarmStepperSection(
                header: "读数延迟",
                footer: "Choose how long the app should wait before alerting.",
                title: "无读数时长",
                range: 11 ... 121,
                step: 5,
                unitLabel: alarm.type.snoozeTimeUnit.label,
                value: $alarm.threshold
            )

            AlarmActiveSection(alarm: $alarm)
            AlarmAudioSection(alarm: $alarm)
            AlarmSnoozeSection(alarm: $alarm)
        }
    }
}
