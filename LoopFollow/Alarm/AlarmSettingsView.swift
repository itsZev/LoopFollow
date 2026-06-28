// LoopFollow
// AlarmSettingsView.swift

import SwiftUI

struct AlarmSettingsView: View {
    @ObservedObject private var cfgStore = Storage.shared.alarmConfiguration

    /// Helper to bind an optional Date? into a non‑optional Date for DatePicker
    private func optDateBinding(_ b: Binding<Date?>) -> Binding<Date> {
        Binding(
            get: { b.wrappedValue ?? Date() },
            set: { b.wrappedValue = $0 }
        )
    }

    private var dayBinding: Binding<Date> {
        Binding(
            get: {
                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                c.hour = cfgStore.value.dayStart.hour
                c.minute = cfgStore.value.dayStart.minute
                return Calendar.current.date(from: c)!
            },
            set: { d in
                let hc = Calendar.current.dateComponents([.hour, .minute], from: d)
                cfgStore.value.dayStart = TimeOfDay(hour: hc.hour!, minute: hc.minute!)
            }
        )
    }

    private var nightBinding: Binding<Date> {
        Binding(
            get: {
                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                c.hour = cfgStore.value.nightStart.hour
                c.minute = cfgStore.value.nightStart.minute
                return Calendar.current.date(from: c)!
            },
            set: { d in
                let hc = Calendar.current.dateComponents([.hour, .minute], from: d)
                cfgStore.value.nightStart = TimeOfDay(hour: hc.hour!, minute: hc.minute!)
            }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(
                    header: Text("Snooze & Mute Options"),
                    footer: Text("""
                    “Snooze All” disables every alarm. \
                    “Mute All” silences phone sounds but still vibrates \
                    and shows iOS notifications.
                    """)
                ) {
                    Toggle("全部报警已静音", isOn: Binding(
                        get: {
                            if let until = cfgStore.value.snoozeUntil { return until > Date() }
                            return false
                        },
                        set: { on in
                            if on {
                                let target = cfgStore.value.snoozeUntil ?? Date()
                                if target <= Date() {
                                    cfgStore.value.snoozeUntil = Date().addingTimeInterval(3600)
                                }
                            } else {
                                cfgStore.value.snoozeUntil = nil
                            }
                        }
                    ))

                    if let until = cfgStore.value.snoozeUntil, until > Date() {
                        DatePicker(
                            "截止时间",
                            selection: optDateBinding(
                                Binding(
                                    get: { cfgStore.value.snoozeUntil },
                                    set: { cfgStore.value.snoozeUntil = $0 }
                                )
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                    }

                    Toggle("全部声音已静音", isOn: Binding(
                        get: {
                            if let until = cfgStore.value.muteUntil { return until > Date() }
                            return false
                        },
                        set: { on in
                            if on {
                                let target = cfgStore.value.muteUntil ?? Date()
                                if target <= Date() {
                                    cfgStore.value.muteUntil = Date().addingTimeInterval(3600)
                                }
                            } else {
                                cfgStore.value.muteUntil = nil
                            }
                        }
                    ))

                    if let until = cfgStore.value.muteUntil, until > Date() {
                        DatePicker(
                            "截止时间",
                            selection: optDateBinding(
                                Binding(
                                    get: { cfgStore.value.muteUntil },
                                    set: { cfgStore.value.muteUntil = $0 }
                                )
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                    }
                }

                Section(
                    header: Text("白天/夜晚时段"),
                    footer: Text("设置白天和夜晚的开始时间。" +
                        "「白天开始」到「夜晚开始」之间计为白天;" +
                        "「夜晚开始」到次日「白天开始」之间计为夜晚。")
                ) {
                    DatePicker(
                        "白天开始",
                        selection: dayBinding,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)

                    DatePicker(
                        "夜晚开始",
                        selection: nightBinding,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }

                Section(header: Text("报警设置")) {
                    Toggle(
                        "覆盖系统音量",
                        isOn: Binding(
                            get: { cfgStore.value.overrideSystemOutputVolume },
                            set: { cfgStore.value.overrideSystemOutputVolume = $0 }
                        )
                    )

                    if cfgStore.value.overrideSystemOutputVolume {
                        Stepper(
                            "音量: \(Int(cfgStore.value.forcedOutputVolume * 100))%",
                            value: Binding(
                                get: { Double(cfgStore.value.forcedOutputVolume) },
                                set: { cfgStore.value.forcedOutputVolume = Float($0) }
                            ),
                            in: 0 ... 1,
                            step: 0.05
                        )
                    }

                    Toggle(
                        "通话时播放报警音",
                        isOn: Binding(
                            get: { cfgStore.value.audioDuringCalls },
                            set: { cfgStore.value.audioDuringCalls = $0 }
                        )
                    )

                    Toggle(
                        "忽略 0 血糖读数",
                        isOn: Binding(
                            get: { cfgStore.value.ignoreZeroBG },
                            set: { cfgStore.value.ignoreZeroBG = $0 }
                        )
                    )

                    Toggle(
                        "CGM 启动时自动静音",
                        isOn: Binding(
                            get: { cfgStore.value.autoSnoozeCGMStart },
                            set: { cfgStore.value.autoSnoozeCGMStart = $0 }
                        )
                    )

                    Toggle(
                        "音量键静音报警",
                        isOn: Binding(
                            get: { cfgStore.value.enableVolumeButtonSnooze },
                            set: { cfgStore.value.enableVolumeButtonSnooze = $0 }
                        )
                    )
                }
            }
        }
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
        .navigationBarTitle("报警设置", displayMode: .inline)
    }
}
