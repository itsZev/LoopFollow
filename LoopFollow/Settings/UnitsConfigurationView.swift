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

    /// Formats a mg/dL threshold pair in the currently selected glucose unit,
    /// e.g. "70–180 mg/dL" or "3.9–10.0 mmol/L".
    private func rangeBounds(_ lowMgdl: Double, _ highMgdl: Double) -> String {
        let factor = glucoseUnit == .mmolL ? GlucoseConversion.mgDlToMmolL : 1.0
        let digits = glucoseUnit.fractionDigits
        let low = Localizer.formatToLocalizedString(lowMgdl * factor, maxFractionDigits: digits, minFractionDigits: digits)
        let high = Localizer.formatToLocalizedString(highMgdl * factor, maxFractionDigits: digits, minFractionDigits: digits)
        return "\(low)–\(high) \(glucoseUnit.rawValue)"
    }

    var body: some View {
        Group {
            Section("Glucose") {
                Picker("Glucose Unit", selection: $glucoseUnit) {
                    Text("mg/dL").tag(GlucoseDisplayUnit.mgdL)
                    Text("mmol/L").tag(GlucoseDisplayUnit.mmolL)
                }
                .pickerStyle(.segmented)
                .onChange(of: glucoseUnit) { newValue in
                    UnitSettingsStore.shared.glucoseUnit = newValue
                }
            }

            Section {
                Picker("Range Mode", selection: $rangeMode) {
                    Text("TIR").tag(TimeInRangeDisplayMode.tir)
                    Text("TITR").tag(TimeInRangeDisplayMode.titr)
                    Text("Custom").tag(TimeInRangeDisplayMode.custom)
                }
                .pickerStyle(.segmented)
                .onChange(of: rangeMode) { newValue in
                    UnitSettingsStore.shared.timeInRangeMode = newValue
                    Observable.shared.chartSettingsChanged.value = true
                }

                if rangeMode == .custom {
                    BGPicker(
                        title: "Low",
                        range: 40 ... 120,
                        value: $lowValue
                    )
                    .id(glucoseUnit)
                    .onChange(of: lowValue) { newValue in
                        Storage.shared.lowLine.value = newValue
                        Observable.shared.chartSettingsChanged.value = true
                    }
                    BGPicker(
                        title: "High",
                        range: 120 ... 400,
                        value: $highValue
                    )
                    .id(glucoseUnit)
                    .onChange(of: highValue) { newValue in
                        Storage.shared.highLine.value = newValue
                        Observable.shared.chartSettingsChanged.value = true
                    }
                }
            } header: {
                Text("Range")
            } footer: {
                Text("TIR — Time in Range, the share of readings within \(rangeBounds(70, 180)). TITR — Time in Tight Range, within \(rangeBounds(70, 140)). Custom — set your own low and high.")
            }

            Section {
                Picker("Metric", selection: Binding(
                    get: { UnitSettingsStore.shared.glycemicMetricMode },
                    set: { UnitSettingsStore.shared.glycemicMetricMode = $0 }
                )) {
                    Text("eHbA1c").tag(GlycemicMetricMode.ehba1c)
                    Text("GMI").tag(GlycemicMetricMode.gmi)
                }
                .pickerStyle(.segmented)

                Picker("Output Unit", selection: Binding(
                    get: { UnitSettingsStore.shared.glycemicOutputUnit },
                    set: { UnitSettingsStore.shared.glycemicOutputUnit = $0 }
                )) {
                    Text("%").tag(GlycemicOutputUnit.percent)
                    Text("mmol/mol").tag(GlycemicOutputUnit.mmolMol)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Glycemic Metrics")
            } footer: {
                Text("eHbA1c — an A1c estimate from your average glucose. GMI — Glucose Management Indicator, another A1c estimate from average glucose. % and mmol/mol (IFCC) are two scales for the result.")
            }

            Section {
                Picker("Metric", selection: Binding(
                    get: { UnitSettingsStore.shared.variabilityMetricMode },
                    set: { UnitSettingsStore.shared.variabilityMetricMode = $0 }
                )) {
                    Text("Std Dev").tag(VariabilityMetricMode.stdDeviation)
                    Text("CV").tag(VariabilityMetricMode.cv)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Variability")
            } footer: {
                Text("Std Dev — Standard Deviation, how much glucose swings around the average. CV — Coefficient of Variation, that swing relative to the average (Std Dev ÷ mean).")
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
