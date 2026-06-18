// LoopFollow
// AlarmsStepView.swift

import SwiftUI

/// The alarms phase: one recommended alarm per page, each with a toggle and a few
/// of its most useful settings. The number of pages depends on the data source
/// (Dexcom-only followers don't see loop/pump alarms), which the phase reports via
/// `phaseProgress` so the overall progress bar stays accurate.
struct AlarmsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    /// Page index into `offeredIndices`.
    @State private var index = 0

    /// Indices into `viewModel.seedAlarms` that are offered for this data source.
    private var offeredIndices: [Int] {
        viewModel.seedAlarms.indices.filter { viewModel.isOffered(viewModel.seedAlarms[$0]) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let seedIndex = offeredIndices[safe: index] {
                alarmPage(seedIndex: seedIndex)
            }

            OnboardingNavFooter(
                continueEnabled: true,
                showBack: true,
                onBack: goBack,
                onContinue: goForward
            )
        }
        .onAppear(perform: reportProgress)
        .onChange(of: index) { _ in reportProgress() }
    }

    private func reportProgress() {
        viewModel.phaseProgress = .init(page: index, count: offeredIndices.count)
    }

    private func goForward() {
        if index < offeredIndices.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) { index += 1 }
        } else {
            viewModel.advance()
        }
    }

    private func goBack() {
        if index > 0 {
            withAnimation(.easeInOut(duration: 0.25)) { index -= 1 }
        } else {
            viewModel.goBack()
        }
    }

    // MARK: - Page

    private func alarmPage(seedIndex: Int) -> some View {
        let seed = $viewModel.seedAlarms[seedIndex]
        let display = viewModel.seedAlarms[seedIndex]
        return Form {
            Section {
                EmptyView()
            } header: {
                VStack(spacing: 8) {
                    Image(systemName: display.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(display.title)
                        .font(.title2.weight(.bold))
                    Text(display.detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .textCase(nil)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section {
                Toggle("Enable this alarm", isOn: seed.isEnabled)

                if seed.wrappedValue.isEnabled {
                    controls(for: seed)
                }
            }
        }
    }

    // MARK: - Per-alarm controls

    @ViewBuilder
    private func controls(for seed: Binding<OnboardingViewModel.SeedAlarm>) -> some View {
        switch seed.wrappedValue.type {
        case .low:
            bgPicker(seed, title: "Alert below", range: 40 ... 150, keyPath: \.belowBG, default: 80)
            intStepper(seed, label: "Warn early by", range: 0 ... 30, step: 5, unit: "min", keyPath: \.predictiveMinutes, default: 0)
        case .high:
            bgPicker(seed, title: "Alert above", range: 120 ... 350, keyPath: \.aboveBG, default: 180)
            intStepper(seed, label: "Only after high for", range: 0 ... 60, step: 5, unit: "min", keyPath: \.persistentMinutes, default: 0)
        case .fastDrop:
            doubleStepper(seed, label: "Drop of at least", range: 5 ... 50, step: 1, unit: "mg/dL", keyPath: \.delta, default: 18)
        case .missedReading:
            doubleStepper(seed, label: "No reading for", range: 11 ... 121, step: 5, unit: "min", keyPath: \.threshold, default: 16)
        case .notLooping:
            doubleStepper(seed, label: "No loop for", range: 16 ... 61, step: 5, unit: "min", keyPath: \.threshold, default: 31)
        case .battery:
            doubleStepper(seed, label: "At or below", range: 0 ... 100, step: 5, unit: "%", keyPath: \.threshold, default: 20)
        case .iob:
            doubleStepper(seed, label: "Alert above", range: 0 ... 30, step: 1, unit: "U", keyPath: \.threshold, default: 6)
        case .cob:
            doubleStepper(seed, label: "Alert above", range: 0 ... 200, step: 5, unit: "g", keyPath: \.threshold, default: 20)
        case .sensorChange:
            doubleStepper(seed, label: "Remind after", range: 1 ... 15, step: 1, unit: "days", keyPath: \.threshold, default: 10)
        case .pumpChange:
            doubleStepper(seed, label: "Remind after", range: 1 ... 7, step: 1, unit: "days", keyPath: \.threshold, default: 3)
        case .pump:
            doubleStepper(seed, label: "Alert below", range: 0 ... 100, step: 5, unit: "U", keyPath: \.threshold, default: 10)
        default:
            EmptyView()
        }
    }

    private func bgPicker(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        title: String,
        range: ClosedRange<Double>,
        keyPath: WritableKeyPath<Alarm, Double?>,
        default def: Double
    ) -> some View {
        BGPicker(title: title, range: range, value: doubleBinding(seed, keyPath: keyPath, default: def))
    }

    private func doubleStepper(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        label: String,
        range: ClosedRange<Double>,
        step: Double,
        unit: String,
        keyPath: WritableKeyPath<Alarm, Double?>,
        default def: Double
    ) -> some View {
        let value = doubleBinding(seed, keyPath: keyPath, default: def)
        return Stepper(value: value, in: range, step: step) {
            labelRow(label, value: "\(formatted(value.wrappedValue)) \(unit)")
        }
    }

    private func intStepper(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        label: String,
        range: ClosedRange<Int>,
        step: Int,
        unit: String,
        keyPath: WritableKeyPath<Alarm, Int?>,
        default def: Int
    ) -> some View {
        let value = intBinding(seed, keyPath: keyPath, default: def)
        return Stepper(value: value, in: range, step: step) {
            labelRow(label, value: "\(value.wrappedValue) \(unit)")
        }
    }

    private func labelRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }

    private func formatted(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
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

    private func intBinding(
        _ seed: Binding<OnboardingViewModel.SeedAlarm>,
        keyPath: WritableKeyPath<Alarm, Int?>,
        default def: Int
    ) -> Binding<Int> {
        Binding(
            get: { seed.wrappedValue.alarm[keyPath: keyPath] ?? def },
            set: { seed.wrappedValue.alarm[keyPath: keyPath] = $0 }
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
