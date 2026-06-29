// LoopFollow
// GraphSettingsView.swift

import SwiftUI

struct GraphSettingsView: View {
    @ObservedObject private var showDots = Storage.shared.showDots
    @ObservedObject private var showLines = Storage.shared.showLines
    @ObservedObject private var showValues = Storage.shared.showValues
    @ObservedObject private var showAbsorption = Storage.shared.showAbsorption
    @ObservedObject private var showDIALines = Storage.shared.showDIALines
    @ObservedObject private var show30MinLine = Storage.shared.show30MinLine
    @ObservedObject private var show90MinLine = Storage.shared.show90MinLine
    @ObservedObject private var showMidnightLines = Storage.shared.showMidnightLines
    @ObservedObject private var smallGraphTreatments = Storage.shared.smallGraphTreatments

    @ObservedObject private var smallGraphHeight = Storage.shared.smallGraphHeight
    @ObservedObject private var predictionToLoad = Storage.shared.predictionToLoad
    @ObservedObject private var predictionDisplayType = Storage.shared.predictionDisplayType
    @ObservedObject private var minBasalScale = Storage.shared.minBasalScale
    @ObservedObject private var minBGScale = Storage.shared.minBGScale
    @ObservedObject private var downloadDays = Storage.shared.downloadDays

    private var nightscoutEnabled: Bool { IsNightscoutEnabled() }

    var body: some View {
        NavigationView {
            Form {
                // ── Graph Display ────────────────────────────────────────────
                Section("图表显示") {
                    Toggle("显示 Dots", isOn: $showDots.value)
                        .onChange(of: showDots.value) { _ in markDirty() }

                    Toggle("显示 Lines", isOn: $showLines.value)
                        .onChange(of: showLines.value) { _ in markDirty() }

                    if nightscoutEnabled {
                        Toggle("显示胰岛素作用时间线", isOn: $showDIALines.value)
                            .onChange(of: showDIALines.value) { _ in markDirty() }

                        Toggle("显示 −30 分钟线", isOn: $show30MinLine.value)
                            .onChange(of: show30MinLine.value) { _ in markDirty() }

                        Toggle("显示 −90 分钟线", isOn: $show90MinLine.value)
                            .onChange(of: show90MinLine.value) { _ in markDirty() }
                    }

                    Toggle("显示午夜线", isOn: $showMidnightLines.value)
                        .onChange(of: showMidnightLines.value) { _ in markDirty() }
                }

                // ── Treatments ───────────────────────────────────────────────
                if nightscoutEnabled {
                    Section("治疗事件") {
                        Toggle("显示碳水/大剂量数值", isOn: $showValues.value)
                        Toggle("显示碳水吸收", isOn: $showAbsorption.value)
                        Toggle("治疗事件 on 小图表",
                               isOn: $smallGraphTreatments.value)
                    }
                }

                // ── Small Graph ──────────────────────────────────────────────
                Section("小图表") {
                    SettingsStepperRow(
                        title: "高度",
                        range: 40 ... 80,
                        step: 5,
                        value: $smallGraphHeight.value,
                        format: { "\(Int($0)) pt" }
                    )
                    .onChange(of: smallGraphHeight.value) { _ in markDirty() }
                }

                // ── Prediction ───────────────────────────────────────────────
                if nightscoutEnabled {
                    Section("预测") {
                        SettingsStepperRow(
                            title: "Hours of 预测",
                            range: 0 ... 6,
                            step: 0.25,
                            value: $predictionToLoad.value,
                            format: { "\($0.localized(maxFractionDigits: 2)) h" }
                        )

                        if Storage.shared.device.value != "Loop" {
                            Picker("预测 Style", selection: $predictionDisplayType.value) {
                                ForEach(PredictionDisplayType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .onChange(of: predictionDisplayType.value) { _ in markDirty() }
                        }
                    }
                }

                // ── Basal / BG scale ─────────────────────────────────────────
                if nightscoutEnabled {
                    Section("基础率/血糖刻度") {
                        SettingsStepperRow(
                            title: "最低基础率",
                            range: 0.5 ... 20,
                            step: 0.5,
                            value: $minBasalScale.value,
                            format: { "\($0.localized(maxFractionDigits: 1)) U/h" }
                        )

                        BGPicker(
                            title: "最低血糖刻度",
                            range: 40 ... 400,
                            value: $minBGScale.value
                        )
                        .onChange(of: minBGScale.value) { _ in markDirty() }
                    }
                }

                // ── History window ───────────────────────────────────────────
                if nightscoutEnabled {
                    Section("历史") {
                        SettingsStepperRow(
                            title: "回看天数",
                            range: 1 ... 4,
                            step: 1,
                            value: $downloadDays.value,
                            format: { "\(Int($0)) d" }
                        )
                    }
                }
            }
        }
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
        .navigationBarTitle("图表设置", displayMode: .inline)
    }

    /// Marks the chart as needing a redraw
    private func markDirty() {
        Observable.shared.chartSettingsChanged.value = true
    }
}
