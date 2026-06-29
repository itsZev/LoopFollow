// LoopFollow
// UnitsConfigurationView.swift

import SwiftUI

/// Reusable view for configuring units and metrics.
/// Can be embedded in Forms or used standalone during onboarding.
struct UnitsConfigurationView: View {
    @State private var rangeMode = UnitSettingsStore.shared.timeInRangeMode
    @State private var glucoseUnit = UnitSettingsStore.shared.glucoseUnit
    @State private var lowValue = Storage.shared.lowLine.value
    @State private var highValue = Storage.shared.highLine.value

    var body: some View {
        Group {
            Section("血糖") {
                Picker("血糖单位", selection: $glucoseUnit) {
                    Text("mg/dL").tag(GlucoseDisplayUnit.mgdL)
                    Text("mmol/L").tag(GlucoseDisplayUnit.mmolL)
                }
                .pickerStyle(.segmented)
                .onChange(of: glucoseUnit) { newValue in
                    UnitSettingsStore.shared.glucoseUnit = newValue
                }
            }

            Section("范围") {
                Picker("范围 Mode", selection: $rangeMode) {
                    Text("TIR").tag(TimeInRangeDisplayMode.tir)
                    Text("TITR").tag(TimeInRangeDisplayMode.titr)
                    Text("自定义").tag(TimeInRangeDisplayMode.custom)
                }
                .pickerStyle(.segmented)
                .onChange(of: rangeMode) { newValue in
                    UnitSettingsStore.shared.timeInRangeMode = newValue
                    Observable.shared.chartSettingsChanged.value = true
                }

                if rangeMode == .custom {
                    BGPicker(
                        title: "低血糖",
                        range: 40 ... 120,
                        value: $lowValue
                    )
                    .id(glucoseUnit)
                    .onChange(of: lowValue) { newValue in
                        Storage.shared.lowLine.value = newValue
                        Observable.shared.chartSettingsChanged.value = true
                    }
                    BGPicker(
                        title: "高血糖",
                        range: 120 ... 400,
                        value: $highValue
                    )
                    .id(glucoseUnit)
                    .onChange(of: highValue) { newValue in
                        Storage.shared.highLine.value = newValue
                        Observable.shared.chartSettingsChanged.value = true
                    }
                }
            }

            Section("血糖指标") {
                Picker("指标", selection: Binding(
                    get: { UnitSettingsStore.shared.glycemicMetricMode },
                    set: { UnitSettingsStore.shared.glycemicMetricMode = $0 }
                )) {
                    Text("eHbA1c").tag(GlycemicMetricMode.ehba1c)
                    Text("GMI").tag(GlycemicMetricMode.gmi)
                }
                .pickerStyle(.segmented)

                Picker("输出单位", selection: Binding(
                    get: { UnitSettingsStore.shared.glycemicOutputUnit },
                    set: { UnitSettingsStore.shared.glycemicOutputUnit = $0 }
                )) {
                    Text("%").tag(GlycemicOutputUnit.percent)
                    Text("mmol/mol").tag(GlycemicOutputUnit.mmolMol)
                }
                .pickerStyle(.segmented)
            }

            Section("波动性") {
                Picker("指标", selection: Binding(
                    get: { UnitSettingsStore.shared.variabilityMetricMode },
                    set: { UnitSettingsStore.shared.variabilityMetricMode = $0 }
                )) {
                    Text("标准差").tag(VariabilityMetricMode.stdDeviation)
                    Text("变异系数").tag(VariabilityMetricMode.cv)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

/// Standalone page for units configuration during onboarding.
/// Shows a checkmark button in the toolbar to complete setup.
struct UnitsOnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        Form {
            UnitsConfigurationView()
        }
        .navigationTitle("Set Up Units")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Storage.shared.hasConfiguredUnits.value = true
                    onComplete()
                }) {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
