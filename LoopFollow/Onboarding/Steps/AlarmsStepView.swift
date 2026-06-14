// LoopFollow
// AlarmsStepView.swift

import SwiftUI

struct AlarmsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        Form {
            Section {
                EmptyView()
            } header: {
                OnboardingStepHeader(
                    systemImage: "bell.badge.fill",
                    title: "Useful alarms",
                    subtitle: "We'll set up a few commonly used alarms with sensible defaults. Turn off any you don't want and adjust the rest."
                )
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section {
                ForEach($viewModel.seedAlarms) { $seed in
                    if viewModel.isSeedAlarmOffered(seed.type) {
                        Toggle(isOn: $seed.isEnabled) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(meta(for: seed.type).title)
                                    Text(meta(for: seed.type).detail)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: meta(for: seed.type).icon)
                            }
                        }

                        if seed.isEnabled {
                            control(for: $seed)
                        }
                    }
                }
            } footer: {
                Text("These come with sensible defaults — fine-tune them any time in the Alarms tab.")
            }
        }
    }

    // MARK: - Per-alarm control

    @ViewBuilder
    private func control(for seed: Binding<OnboardingViewModel.SeedAlarm>) -> some View {
        switch seed.wrappedValue.type {
        case .low:
            BGPicker(
                title: "Alert below",
                range: 40 ... 150,
                value: doubleBinding(seed, keyPath: \.belowBG, default: 80)
            )
        case .high:
            BGPicker(
                title: "Alert above",
                range: 120 ... 350,
                value: doubleBinding(seed, keyPath: \.aboveBG, default: 180)
            )
        case .missedReading:
            stepperRow(seed, label: "No reading for", range: 11 ... 121, step: 5, unit: "min", default: 16)
        case .notLooping:
            stepperRow(seed, label: "No loop for", range: 16 ... 61, step: 5, unit: "min", default: 31)
        case .battery:
            stepperRow(seed, label: "At or below", range: 0 ... 100, step: 5, unit: "%", default: 20)
        default:
            EmptyView()
        }
    }

    private func stepperRow(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        label: String,
        range: ClosedRange<Double>,
        step: Double,
        unit: String,
        default def: Double
    ) -> some View {
        let value = doubleBinding(seed, keyPath: \.threshold, default: def)
        return Stepper(value: value, in: range, step: step) {
            HStack {
                Text(label)
                Spacer()
                Text("\(Int(value.wrappedValue)) \(unit)")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func doubleBinding(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        keyPath: WritableKeyPath<Alarm, Double?>,
        default def: Double
    ) -> Binding<Double> {
        Binding(
            get: { seed.wrappedValue.alarm[keyPath: keyPath] ?? def },
            set: { seed.wrappedValue.alarm[keyPath: keyPath] = $0 }
        )
    }

    // MARK: - Copy

    private struct AlarmMeta {
        let title: String
        let detail: String
        let icon: String
    }

    private func meta(for type: AlarmType) -> AlarmMeta {
        switch type {
        case .low:
            return AlarmMeta(title: "Low glucose", detail: "Warns when glucose is low, now or soon.", icon: "arrow.down.circle.fill")
        case .high:
            return AlarmMeta(title: "High glucose", detail: "Warns when glucose stays high.", icon: "arrow.up.circle.fill")
        case .missedReading:
            return AlarmMeta(title: "Missed readings", detail: "Warns when glucose stops updating.", icon: "wifi.slash")
        case .notLooping:
            return AlarmMeta(title: "Not looping", detail: "Warns when the loop stops running.", icon: "arrow.triangle.2.circlepath")
        case .battery:
            return AlarmMeta(title: "Phone battery", detail: "Warns when your phone battery is low.", icon: "battery.25")
        default:
            return AlarmMeta(title: type.rawValue, detail: "", icon: "bell.fill")
        }
    }
}
